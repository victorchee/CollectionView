//
//  BookPageCell.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookPageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var book: Book?
    var isRightPage = false
    var shadowLayer = CAGradientLayer()
    
    override var bounds: CGRect {
        didSet {
            shadowLayer.frame = bounds
        }
    }
    
    var image: UIImage? {
        didSet {
            let corners: UIRectCorner = isRightPage ? [.topRight, .bottomRight] : [.topLeft, .bottomLeft]
            imageView.image = image?.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(20, corners: corners)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAntialiasing()
        initShadowLayer()
    }
    
    fileprivate func setupAntialiasing() {
        layer.allowsEdgeAntialiasing = true
        imageView.layer.allowsEdgeAntialiasing = true
    }
    
    fileprivate func initShadowLayer() {
        shadowLayer = CAGradientLayer()
        shadowLayer.frame = bounds
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        imageView.layer.addSublayer(shadowLayer)
    }
    
    fileprivate func getRatioFromTransform() -> CGFloat {
        var ratio: CGFloat = 0
        if let rotationYValue = layer.value(forKey: "transform.rotation.y") {
            let rotationY = CGFloat((rotationYValue as AnyObject).floatValue)
            
            if isRightPage {
                ratio = 1 - rotationY / CGFloat(-M_PI_2)
            } else {
                ratio = -(1 - rotationY / CGFloat(M_PI_2))
            }
        }
        
        return ratio
    }
    
    func updateShadowLayer(animated: Bool = false) {
        let ratio: CGFloat = getRatioFromTransform()
        let inverseRatio = 1 - abs(ratio)
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
        }
        
        if isRightPage {
            shadowLayer.colors = [UIColor.darkGray.withAlphaComponent(inverseRatio * 0.45).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor]
            shadowLayer.locations = [NSNumber(value: 0 as Float), NSNumber(value: 0.02 as Float), NSNumber(value: 1.0 as Float)];
        } else {
            shadowLayer.colors = [UIColor.darkGray.withAlphaComponent(inverseRatio * 0.30).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.40).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.50).cgColor,
                UIColor.darkGray.withAlphaComponent(inverseRatio * 0.55).cgColor]
            shadowLayer.locations = [NSNumber(value: 0 as Float), NSNumber(value: 0.50 as Float), NSNumber(value: 0.98 as Float), NSNumber(value: 1.0 as Float)];
        }
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes.copy() as! UICollectionViewLayoutAttributes)
        
        if layoutAttributes.indexPath.item % 2 == 0 {
            layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            isRightPage = true
        } else {
            layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            isRightPage = false
        }
//        updateShadowLayer()
    }
}
