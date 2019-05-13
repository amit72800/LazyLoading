//
//  DownloadService.swift
//  LazyLoading
//
//  Created by Amit on 5/12/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import Foundation
import UIKit

class DownloadService: NSObject {
    var downloadsSession: URLSession!
    var activeDownloads: [URL: ListItem] = [:]

    func downloadImageFrom(item: ListItem) {
        let url = URL(string: item.imageUrl)!

        let task = downloadsSession.downloadTask(with: url)
        task.resume()

        activeDownloads[url] = item
    }
}
