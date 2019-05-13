//
//  ImageViewController.swift
//  LazyLoading
//
//  Created by Amit on 5/12/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!

    var receivedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = receivedImage
        // Do any additional setup after loading the view.
        imageView.isUserInteractionEnabled = true
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))

        imageView.addGestureRecognizer(pinchGesture)
    }

    @objc func pinchGesture(sender: UIPinchGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!

        sender.scale = 1.0
    }
}
