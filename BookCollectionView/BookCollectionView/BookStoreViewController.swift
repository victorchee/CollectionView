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
        self.transition = transition
        return transition
    }
    
    func animationControllerForDismissController(viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        self.transition = transition
        return transition
    }
}
