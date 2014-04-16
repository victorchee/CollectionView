//
//  DynamicCollectionViewFlowLayout.m
//  DynamicCollectionView
//
//  Created by qihaijun on 14-4-16.
//  Copyright (c) 2014年 qihaijun. All rights reserved.
//

#import "DynamicCollectionViewFlowLayout.h"

@interface DynamicCollectionViewFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPaths;
@property (nonatomic, assign) CGFloat latestDelta;

@end

@implementation DynamicCollectionViewFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    if (!self.dynamicAnimator) {
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        self.itemSize = CGSizeMake(44, 44);
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        self.visibleIndexPaths = [NSMutableSet set];
    }
    CGRect originalRect = (CGRect){.origin=self.collectionView.bounds.origin, .size=self.collectionView.frame.size};
    CGRect visibleRect = CGRectInset(originalRect, -100, -100);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings) {
        BOOL currentlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behavior items] firstObject] indexPath]] != nil;
        return !currentlyVisible;
    }];
    
    NSArray *nolongerVisibleBehaviors = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:predicate];
    [nolongerVisibleBehaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPaths removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    
    predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentVisible = [self.visibleIndexPaths member:item.indexPath] != nil;
        return !currentVisible;
    }];
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:predicate];
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        behavior.length = 0;
        behavior.damping = 0.8f;
        behavior.frequency = 1.0f;
        
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat yDistanceFromTouch = fabsf(touchLocation.y - behavior.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabsf(touchLocation.x - behavior.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
            
            UICollectionViewLayoutAttributes *item = behavior.items.firstObject;
            CGPoint center = item.center;
            if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            } else {
                center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            }
            item.center = center;
        }
        
        [self.dynamicAnimator addBehavior:behavior];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    self.latestDelta = delta;
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *behavior, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - behavior.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - behavior.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = behavior.items.firstObject;
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta*scrollResistance);
        } else {
            center.y += MIN(delta, delta*scrollResistance);
        }
        item.center = center;
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}
@end
