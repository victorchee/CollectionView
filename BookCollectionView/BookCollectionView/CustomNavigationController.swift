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
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            if let from = fromVC as? BookStoreViewController {
                return from.animationControllerForPresentController(toVC)
            }
        } else if operation == .pop {
            if let to = toVC as? BookStoreViewController {
                return to.animationControllerForDismissController(to)
            }
        }
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animationController =  animationController as? BookOpeningTransition else {
            return nil
        }
        return animationController.interactionController
    }
}
