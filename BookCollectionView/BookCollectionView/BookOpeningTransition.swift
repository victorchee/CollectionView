//
//  BookOpeningTransition.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookOpeningTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var transforms = [UICollectionViewCell: CATransform3D]()
    var toViewBackgroundColor: UIColor?
    var isPush = true
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPush ? 1 : 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        if isPush {
            guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? BookStoreViewController, let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? BookViewController else {
                return
            }
            container.addSubview(toViewController.view)
            
            setStartPositionForPush(fromViewController, toViewController: toViewController)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                self.setEndPositionForPush(fromViewController, toViewController: toViewController)
                }, completion: { (finished) -> Void in
                    self.cleanupPush(fromViewController, toViewController: toViewController)
                    transitionContext.completeTransition(finished)
            })
        } else {
            // pop
            guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? BookViewController, let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? BookStoreViewController else {
                return
            }
            container.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            setStartPositionForPop(fromViewController, toViewController: toViewController)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                self.setEndPositionForPop(fromViewController, toViewController: toViewController)
                }, completion: { (finished) -> Void in
                    self.cleanupPop(fromViewController, toViewController: toViewController)
                    transitionContext.completeTransition(finished)
            })
        }
    }
    
    fileprivate func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000.0
        return transform
    }
    
    fileprivate func closePageCell(_ cell: BookPageCell) {
        var transform = makePerspectiveTransform()
        if cell.layer.anchorPoint.x == 0 {
            // 页面在书脊右侧
            transform = CATransform3DRotate(transform, 0, 0, 1, 0)
            transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2.0, 0, 0)
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        } else {
            // 页面在书脊左侧
            transform = CATransform3DRotate(transform, CGFloat(-M_PI), 0, 1, 0)
            transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2.0, 0, 0)
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        }
        cell.layer.transform = transform
    }
    
    // MARK: - PUSH
    fileprivate func setStartPositionForPush(_ fromViewController: BookStoreViewController, toViewController: BookViewController) {
        toViewBackgroundColor = fromViewController.collectionView?.backgroundColor
        toViewController.collectionView?.backgroundColor = nil
        
        fromViewController.selectedCell?.alpha = 0
        
        for cell in toViewController.collectionView?.visibleCells as! [BookPageCell] {
            transforms[cell] = cell.layer.transform
            closePageCell(cell)
            cell.updateShadowLayer()
            
            if let indexPath = toViewController.collectionView?.indexPath(for: cell), indexPath.item == 0 {
                cell.shadowLayer.opacity = 0
            }
        }
    }
    
    fileprivate func setEndPositionForPush(_ fromViewController: BookStoreViewController, toViewController: BookViewController) {
        for cell in fromViewController.collectionView?.visibleCells as! [BookCoverCell] {
            cell.alpha = 0
        }
        for cell in toViewController.collectionView?.visibleCells as! [BookPageCell] {
            cell.layer.transform = transforms[cell]!
            cell.updateShadowLayer(animated: true)
        }
    }
    
    fileprivate func cleanupPush(_ fromViewController: BookStoreViewController, toViewController: BookViewController) {
        toViewController.collectionView?.backgroundColor = toViewBackgroundColor
        toViewController.recognizer = fromViewController.recognizer
    }
    
    // MARK: - POP
    fileprivate func setStartPositionForPop(_ fromViewController: BookViewController, toViewController: BookStoreViewController) {
        toViewBackgroundColor = fromViewController.collectionView?.backgroundColor
        fromViewController.collectionView?.backgroundColor = nil
    }
    
    fileprivate func setEndPositionForPop(_ fromViewController: BookViewController, toViewController: BookStoreViewController) {
        let coverCell = toViewController.selectedCell
        for cell in toViewController.collectionView!.visibleCells as! [BookCoverCell] {
            if cell != coverCell {
                cell.alpha = 1
            }
        }
        for cell in fromViewController.collectionView!.visibleCells as! [BookPageCell] {
            closePageCell(cell)
        }
    }
    
    fileprivate func cleanupPop(_ fromViewController: BookViewController, toViewController: BookStoreViewController) {
        fromViewController.collectionView?.backgroundColor = toViewBackgroundColor
        toViewController.selectedCell?.alpha = 1
        toViewController.recognizer = fromViewController.recognizer
    }
}
