//
//  BookStore.swift
//  BookCollectionView
//
//  Created by qihaijun on 11/30/15.
//  Copyright © 2015 VictorChee. All rights reserved.
//

import UIKit

class BookStore {
    static let sharedStore = BookStore()
    
    func loadBooks(plist: String) -> [Book] {
        var books = [Book]()
        
        guard let path = NSBundle.mainBundle().pathForResource(plist, ofType: "plist") else {
            return books
        }
        
        guard let array = NSArray(contentsOfFile: path) as? [NSDictionary] else {
            return books
        }
        
        for dict in array {
            let book = Book(dict: dict)
            books.append(book)
        }
        
        return books
    }
}
