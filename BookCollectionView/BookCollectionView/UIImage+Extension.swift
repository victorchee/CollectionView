//
//  UIImage+Extension.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithRoundedCornersSize(cornerRadius: CGFloat, corners: UIRectCorner) -> UIImage {
        UIGraphicsBeginImageContext(size)
        UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).addClip()
        drawInRect(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageByScalingAndCroppingForSize(targetSize: CGSize) -> UIImage {
        var scaledSize = CGSize.zero
        var thumbnailPoint = CGPoint.zero
        
        if !CGSizeEqualToSize(size, targetSize) {
            let widthFactor = targetSize.width / size.width
            let heightFactor = targetSize.height / size.height
            
            let scaleFactor: CGFloat = widthFactor > heightFactor ? widthFactor : heightFactor
            scaledSize = CGSizeMake(size.width * scaleFactor, size.height * scaleFactor)
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetSize.height - scaledSize.height) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetSize.width - scaledSize.height) * 0.5
            }
        }
        
        UIGraphicsBeginImageContext(targetSize)
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: scaledSize)
        self.drawInRect(thumbnailRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
