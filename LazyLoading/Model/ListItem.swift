//
//  List.swift
//  LazyLoading
//
//  Created by Amit on 5/11/19.
//  Copyright © 2019 Amit. All rights reserved.
//

import Foundation

class ListItem {
    
    let title: String
    let imageUrl: String
    let indexValue: Int
    
    init(title: String, imageUrl: String, indexValue: Int) {
        self.title = title
        self.imageUrl = imageUrl
        self.indexValue = indexValue
    }
    
}

