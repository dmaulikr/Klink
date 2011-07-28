//
//  UIPagedViewSlider.h
//  Klink V2
//
//  Created by Bobby Gill on 7/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewSlider.h"
#import "UIKlinkScrollView.h"

@class UIPagedViewSlider;
@protocol UIPagedViewSliderDelegate <NSObject>
@optional

- (void)viewSlider:(UIPagedViewSlider*)viewSlider selectIndex:(int)index;
- (UIView*)viewSlider:(UIPagedViewSlider *)viewSlider cellForRowAtIndex:(int)index sliderIsHorizontal:(BOOL)isHorizontalOrientation;
- (void)viewSlider:(UIPagedViewSlider*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd;



@end


@interface UIPagedViewSlider : UIView  <UIScrollViewDelegate>{
    UIKlinkScrollView* m_slider;
    NSMutableArray* m_viewList;
    
    int m_itemHeight;
    int m_itemSpacing;
    int m_itemWidth;
    int m_lastScrollPosition;
    int m_numItemsToLoadOnScroll;
    id<UIPagedViewSliderDelegate> m_delegate;
    BOOL m_isHorizontalOrientation;
}

@property (nonatomic,retain) UIKlinkScrollView* slider;
@property (nonatomic,retain) NSMutableArray* viewList;
@property int itemHeight;
@property int itemSpacing;
@property int itemWidth;
@property int lastScrollPosition;
@property int numItemsToLoadOnScroll;
@property BOOL isHorizontalOrientation;
@property (nonatomic,retain) IBOutlet id<UIPagedViewSliderDelegate> delegate;

- (void)setContentOffsetTo:(int)index;
- (int)getContentOffsetIndex;
- (id) initWith:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing;
- (id) initWith:(BOOL)isHorizontalOrientation  itemWidth:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing;
- (void) resetSliderWithItems:(NSArray*)items;
- (void) item:(id)object insertedAt:(int)index;
- (void) item:(id)object atIndex:(int)index movedTo:(int)newIndex;
@end
