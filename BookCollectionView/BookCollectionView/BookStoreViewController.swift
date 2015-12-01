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
    
    var selectedCell: BookCoverCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedStore.loadBooks("Books")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenBook" {
            guard let cell = sender as? BookCoverCell else {
                return
            }
            selectedCell = cell
            guard let indexPath = collectionView?.indexPathForCell(cell) else {
                return
            }
            guard let book = books?[indexPath.item] else {
                return
            }
            guard let bookViewController = segue.destinationViewController as? BookViewController else {
                return
            }
            bookViewController.book = book
            print("open \(indexPath.item + 1)th book")
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
}

extension BookStoreViewController {
    func animationControllerForPresentController(viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = true
        self.transition = transition
        return transition
    }
}
