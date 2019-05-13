//
//  ViewController.swift
//  LazyLoading
//
//  Created by Amit on 5/11/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import FBAudienceNetwork
import UIKit

class ListViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    var userResults: [ListItem] = []

    // loader view created by alert controller
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

    // Network classes
    let apiService = ApiService()
    let downloadService = DownloadService()

    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "myBackgroundConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    // custom layout for collection view
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )

    // for add count
    let adRowStep = 6

    // FB add manager
    var adsManager: FBNativeAdsManager!
    var adsCellProvider: FBNativeAdCollectionViewCellProvider!

    override func viewDidLoad() {
        super.viewDidLoad()

        downloadService.downloadsSession = downloadsSession

        addLoader()
        configureCollectionView()

        apiService.getResults(limit: 50, completion: { results, errorMessage in
            if let results = results {
                self.userResults = results
                self.collectionView.reloadData()
            }
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
            self.alert.dismiss(animated: false, completion: nil)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        configureAdManagerAndLoadAds()
    }

    func configureCollectionView() {
        collectionView.backgroundColor = UIColor(red: 254 / 255, green: 219 / 255, blue: 208 / 255, alpha: 1)

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always

        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectionViewCell")
    }

    func addLoader() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    func configureAdManagerAndLoadAds() {
        if adsManager == nil {
            FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
            adsManager = FBNativeAdsManager(placementID: "360114424609341_360313877922729", forNumAdsRequested: 5)
            adsManager.delegate = self
            adsManager.loadAds()
        }
    }

    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            let cell: CustomCollectionViewCell = collectionView.cellForItem(at: (sender as! IndexPath)) as! CustomCollectionViewCell

            let destination = segue.destination as! ImageViewController

            destination.receivedImage = cell.image.image
        }
    }
}

// for collection view
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if adsCellProvider != nil {
            return Int(adsCellProvider.adjustCount(UInt(userResults.count), forStride: UInt(adRowStep)))
        } else {
            return userResults.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if adsCellProvider != nil && adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
            return adsCellProvider.collectionView(collectionView, cellForItemAt: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell

            let listItem = userResults[indexPath.row - Int(indexPath.row / adRowStep)]

            cell.configure(with: listItem)

            let destinationUrl = localFilePath(for: URL(string: listItem.imageUrl)!)

            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: destinationUrl.path) {
                let data = fileManager.contents(atPath: destinationUrl.path)
                let downloadedImage = UIImage(data: data as! Data)
                cell.image.image = downloadedImage

            } else {
                downloadService.downloadImageFrom(item: listItem)
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showImage", sender: indexPath)
    }
}

// for url session
extension ListViewController: URLSessionDownloadDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }

        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil

        let destinationURL = localFilePath(for: sourceURL)

        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)

        } catch let error {
            print("error copying to disk: \(error.localizedDescription)")
        }

        if let index = download?.indexValue {
            var indexPath = IndexPath(row: index, section: 0)

            let row: Int = indexPath.row + Int(indexPath.row / (adRowStep - 1))

            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
            }
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

// for FB Add delegates
extension ListViewController: FBNativeAdDelegate, FBNativeAdsManagerDelegate {
    func nativeAdsLoaded() {
        print("ads loaded")
        adsCellProvider = FBNativeAdCollectionViewCellProvider(manager: adsManager, for: .dynamic)
        adsCellProvider.delegate = self
    }

    func nativeAdsFailedToLoadWithError(_ error: Error) {
        print("ads load failed")
    }
}
