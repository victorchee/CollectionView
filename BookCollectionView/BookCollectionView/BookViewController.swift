//
//  BookViewController.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookViewController: UICollectionViewController {
    var book: Book? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSrouce
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let book = book else {
            return 0
        }
        return book.numberOfPages() + 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookPageCell", forIndexPath: indexPath) as! BookPageCell
        if indexPath.item == 0 {
            // cover
            cell.label.text = nil
            cell.image = book?.coverImage()
        } else {
            // page
            cell.label.text = "\(indexPath.item)"
            cell.image = book?.pageImage(indexPath.item - 1)
        }
        return cell
    }
}
