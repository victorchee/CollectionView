//
//  ViewController.swift
//  PaginationCollectionView
//
//  Created by Victor Chee on 2018/5/11.
//  Copyright © 2018年 VictorChee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var indexOfCellBeforeDragging = 0
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        cell.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0, green: CGFloat(arc4random_uniform(255)) / 255.0, blue: CGFloat(arc4random_uniform(255)) / 255.0, alpha: 1)
        return cell
    }
}

//extension ViewController: UIScrollViewDelegate {
//    // PaginEnabled设置为NO
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let x = targetContentOffset.pointee.x
//        
//        let collectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
////        let leftInset = collectionViewFlowLayout.sectionInset.left
//        let pageWidth = collectionViewFlowLayout.itemSize.width + collectionViewFlowLayout.minimumLineSpacing
//        
//        let moveWidth = x - pageWidth * CGFloat(selectedIndex)
//        // 当位移的绝对值大于分页宽度的一半时，滚动到相邻页
//        if moveWidth < -pageWidth * 0.5 {
//            selectedIndex -= 1
//        } else if moveWidth > pageWidth * 0.5 {
//            selectedIndex += 1
//        }
//        
//        if abs(velocity.x) >= 2 {
//            // 滚动到目标位置
//            targetContentOffset.pointee.x = pageWidth * CGFloat(selectedIndex)
//        } else {
//            // 回退到滚动之前位置
//            targetContentOffset.pointee.x = scrollView.contentOffset.x
//            scrollView.setContentOffset(CGPoint(x: pageWidth * CGFloat(selectedIndex), y: 0), animated: true)
//        }
//    }
//}

//extension ViewController: UIScrollViewDelegate {
//    private func indexOfMajorCell() -> Int {
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
//        let proportionalOffset = (collectionView.contentOffset.x-layout.sectionInset.left) / itemWidth
//        return Int(round(proportionalOffset))
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        indexOfCellBeforeDragging = indexOfMajorCell()
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        // Stop scrollView sliding:
//        targetContentOffset.pointee = scrollView.contentOffset
//
//        // calculate where scrollView should snap to:
//        let indexOfMajorCell = self.indexOfMajorCell()
//
//        // calculate conditions:
//        let dataSourceCount = collectionView(collectionView!, numberOfItemsInSection: 0)
//        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
//        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < dataSourceCount && velocity.x > swipeVelocityThreshold
//        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
//        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
//        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
//
//        if didUseSwipeToSkipCell {
//
//            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
//            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//            let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
//            let toValue = itemWidth * CGFloat(snapToIndex) + layout.sectionInset.left
//
//            // Damping equal 1 => no oscillations => decay animation:
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
//                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
//                scrollView.layoutIfNeeded()
//            }, completion: nil)
//
//        } else {
//            // This is a much better to way to scroll to a cell:
//            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//    }
//}

