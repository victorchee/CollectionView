//
//  CircularCollectionViewLayout.swift
//  CustomCollectionViewLayouts
//
//  Created by qihaijun on 11/27/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    /// item 的锚点
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    /// item 的角度
    var angle: CGFloat = 0 {
        didSet {
            zIndex = Int(angle * 10000) // 保证右边的 item 覆盖在左边的 item 上，乘以10000是为了保持精度
            transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        // 在collectionView布局时，内部会拷贝布局属性。复写这个方法来确保复制过程中，anchorPoint 和 angle两个属性也会被拷贝
        let copiedAttributes = super.copyWithZone(zone) as! CircularCollectionViewLayoutAttributes
        copiedAttributes.anchorPoint = anchorPoint
        copiedAttributes.angle = angle
        return copiedAttributes
    }
}

class CircularCollectionViewLayout: UICollectionViewLayout {
    let itemSize = CGSize(width: 150, height: 200)
    
    var anglePerItem: CGFloat {
        return atan(itemSize.width / radius)
    }
    /// 最后一个item在中心时，即移到最后时，第一个item的角度
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItemsInSection(0) > 0 ? -CGFloat(collectionView!.numberOfItemsInSection(0) - 1) * anglePerItem : 0
    }
    /// 第0个 item 的角度
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionView!.contentSize.width - collectionView!.bounds.width)
    }
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout() // 半径改变需要重新计算所有值
        }
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
        let anchorPointY = (itemSize.height / 2.0 + radius) / itemSize.height // item 的锚点Y
        
        // 只对显示的item做处理，剔除离屏的item
        let theta = atan2(collectionView!.bounds.width / 2.0, radius + itemSize.height / 2.0 - collectionView!.bounds.height / 2.0)
        var startIndex = 0
        var endIndex = collectionView!.numberOfItemsInSection(0) - 1
        if angle < -theta {
            // 如果第0个 item 的角位置小于 -θ，那么它就是离屏的，屏上第 1 个 item 的 index 将为 -θ 与 angle 的差值再除以 anglePerItem
            startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem))) // 屏幕上最后一个 item 是 θ 与 angle 的差值再除以 anglePerItem，min 是保证endIndex不会越界
        if endIndex < startIndex {
            // 容错处理，防止在快速滑动时所有 item 都离屏时导致 endIndex小于 startIndex的情况
            endIndex = 0
            startIndex = 0
        }
        
        attributesList = (startIndex ... endIndex).map({ (i) -> CircularCollectionViewLayoutAttributes in
            let attributes = CircularCollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            attributes.size = itemSize
            attributes.center = CGPoint(x: centerX, y: CGRectGetMidY(collectionView!.bounds)) // collectionView的中点
            attributes.angle = angle + anglePerItem * CGFloat(i)
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY) // 锚点下移
            
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
    
    // 让 item 滑动停在 collectionView 的正中位置
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
