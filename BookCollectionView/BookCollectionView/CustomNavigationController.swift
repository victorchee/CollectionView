//
//  CustomNavigationController.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Push {
            if let from = fromVC as? BookStoreViewController {
                return from.animationControllerForPresentController(toVC)
            }
        } else if operation == .Pop {
            if let to = toVC as? BookStoreViewController {
                return to.animationControllerForDismissController(to)
            }
        }
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animationController =  animationController as? BookOpeningTransition else {
            return nil
        }
        return animationController.interactionController
    }
}
