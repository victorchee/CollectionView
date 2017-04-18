//
//  DecorationSectionFlowLayout.swift
//  DecorationSectionCollectionView
//
//  Created by Victor Chee on 2017/4/16.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

import UIKit

public protocol CollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, backgroundColorForSectionAt section: Int) -> UIColor
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumSectionSpacingForSectionAt section: Int) -> CGFloat
}

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
                var firstItem = self.layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                var lastItem = self.layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                    continue
            }
            var hasHeader = false
            if let header = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
                firstItem = header
                hasHeader = true
            }
            var hasFooter = false
            if let footer = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: section)) {
                lastItem = footer
                hasFooter = true
            }
            var sectionInset = self.sectionInset
            if let inset = delegate.collectionView?(self.collectionView!, layout: self, insetForSectionAt: section) {
                sectionInset = inset
            }
            
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            
            if scrollDirection == .horizontal {
                sectionFrame.origin.x -= hasHeader ? 0 : sectionInset.left
                sectionFrame.origin.y = 0
                sectionFrame.size.width += (hasHeader ? 0 : sectionInset.left) + (hasFooter ? 0 : sectionInset.right)
                sectionFrame.size.height = collectionView!.frame.height
            } else {
                sectionFrame.origin.x = 0
                sectionFrame.origin.y -= hasHeader ? 0 : sectionInset.top
                sectionFrame.size.width = collectionView!.frame.width
                sectionFrame.size.height += (hasHeader ? 0 : sectionInset.top) + (hasFooter ? 0 : sectionInset.bottom)
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
