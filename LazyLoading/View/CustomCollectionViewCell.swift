//
//  CustomCollectionViewCell.swift
//  LazyLoading
//
//  Created by Amit on 5/11/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!
    @IBOutlet var name: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(with model: ListItem) {
        image.image = UIImage(named: "placeholder")
        image.layer.cornerRadius = 5
        name.text = model.title
    }
}
