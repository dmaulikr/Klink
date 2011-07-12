//
//  UIViewSlider.h
//  Klink V2
//
//  Created by Bobby Gill on 7/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIViewSlider;
@protocol UIViewSliderDelegate <NSObject>
@optional
- (UIView*)viewSlider:(UIViewSlider *)viewSlider cellForRowAtIndex:(int)index;
@end


@interface UIViewSlider : UIView <UIScrollViewDelegate> {
    UIScrollView* sv_scrollView;

    int m_itemHeight;
    int m_itemWidth;
    int m_itemSpacing;
    int m_numItemsToLoadOnScroll;
    NSMutableArray* m_viewList;
    NSFetchedResultsController *m_fetchedResultsController;
    
    id<UIViewSliderDelegate> delegate;
    
}

- (id) initWithFrame:(CGRect)frame Length:(int)length itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing;

- (void) hasNumberOfElements:(int)length itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing;

- (id) viewAt:(int)index;
- (void) datasetItemAddedAt:(int)index;
- (void) datasetHasChangedAt:(int)index;
- (void) render;
- (int) currentScrollIndex;
- (float) getContentWidth;
- (void) setInitialCapacity:(int)capacity;

@property (nonatomic,retain) UIScrollView* sv_scrollView;
@property int m_itemHeight;
@property int m_itemWidth;
@property int m_itemSpacing;
@property (nonatomic,retain) NSMutableArray* m_viewList;
@property int m_numItemsToLoadOnScroll;
@property (nonatomic, retain) NSFetchedResultsController *m_fetchedResultsController;
@property (nonatomic, retain) IBOutlet id<UIViewSliderDelegate> delegate;

@end



