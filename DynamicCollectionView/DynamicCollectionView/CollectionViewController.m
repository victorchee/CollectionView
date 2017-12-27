//
//  CollectionViewController.m
//  DynamicCollectionView
//
//  Created by qihaijun on 14-4-16.
//  Copyright (c) 2014年 qihaijun. All rights reserved.
//

#import "CollectionViewController.h"
#import "AttachmentFlowLayout.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

#pragma mark - UICollectionViewController DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCellIdentifier" forIndexPath:indexPath];
    return cell;
}

@end
