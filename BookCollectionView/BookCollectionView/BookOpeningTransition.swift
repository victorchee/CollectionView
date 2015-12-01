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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return isPush ? 1 : 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        if isPush {
            guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? BookStoreViewController, let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? BookViewController else {
                return
            }
            container?.addSubview(toViewController.view)
            
            setStartPositionForPush(fromViewController, toViewController: toViewController)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                self.setEndPositionForPush(fromViewController, toViewController: toViewController)
                }, completion: { (finished) -> Void in
                    self.cleanupPush(fromViewController, toViewController: toViewController)
                    transitionContext.completeTransition(finished)
            })
        } else {
            // pop
            guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? BookViewController, let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? BookStoreViewController else {
                return
            }
            container?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
            
            setStartPositionForPop(fromViewController, toViewController: toViewController)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                self.setEndPositionForPop(fromViewController, toViewController: toViewController)
                }, completion: { (finished) -> Void in
                    self.cleanupPop(fromViewController, toViewController: toViewController)
                    transitionContext.completeTransition(finished)
            })
        }
    }
    
    private func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000.0
        return transform
    }
    
    private func closePageCell(cell: BookPageCell) {
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
    private func setStartPositionForPush(fromViewController: BookStoreViewController, toViewController: BookViewController) {
        toViewBackgroundColor = fromViewController.collectionView?.backgroundColor
        toViewController.collectionView?.backgroundColor = nil
        
        fromViewController.selectedCell?.alpha = 0
        
        for cell in toViewController.collectionView?.visibleCells() as! [BookPageCell] {
            transforms[cell] = cell.layer.transform
            closePageCell(cell)
            cell.updateShadowLayer()
            
            if let indexPath = toViewController.collectionView?.indexPathForCell(cell) where indexPath.item == 0 {
                cell.shadowLayer.opacity = 0
            }
        }
    }
    
    private func setEndPositionForPush(fromViewController: BookStoreViewController, toViewController: BookViewController) {
        for cell in fromViewController.collectionView?.visibleCells() as! [BookCoverCell] {
            cell.alpha = 0
        }
        for cell in toViewController.collectionView?.visibleCells() as! [BookPageCell] {
            cell.layer.transform = transforms[cell]!
            cell.updateShadowLayer(animated: true)
        }
    }
    
    private func cleanupPush(fromViewController: BookStoreViewController, toViewController: BookViewController) {
        toViewController.collectionView?.backgroundColor = toViewBackgroundColor
        toViewController.recognizer = fromViewController.recognizer
    }
    
    // MARK: - POP
    private func setStartPositionForPop(fromViewController: BookViewController, toViewController: BookStoreViewController) {
        toViewBackgroundColor = fromViewController.collectionView?.backgroundColor
        fromViewController.collectionView?.backgroundColor = nil
    }
    
    private func setEndPositionForPop(fromViewController: BookViewController, toViewController: BookStoreViewController) {
        let coverCell = toViewController.selectedCell
        for cell in toViewController.collectionView!.visibleCells() as! [BookCoverCell] {
            if cell != coverCell {
                cell.alpha = 1
            }
        }
        for cell in fromViewController.collectionView!.visibleCells() as! [BookPageCell] {
            closePageCell(cell)
        }
    }
    
    private func cleanupPop(fromViewController: BookViewController, toViewController: BookStoreViewController) {
        fromViewController.collectionView?.backgroundColor = toViewBackgroundColor
        toViewController.selectedCell?.alpha = 1
        toViewController.recognizer = fromViewController.recognizer
    }
}
