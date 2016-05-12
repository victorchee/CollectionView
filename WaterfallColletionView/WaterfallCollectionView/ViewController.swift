//
//  ViewController.swift
//  WaterfallCollectionView
//
//  Created by Victor Chee on 16/5/12.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, WaterfallFlowLayoutDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let layout = self.collectionView?.collectionViewLayout as? WaterfallFlowLayout {
            layout.dataSource = self
            layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
            layout.columnCount = 5
            layout.lineSpacing = 10
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - WaterfallFlowLayoutDataSource
    func collectionView(collectionView: UICollectionView, layout: WaterfallFlowLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.interitemSpacing * CGFloat(layout.columnCount - 1)) / CGFloat(layout.columnCount)
        let height = CGFloat(sizeForItemAtIndexPath.item * 10 + 20)
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        cell.label.text = "\(indexPath.section) - \(indexPath.item)"
        return cell;
    }
}

