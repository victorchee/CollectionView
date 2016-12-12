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
        guard let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView!.contentOffset.x + collectionView!.bounds.width / 2.0, y: collectionView!.bounds.height / 2.0)), let cell = collectionView?.cellForItem(at: indexPath) as? BookCoverCell else {
            return nil
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedStore.loadBooks("Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: #selector(BookStoreViewController.handlePinch(_:)))
    }
    
    func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            if sender.scale >= 1 {
                if sender.view == collectionView {
                    let book = selectedCell?.book
                    openBook(book!)
                }
            } else {
                navigationController?.popViewController(animated: true)
            }
            
        case .changed:
            if transition!.isPush {
                let progress = min(max(abs((sender.scale - 1)) / 5, 0), 1)
                interactionController?.update(progress)
            } else {
                let progress = min(max(abs((1 - sender.scale)), 0), 1)
                interactionController?.update(progress)
            }
        case .ended:
            interactionController?.finish()
            interactionController = nil
        default:
            break
        }
    }
    
    func openBook(_ book: Book) {
        let bookViewController = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        bookViewController.book = selectedCell?.book
        bookViewController.view.snapshotView(afterScreenUpdates: true)
        DispatchQueue.main.async { () -> Void in
            self.navigationController?.pushViewController(bookViewController, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath) as! BookCoverCell
        cell.book = books?[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let book = books?[indexPath.row] else {
            return
        }
        openBook(book)
    }
}

extension BookStoreViewController {
    func animationControllerForPresentController(_ viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = true
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
    
    func animationControllerForDismissController(_ viewController: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}
