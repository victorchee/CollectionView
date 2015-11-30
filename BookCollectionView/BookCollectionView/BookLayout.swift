//
//  BookLayout.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookLayout: UICollectionViewFlowLayout {
    private let pageSize = CGSize(width: 362, height: 536)
    private var numberOfItems: Int = 0
    
    override func prepareLayout() {
        super.prepareLayout()
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        numberOfItems = collectionView?.numberOfItemsInSection(0) ?? 0
        collectionView?.pagingEnabled = true
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(numberOfItems / 2) * collectionView!.bounds.width, height: collectionView!.bounds.height)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        for i in 0 ... max(0, numberOfItems - 1) {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let attribute = layoutAttributesForItemAtIndexPath(indexPath)
            if attribute != nil {
                attributes.append(attribute!)
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let frame = getFrame(collectionView!)
        layoutAttributes.frame = frame // 给布局属性设置 frame，来保证它会与书脊对齐
        
        let ratio = getRatio(collectionView!, indexPath: indexPath) // 设置布局属性的比率
        // 判断当前页的比率是否在限制范围内，如果不在就不展示这个 cell。为了优化，通常不显示背面，只展示正面。当然如果是书的封面则需要一直展示
        if ratio > 0 && indexPath.item % 2 == 1 || ratio < 0 && indexPath.item % 2 == 0 {
            // 保证封面一直显示
            if indexPath.item != 0 {
                return nil
            }
        }
        
        let rotation = getRotation(indexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation // 根据计算得到比率来获取 rotation 和 transform
        
        if indexPath.item == 0 {
            // 判断 indexPath 是否为第一页，如果是第一页则设置其 zIndex 让它显示在所有页面之上，避免闪现情况发生
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
    
    private func getFrame(collectionView: UICollectionView) -> CGRect {
        var frame = CGRect.zero
        frame.origin.x = collectionView.bounds.width / 2.0 - pageSize.width / 2.0 + collectionView.contentOffset.x
        frame.origin.y = (collectionView.contentSize.height - pageSize.height) / 2.0
        frame.size = pageSize
        return frame
    }
    
    private func getRatio(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat {
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5 // 计算页面在书本当中的编号，记住书页是双面的。乘以0.5可以得到你当前所在的页面
        var ratio: CGFloat = -0.5 + page - collectionView.contentOffset.x / collectionView.bounds.width // 根据你翻动的权重计算比率
        // 需要将比率范围限制在-0.5到0.5之间。乘以0.1是用来给页面之间添加一个间距使得它们看起来是被遮盖一样
        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }
        return ratio
    }
    
    private func getAngle(indexPath: NSIndexPath, ratio: CGFloat) -> CGFloat {
        var angle: CGFloat = 0
        
        if indexPath.item % 2 == 0 {
            // right page
            angle = (1.0 - ratio) * CGFloat(-M_PI_2) // 向左翻动是逆时针
        } else if indexPath.item % 2 == 1 {
            // left page
            angle = (1.0 + ratio) * CGFloat(M_PI_2) // 向右翻动是顺时针
        }
        angle += CGFloat(indexPath.row % 2) / 1000 // 为每个页面添加一个偏移角度
        return angle
    }
    
    private func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000.0 // 修改m34来增加透视
        return transform
    }
    
    private func getRotation(indexPath: NSIndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }
}
