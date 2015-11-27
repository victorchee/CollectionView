//
//  CollectionViewCell.swift
//  CustomCollectionViewLayouts
//
//  Created by qihaijun on 11/27/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = UIColor.blackColor().CGColor
        contentView.layer.borderWidth = 1
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
        contentView.clipsToBounds = true
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let circularLayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        layer.anchorPoint = circularLayoutAttributes.anchorPoint
        center.y += (circularLayoutAttributes.anchorPoint.y - 0.5) * bounds.height
    }
}
