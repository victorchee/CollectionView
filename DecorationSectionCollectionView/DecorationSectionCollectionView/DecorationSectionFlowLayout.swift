//
//  DecorationSectionFlowLayout.swift
//  DecorationSectionCollectionView
//
//  Created by Victor Chee on 2017/4/16.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

import UIKit

protocol CollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor
}

//class DecorationSectionFlowLayout: UICollectionViewFlowLayout {
//    override func prepare() {
//        super.prepare()
//        
//        register(DecorationSectionReusableView.self, forDecorationViewOfKind: String(describing: DecorationSectionReusableView.self))
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil}
//        var allAttributes = attributes
//        for attribute in attributes {
//            if attribute.representedElementCategory == .cell && attribute.frame.minX == sectionInset.left {
//                let decorationiAttributes = DecorationSectionFlowLayoutAttributes(forDecorationViewOfKind: String(describing: DecorationSectionReusableView.self), with: attribute.indexPath)
//                decorationiAttributes.frame = CGRect(x: 0, y: attribute.frame.minY - sectionInset.top, width: collectionViewContentSize.width, height: itemSize.height + minimumLineSpacing + sectionInset.top + sectionInset.bottom)
//                decorationiAttributes.zIndex = attribute.zIndex - 1
//                if let collectionView = self.collectionView, let delegate = collectionView.delegate as? CollectionViewDelegateFlowLayout {
//                    decorationiAttributes.backgroundColor = delegate.collectionView(collectionView, layout: self, backgroundColorForSectionAt: attribute.indexPath.section)
//                }
//                allAttributes.append(decorationiAttributes)
//            }
//        }
//        return attributes
//    }
//}

class DecorationSectionFlowLayout: UICollectionViewFlowLayout {
    private var decorationViewAttributes = [UICollectionViewLayoutAttributes]()
    
    override init() {
        super.init()
        register(DecorationSectionReusableView.self, forDecorationViewOfKind: String(describing: DecorationSectionReusableView.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(DecorationSectionReusableView.self, forDecorationViewOfKind: String(describing: DecorationSectionReusableView.self))
    }
    
    override func prepare() {
        super.prepare()

        guard let numberOfSections = collectionView?.numberOfSections, let delegate = collectionView?.delegate as? CollectionViewDelegateFlowLayout else {
            return
        }
        
        decorationViewAttributes.removeAll()
        
        for section in 0..<numberOfSections {
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section),
                numberOfItems > 0,
                let firstItem = self.layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                let lastItem = self.layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                    continue
            }
            var sectionInset = self.sectionInset
            if let inset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {
                sectionInset = inset
            }
            
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x = 0
            sectionFrame.origin.y -= sectionInset.top
            
            if scrollDirection == .horizontal {
                sectionFrame.size.width += sectionInset.left + sectionInset.right
                sectionFrame.size.height += collectionView!.frame.height
            } else {
                sectionFrame.size.width += collectionView!.frame.width
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            }
            
            let attribute = DecorationSectionFlowLayoutAttributes(forDecorationViewOfKind: String(describing: DecorationSectionReusableView.self), with: IndexPath(item: 0, section: section))
            attribute.frame = sectionFrame
            attribute.zIndex = -1
            attribute.backgroundColor = delegate.collectionView(self.collectionView!, layout: self, backgroundColorForSectionAt: section)
            
            decorationViewAttributes.append(attribute)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        
        attributes?.append(contentsOf: decorationViewAttributes.filter {
            return rect.intersects($0.frame)
        })
        
        return attributes
    }
}

class DecorationSectionFlowLayoutAttributes: UICollectionViewLayoutAttributes {
    var backgroundColor = UIColor.clear
}

class DecorationSectionReusableView: UICollectionReusableView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? DecorationSectionFlowLayoutAttributes {
            self.backgroundColor = attributes.backgroundColor
        }
    }
}
