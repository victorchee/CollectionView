//
//  BookCoverCell.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookCoverCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book? {
        didSet {
            image = book?.coverImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image?.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(20, corners: [.TopRight, .BottomRight])
        }
    }
}
