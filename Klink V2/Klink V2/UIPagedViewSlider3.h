//
//  UIPagedViewSlider3.h
//  Klink V2
//
//  Created by Bobby Gill on 9/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIKlinkScrollView.h"


@class UIPagedViewItem;
@class UIPagedViewSlider2;
@protocol UIPagedViewSlider2Delegate <NSObject>
@optional

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index;

- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:  (int)                   index 
             withFrame:          (CGRect)                frame;


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining: (int)                   numberOfCellsToEnd;


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame;



- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider;




@end

@interface UIPagedViewSlider2 : UIView <UIScrollViewDelegate> {
    UIKlinkScrollView   *m_pagingScrollView;
    NSMutableSet        *m_visiblePages;
    NSMutableSet        *m_recyclePages;
    
    BOOL                m_isHorizontalOrientation;
    int                 m_pageIndex;
    id<UIPagedViewSlider2Delegate> m_delegate;
    int                 m_itemWidth;
    int                 m_itemWidth_landscape;
    int                 m_itemHeight;
    int                 m_itemHeight_landscape;
    int                 m_itemSpacing;
}

@property (nonatomic,retain)    UIKlinkScrollView   *pagingScrollView;
@property int pageIndex;
@property (nonatomic,retain)    NSMutableSet  *visiblePages;
@property (nonatomic,retain)    NSMutableSet  *recycledPages;
@property (nonatomic,retain)    id<UIPagedViewSlider2Delegate>  delegate;

-(id)       initWithWidth:      (int)   width_portrait
               withHeight:      (int)   height_portrait
       withWidthLandscape:      (int)   width_landscape
      withHeightLandscape:      (int)   height_landscape
              withSpacing:      (int)   spacing;

- (id)      initWithWidth:          (int)   width
               withHeight:          (int)   height
              withSpacing:          (int)   spacing
             isHorizontal:          (BOOL)  isHorizontal;

- (void)        animateScrollView: (NSTimer*) timerParam;
- (void)        onNewItemInsertedAt:(int)index;
- (void)        goTo:               (int)index;
- (void)        goTo:               (int)index withAnimation:(BOOL)withAnimation;
- (void)        reset;
- (NSArray*)    getVisibleViews;
- (void)        render;
@end
