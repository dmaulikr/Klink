//
//  UIPagedViewSlider.h
//  Klink V2
//
//  Created by Bobby Gill on 7/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewSlider.h"

@interface UIPagedViewSlider : UIView  <UIScrollViewDelegate>{
    UIScrollView* sv_slider;
    NSMutableArray* m_viewList;
    
    int m_itemHeight;
    int m_itemSpacing;
    int m_itemWidth;
    int m_lastScrollPosition;
    int m_numItemsToLoadOnScroll;
    id<UIViewSliderDelegate> delegate;
}

@property (nonatomic,retain) UIScrollView* sv_slider;
@property (nonatomic,retain) NSMutableArray* m_viewList;
@property int m_itemHeight;
@property int m_itemSpacing;
@property int m_itemWidth;
@property int m_lastScrollPosition;
@property int m_numItemsToLoadOnScroll;
@property (nonatomic,retain) IBOutlet id<UIViewSliderDelegate> delegate;
- (id) initWith:(int)itemWidth itemHeight:(int)itemHeight itemSpacing:(int)itemSpacing;
- (void) set:(NSArray*)items;
- (void) datasetItemAddedAt:(int)index;
- (void) item:(id)object insertedAt:(int)index;
- (void) item:(id)object atIndex:(int)index movedTo:(int)newIndex;
@end
