//
//  BookStoreLayout.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookStoreLayout: UICollectionViewFlowLayout {
    private let pageSize = CGSize(width: 362, height: 536)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .Horizontal
        itemSize = pageSize
        minimumInteritemSpacing = 10.0
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: collectionView!.bounds.width / 2.0 - pageSize.width / 2.0, bottom: 0, right: collectionView!.bounds.width / 2.0 - pageSize.width / 2.0)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElementsInRect(rect)
        var copedAttributes = [UICollectionViewLayoutAttributes]()
        if let attributes = attributes {
            for attribute in attributes {
                let copyedAttribute = attribute.copy() as! UICollectionViewLayoutAttributes
                let frame = attribute.frame
                let distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x) // 封面与屏幕中心的距离
                let scale = 0.7 * min(max(1 - distance / collectionView!.bounds.width, 0.75), 1)
                copyedAttribute.transform = CGAffineTransformMakeScale(scale, scale)
                copedAttributes.append(copyedAttribute)
            }
        }
        return copedAttributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        // snap cells to centre
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        let width = layout.itemSize.width + layout.minimumLineSpacing
        var offset = proposedContentOffset.x + collectionView!.contentInset.left
        
        if velocity.x > 0 {
            // 右滑
            offset = width * ceil(offset / width)
        } else if velocity.x == 0 {
            // 滑动距离不够，保持不变
            offset = width * round(offset / width)
        } else {
            // 左滑
            offset = width * floor(offset / width)
        }
        return CGPoint(x: offset - collectionView!.contentInset.left, y: proposedContentOffset.y)
    }
}
