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
    
    @IBInspectable var sectionInset = UIEdgeInsets.zero
    @IBInspectable var lineSpacing: CGFloat = 10
    @IBInspectable var interitemSpacing: CGFloat = 10
    @IBInspectable var columnCount: Int = 2
    
    private var cellInfo: [Int: CGFloat] = [:] // Key: 第几列; Value: 每列的底部y值
    
    override var collectionViewContentSize: CGSize {
        let width = self.collectionView!.frame.width
        var maxY: CGFloat = 0
        for value in self.cellInfo.values {
            if (value > maxY) {
                maxY = value
            }
        }
        
        return CGSize(width: width, height: maxY + self.sectionInset.bottom)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        
        for i in 0 ..< self.columnCount {
            self.cellInfo[i] = self.sectionInset.top
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var temp = [UICollectionViewLayoutAttributes]()
        for section in 0 ..< self.collectionView!.numberOfSections {
            for item in 0 ..< self.collectionView!.numberOfItems(inSection: section) {
                guard let attributes = layoutAttributesForItem(at: NSIndexPath(item: item, section: section) as IndexPath) else {
                    continue
                }
                temp.append(attributes)
            }
        }
        return temp
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var minYColumn: Int = 0 // 底部Y最小的列
        var maxYColumn: Int = 0 // 底部Y最大的列
        var maxY: CGFloat = 0;
        for key in self.cellInfo.keys.sorted() { // 需要对key进行排序，要不然第二个会出现在右边
            let value = self.cellInfo[key]!
            if value < self.cellInfo[minYColumn]! {
                minYColumn = key
            }
            if value >= self.cellInfo[maxYColumn]! {
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
        
        let size = self.dataSource?.collectionView(collectionView: self.collectionView!, layout: self, sizeForItemAtIndexPath: indexPath as NSIndexPath) ?? CGSize.zero
        let x = self.sectionInset.left + (size.width + self.interitemSpacing) * CGFloat(minYColumn)
        let y = (indexPath.item < self.columnCount ? 0 : self.lineSpacing) + self.cellInfo[minYColumn]!
        
        self.cellInfo[minYColumn] = y + size.height
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
        
        return attributes
    }
}
