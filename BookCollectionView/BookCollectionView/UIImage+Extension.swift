//
//  UIImage+Extension.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithRoundedCornersSize(_ cornerRadius: CGFloat, corners: UIRectCorner) -> UIImage {
        UIGraphicsBeginImageContext(size)
        UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).addClip()
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func imageByScalingAndCroppingForSize(_ targetSize: CGSize) -> UIImage {
        var scaledSize = targetSize
        var thumbnailPoint = CGPoint.zero
        
        if size.equalTo(targetSize) == false {
            let widthFactor = targetSize.width / size.width
            let heightFactor = targetSize.height / size.height
            
            let scaleFactor = max(widthFactor, heightFactor)
            scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
            
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetSize.height - scaledSize.height) * 0.5
            } else if widthFactor < heightFactor {
                thumbnailPoint.x = (targetSize.width - scaledSize.width) * 0.5
            }
        }
        
        UIGraphicsBeginImageContext(targetSize)
        
        let thumbnailRect = CGRect(origin: thumbnailPoint, size: scaledSize)
        self.draw(in: thumbnailRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
