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
            let corners: UIRectCorner = isRightPage ? [.TopRight, .BottomRight] : [.TopLeft, .BottomLeft]
            imageView.image = image?.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(20, corners: corners)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAntialiasing()
        initShadowLayer()
    }
    
    private func setupAntialiasing() {
        layer.allowsEdgeAntialiasing = true
        imageView.layer.allowsEdgeAntialiasing = true
    }
    
    private func initShadowLayer() {
        shadowLayer = CAGradientLayer()
        shadowLayer.frame = bounds
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        imageView.layer.addSublayer(shadowLayer)
    }
    
    private func getRatioFromTransform() -> CGFloat {
        var ratio: CGFloat = 0
        if let rotationYValue = layer.valueForKey("transform.rotation.y") {
            let rotationY = CGFloat(rotationYValue.floatValue)
            
            if isRightPage {
                ratio = 1 - rotationY / CGFloat(-M_PI_2)
            } else {
                ratio = -(1 - rotationY / CGFloat(M_PI_2))
            }
        }
        
        return ratio
    }
    
    func updateShadowLayer(animated animated: Bool = false) {
        let ratio: CGFloat = getRatioFromTransform()
        let inverseRatio = 1 - abs(ratio)
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
        }
        
        if isRightPage {
            shadowLayer.colors = [UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.45).CGColor,
                UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.40).CGColor,
                UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.55).CGColor]
            shadowLayer.locations = [NSNumber(float: 0), NSNumber(float: 0.02), NSNumber(float: 1.0)];
        } else {
            shadowLayer.colors = [UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.30).CGColor,
                UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.40).CGColor,
                UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.50).CGColor,
                UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.55).CGColor]
            shadowLayer.locations = [NSNumber(float: 0), NSNumber(float: 0.50), NSNumber(float: 0.98), NSNumber(float: 1.0)];
        }
        
        if !animated {
            CATransaction.commit()
        }
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes.copy() as! UICollectionViewLayoutAttributes)
        
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
