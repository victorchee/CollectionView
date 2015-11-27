//
//  CircularCollectionViewLayout.swift
//  CustomCollectionViewLayouts
//
//  Created by qihaijun on 11/27/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var anchorPoint = CGPoint(x: 0.5, y: 0.5) // 旋转锚点
    var angle: CGFloat = 0 {
        didSet {
            zIndex = Int(angle * 1000000) // 保证右边的cell覆盖在左边的cell上
            transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copiedAttributes = super.copyWithZone(zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = anchorPoint
        copiedAttributes.angle = angle
        return copiedAttributes
    }
}

class CircularCollectionViewLayout: UICollectionViewLayout {
    let itemSize = CGSize(width: 133, height: 173)
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItemsInSection(0) > 0 ? -CGFloat(collectionView!.numberOfItemsInSection(0) - 1) * anglePerItem : 0
    }
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionView!.contentSize.width - collectionView!.bounds.width)
    }
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout() // 半径改变需要重新计算所有值
        }
    }
    
    var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }
    
    var attributesList = [CircularCollectionViewLayoutAttributes]() // 布局属性
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0)) * itemSize.width, height: collectionView!.bounds.height)
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return CircularCollectionViewLayoutAttributes.self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)
        let anchorPointY = (itemSize.height / 2.0 + radius) / itemSize.height
        
        // 计算离屏item
        let theta = atan2(collectionView!.bounds.width / 2.0, radius + itemSize.height / 2.0 - collectionView!.bounds.height / 2.0)
        var startIndex = 0
        var endIndex = collectionView!.numberOfItemsInSection(0) - 1
        if angle < -theta {
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        if endIndex < startIndex {
            endIndex = 0
            startIndex = 0
        }
        
        attributesList = (startIndex ... endIndex).map({ (i) -> CircularCollectionViewLayoutAttributes in
            let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            attributes.size = itemSize
            attributes.center = CGPoint(x: centerX, y: CGRectGetMidY(collectionView!.bounds))
            attributes.angle = angle + anglePerItem * CGFloat(i)
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            
            return attributes
        })
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesList[indexPath.item]
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        // 滑动时布局失效，collectionView调用prepareLayout()来重新布局
        return true
    }
    
    // snapping
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        let factor = -angleAtExtreme / (collectionView!.contentSize.width - collectionView!.bounds.width)
        let proposedAngle = proposedContentOffset.x * factor
        let ratio = proposedAngle / anglePerItem
        var multiplier: CGFloat
        if velocity.x > 0 {
            multiplier = ceil(ratio)
        } else if velocity.x < 0 {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        finalContentOffset.x = multiplier * anglePerItem / factor
        return finalContentOffset
    }
}
