//
//  WaterfallFlowLayout.swift
//  WaterfallCollectionView
//
//  Created by Victor Chee on 16/5/12.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import UIKit

@objc protocol WaterfallFlowLayoutDataSource {
    func collectionView(collectionView: UICollectionView, layout: WaterfallFlowLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize
}

class WaterfallFlowLayout: UICollectionViewLayout {
    var dataSource: WaterfallFlowLayoutDataSource? = nil
    
    @IBInspectable var sectionInset = UIEdgeInsetsZero
    @IBInspectable var lineSpacing: CGFloat = 10
    @IBInspectable var interitemSpacing: CGFloat = 10
    @IBInspectable var columnCount: Int = 2
    
    private var cellInfo: [Int: CGFloat] = [:] // Key: 第几列; Value: 每列的底部y值
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        for i in 0 ..< self.columnCount {
            self.cellInfo[i] = self.sectionInset.top
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var temp = [UICollectionViewLayoutAttributes]()
        for section in 0 ..< self.collectionView!.numberOfSections() {
            for item in 0 ..< self.collectionView!.numberOfItemsInSection(section) {
                guard let attributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: item, inSection: section)) else {
                    continue
                }
                temp.append(attributes)
            }
        }
        return temp
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var minYColumn: Int = 0 // 底部Y最小的列
        var maxYColumn: Int = 0 // 底部Y最大的列
        var maxY: CGFloat = 0;
        for key in self.cellInfo.keys.sort() { // 需要对key进行排序，要不然第二个会出现在右边
            let value = self.cellInfo[key]!
            if value < self.cellInfo[minYColumn] {
                minYColumn = key
            }
            if value >= self.cellInfo[maxYColumn] {
                maxYColumn = key
                maxY = value
            }
        }
        
        if indexPath.item == 0 {
            // 开始一个新的Section
            minYColumn = 0
            for i in 0 ..< self.columnCount {
                self.cellInfo[i] = maxY + (indexPath.section == 0 ? sectionInset.top : sectionInset.bottom)
            }
        }
        
        let size = self.dataSource?.collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath) ?? CGSize.zero
        let x = self.sectionInset.left + (size.width + self.interitemSpacing) * CGFloat(minYColumn)
        let y = (indexPath.item < self.columnCount ? 0 : self.lineSpacing) + self.cellInfo[minYColumn]!
        
        self.cellInfo[minYColumn] = y + size.height
        
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        return attributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        let width = self.collectionView!.frame.width
        var maxY: CGFloat = 0
        for value in self.cellInfo.values {
            if (value > maxY) {
                maxY = value
            }
        }
        
        return CGSize(width: width, height: maxY + self.sectionInset.bottom)
    }
}
