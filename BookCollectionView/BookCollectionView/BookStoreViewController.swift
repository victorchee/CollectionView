//
//  BookStoreViewController.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookStoreViewController: UICollectionViewController {
    var transition: BookOpeningTransition?
    var interactionController: UIPercentDrivenInteractiveTransition?
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    var books: [Book]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var selectedCell: BookCoverCell? {
        guard let indexPath = collectionView?.indexPathForItemAtPoint(CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width / 2.0, y: collectionView!.bounds.height / 2.0)), let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BookCoverCell else {
            return nil
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedStore.loadBooks("Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            if sender.scale >= 1 {
                if sender.view == collectionView {
                    let book = selectedCell?.book
                    openBook(book!)
                }
            } else {
                navigationController?.popViewControllerAnimated(true)
            }
            
        case .Changed:
            if transition!.isPush {
                let progress = min(max(abs((sender.scale - 1)) / 5, 0), 1)
                interactionController?.updateInteractiveTransition(progress)
            } else {
                let progress = min(max(abs((1 - sender.scale)), 0), 1)
                interactionController?.updateInteractiveTransition(progress)
            }
        case .Ended:
            interactionController?.finishInteractiveTransition()
            interactionController = nil
        default:
            break
        }
    }
    
    func openBook(book: Book) {
        let bookViewController = storyboard?.instantiateViewControllerWithIdentifier("BookViewController") as! BookViewController
        bookViewController.book = selectedCell?.book
        bookViewController.view.snapshotViewAfterScreenUpdates(true)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.navigationController?.pushViewController(bookViewController, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCoverCell", forIndexPath: indexPath) as! BookCoverCell
        cell.book = books?[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let book = books?[indexPath.row] else {
            return
        }
        openBook(book)
    }
}

extension BookStoreViewController {
    func animationControllerForPresentController(viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = true
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
    
    func animationControllerForDismissController(viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}
