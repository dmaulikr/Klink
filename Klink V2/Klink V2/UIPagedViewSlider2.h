//
//  UIPagedViewSlider2.h
//  Klink V2
//
//  Created by Bobby Gill on 8/2/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
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
    // Views
	UIKlinkScrollView   *m_pagingScrollView;
    // Paging
	NSMutableSet        *m_visiblePages;
    NSMutableSet        *m_recycledPages;
	int                 m_currentPageIndex;
	int                 m_pageIndexBeforeRotation;
    
    // Misc
	BOOL                m_performingLayout;
	BOOL                m_rotating;

    id<UIPagedViewSlider2Delegate>  m_delegate;
    
    //
    int                 m_itemWidth;
    int                 m_itemWidth_landscape;
    int                 m_itemHeight;
    int                 m_itemHeight_landscape;
    int                 m_itemSpacing;
    
}

@property (nonatomic,retain)    UIKlinkScrollView*   pagingScrollView;
@property (nonatomic,retain)    NSMutableSet*   visiblePages;
@property (nonatomic,retain)    NSMutableSet*   recycledPages;
@property (nonatomic,retain)    IBOutlet id<UIPagedViewSlider2Delegate>  delegate;
@property                       int                             currentPageIndex;

-(id)       initWithWidth:      (int)   width_portrait
            withHeight:         (int)   height_portrait
            withWidthLandscape: (int)   width_landscape
            withHeightLandscape:(int)   height_landscape
            withSpacing:        (int)   spacing;

// Layout
- (void)    performLayout;
- (void)    onNewItemInsertedAt:(int)index;

// Paging
- (void)                tilePages;
- (UIPagedViewItem *)   dequeueRecycledPage;
- (void)                configurePage:              (UIPagedViewItem*)  page forIndex:(NSUInteger)index;
- (void)                didStartViewingPageAtIndex: (NSUInteger)        index;

// Properties
- (void)    setInitialPageIndex:        (NSUInteger)    index;


//Frames
- (CGSize)  contentSizeForPagingScrollView;
- (CGRect)  frameForPageAtIndex:            (NSUInteger)    index;
- (CGPoint) contentOffsetForPageAtIndex:    (NSUInteger)    index;
- (CGRect)  frameForPagingScrollView;

//Memory
- (void)    didReceiveMemoryWarning;
- (BOOL)    isDisplayingPageForIndex:       (NSUInteger)    index;


//Navigation
- (void)    updateNavigation;


@end
