//
//  Book.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class Book {
    var dict: NSDictionary?
    
    convenience init(dict: NSDictionary) {
        self.init()
        self.dict = dict
    }
    
    func coverImage() -> UIImage? {
        guard let cover = dict?["cover"] as? String  else {
            return nil
        }
        return UIImage(named: cover)
    }
    
    func pageImage(_ index: Int) -> UIImage? {
        guard let pages = dict?["pages"] as? [String] else {
            return nil
        }
        return UIImage(named: pages[index])
    }
    
    func numberOfPages() -> Int {
        guard let pages = dict?["pages"] as? [String] else {
            return 0
        }
        return pages.count
    }
}
