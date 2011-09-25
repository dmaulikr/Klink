//
//  UIPagedViewSlider3.m
//  Klink V2
//
//  Created by Bobby Gill on 9/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPagedViewSlider3.h"
#import "AttributeNames.h"
#import "UIPagedViewItem.h"
@implementation UIPagedViewSlider2
@synthesize pageIndex = m_pageIndex;
@synthesize delegate = m_delegate;
@synthesize visiblePages = m_visiblePages;
@synthesize recycledPages = m_recyclePages;
@synthesize pagingScrollView=m_pagingScrollView;



#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.bounds;
    return frame;
}

- (CGRect)  frameForPageAtIndex: (NSUInteger)    index {
    if (m_isHorizontalOrientation) {
        return CGRectMake((m_itemWidth + m_itemSpacing) * index, 0, m_itemWidth,  m_itemHeight);
    }
    else {
        return CGRectMake(0,(m_itemHeight+m_itemSpacing)*index, m_itemWidth, m_itemHeight);
    }
}


- (CGSize)  contentSizeForPagingScrollView {
    int count = [self.delegate itemCountFor:self];
    if (m_isHorizontalOrientation) {
        return CGSizeMake((m_itemWidth+m_itemSpacing)*count,m_itemHeight);
    }
    else {
        return CGSizeMake(m_itemWidth,(m_itemHeight + m_itemSpacing)*count);
    }
    
    
}

- (CGPoint) contentOffsetForPageAtIndex:    (NSUInteger)    index {
    if (m_isHorizontalOrientation) {
        return CGPointMake((m_itemWidth+m_itemSpacing) * index, 0);
    }
    else {
        return CGPointMake(0,(m_itemHeight+m_itemSpacing)*index);
    }
    
    
}

- (int)  indexForContentOffset:(CGPoint)point {
    int index = 0;
    if (m_isHorizontalOrientation) {
        index =floor(point.x / (m_itemWidth + m_itemSpacing));
    }
    else {
        index = floor(point.y/ (m_itemHeight + m_itemSpacing));
    }
    return index;
}

-(id)       initWithWidth:          (int)   width_portrait
               withHeight:          (int)   height_portrait
       withWidthLandscape:          (int)   width_landscape
      withHeightLandscape:          (int)   height_landscape
              withSpacing:          (int)   spacing {
    
    m_itemHeight = height_portrait;
    m_itemWidth = width_portrait;
    m_itemSpacing = spacing;
    m_itemWidth_landscape = width_landscape;
    m_itemHeight_landscape = height_landscape;
    [self init];
    
    if (self.delegate != nil) {
        int count = [self.delegate itemCountFor:self];
        for (int i = 0; i < count; i++) {
            UIPagedViewItem* page = [[UIPagedViewItem alloc]init];
            [self.recycledPages addObject:page];
            [page release];
        }
    }
    return self;
}


- (id)      initWithWidth:          (int)   width
               withHeight:          (int)   height
              withSpacing:          (int)   spacing
             isHorizontal:          (BOOL)  isHorizontal {
    
    m_itemWidth = width;
    m_itemHeight= height;
    m_itemSpacing = spacing;
    m_isHorizontalOrientation   = isHorizontal;
    [self init];
    
    if (self.delegate != nil) {
        int count = [self.delegate itemCountFor:self];
        for (int i = 0; i < count; i++) {
            UIPagedViewItem* page = [[UIPagedViewItem alloc]init];
            page.index = -1;
            page.userInteractionEnabled = YES;
            [self.recycledPages addObject:page];
            [page release];
        }
    }
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    self.pageIndex = 0;
    [self render];
    return self;
}

- (id)    init {
    
    //    self = [super init];
    
    if (self != nil) {
        // Setup paging scrolling view
        CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
        
        self.pagingScrollView = [[UIKlinkScrollView alloc] initWithFrame:pagingScrollViewFrame];
        self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.pagingScrollView.userInteractionEnabled = YES;
        self.pagingScrollView.pagingEnabled = NO;
        self.pagingScrollView.delegate = self;
        self.pagingScrollView.showsHorizontalScrollIndicator = NO;
        self.pagingScrollView.showsVerticalScrollIndicator = NO;
        self.pagingScrollView.backgroundColor = nil;
        self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
        self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:self.pageIndex];        
        [self addSubview:self.pagingScrollView];
        
        
        // Setup pages
        self.visiblePages = [[NSMutableSet alloc] init];
        self.recycledPages = [[NSMutableSet alloc] init];
        
    
        
    }
    return self;
}


- (int) getLastVisibleIndex {
    
    CGRect visibleBounds = self.pagingScrollView.bounds;

    
    if (m_isHorizontalOrientation) {
        int leftIndex = [self pageIndex];
        return leftIndex + ceilf(visibleBounds.size.width/ (m_itemSpacing+m_itemWidth));
    }
    else {
        int topIndex = [self pageIndex];
        return topIndex + ceilf(visibleBounds.size.height / (m_itemSpacing + m_itemHeight));
    }
}

- (BOOL) isVisible:(int)index {
    int leftIndex = [self pageIndex];
    int rightIndex = [self getLastVisibleIndex];
    
    return (index >= leftIndex && index <= rightIndex);
}


- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (UIPagedViewItem *page in self.visiblePages)
		if (page.index == index) return YES;
	return NO;
}


- (UIPagedViewItem *)dequeueRecycledPage {
	UIPagedViewItem *page = [self.recycledPages anyObject];
	if (page) {
		[[page retain] autorelease];
		[self.recycledPages removeObject:page];
	}
	return page;
}


- (void)configurePage:(UIPagedViewItem *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
    
    if (page.view == nil) {
        UIView* subview = [self.delegate viewSlider:self cellForRowAtIndex:index withFrame:page.frame];
        
       // [UIView transitionWithView:self.pagingScrollView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{ [self.pagingScrollView addSubview:subview];} completion:nil];
        
        [self.pagingScrollView addSubview:subview];  
        page.view = subview;
    }
    else {
        UIView* existingView = page.view;
        [self.delegate viewSlider:self configure:page.view forRowAtIndex:index withFrame:page.frame];
   //             [UIView transitionWithView:self.pagingScrollView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{ [self.pagingScrollView addSubview:subview];} completion:nil];
        [self.pagingScrollView addSubview:existingView];
        
    }
    
}

- (void) render {
    //bracket window with lower bound and upper bound
    //foreach page 
    //configure and attach new view
    int lowerBound = self.pageIndex;
    
    int upperBound = [self getLastVisibleIndex];
    int itemCount = [self.delegate itemCountFor:self];
    
    if (upperBound >= itemCount) {
        upperBound = itemCount-1;
    }
    
    
    for (UIPagedViewItem *page in self.visiblePages) {
        if (page.index < lowerBound || page.index > upperBound) {
            [self.recycledPages addObject:page];
            page.index = -1;
            [page.view removeFromSuperview];
            
        }
    }
    [self.visiblePages minusSet:self.recycledPages];
    NSArray* visiblePagesArray = [self.visiblePages allObjects];
    
    for (int i =  lowerBound; i <= upperBound; i++) {
        //check to see if the page at this index is valid
        UIPagedViewItem* page = nil;
        
        for (UIPagedViewItem* item in visiblePagesArray) {
            if (item.index == i) {
                page = item;
                break;
            }
        }
        
        if (page == nil) {
            page  = [self dequeueRecycledPage];
        }
        
        if (page == nil) {
            page = [[UIPagedViewItem alloc]init];
            page.userInteractionEnabled = YES;
            [self configurePage:page forIndex:i];
            [self.visiblePages addObject:page];
            [page release];
        }
        else {
            [self configurePage:page forIndex:i];
            if ([self.visiblePages containsObject:page]==NO) {
                [self.visiblePages addObject:page];
            }
        }
        
        
    }
}

- (void) onNewItemInsertedAt:(int)index {
    int lastVisibleIndex = [self getLastVisibleIndex];
    UIPagedViewItem* newPage = [[UIPagedViewItem alloc]init];
    newPage.index = index;
    newPage.userInteractionEnabled = YES;
    [self.recycledPages addObject:newPage];
    [newPage release];
    
    if (index < self.pageIndex) {
        CGPoint currentScrollPosition = self.pagingScrollView.contentOffset;
        int newIndex = [self indexForContentOffset:currentScrollPosition];
        //adjust the page indices of all visible pages right now
        for (UIPagedViewItem* visiblePage in self.visiblePages) {
            visiblePage.index++;
        }
        self.pageIndex = newIndex;
    }
    else if (index >= self.pageIndex && index <= lastVisibleIndex) {
        for (UIPagedViewItem* page in self.visiblePages) {
            if (page.index >= index) {
                page.index++;
                
            }
        }
    }
    
    //need to increase the content size for the scrollview
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self render];
    //if the new item is inserted before current page
        //insert new blank page
        //re-calculate current index based on change
        //render
    //if the new item is inserted after last visible page
        //insert new blank page
        //render
    //if the new item is inserted in the middle of the visible window
        //insert new blank page
        //render entire window
}


- (void) animateScrollView : (NSTimer*) timerParam {
    NSDictionary *userInfo = [timerParam userInfo];
    NSNumber* timerDuration = [userInfo objectForKey:an_TIMERDURATION];
    NSDate* startTime = [userInfo objectForKey:an_STARTTIME];
    
    NSNumber* startingIndex = [userInfo objectForKey:an_STARTINGINDEX];
    NSNumber* destinationIndex = [userInfo objectForKey:an_DESTINATIONINDEX];
    NSTimeInterval timeRunning = - [startTime timeIntervalSinceNow];
    
    if (timeRunning >= [timerDuration doubleValue]) {
        self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:[destinationIndex intValue]];
        [timerParam invalidate];
        timerParam = nil;
        return;
    }
    else {
        CGPoint currentOffset = self.pagingScrollView.contentOffset;
        CGPoint startingOffset = [self contentOffsetForPageAtIndex:[startingIndex intValue]];
        CGPoint destinationOffset = [self contentOffsetForPageAtIndex:[destinationIndex intValue]];
        
        if (m_isHorizontalOrientation) {
            currentOffset.x = startingOffset.x + (destinationOffset.x - startingOffset.x) * (timeRunning / [timerDuration doubleValue]); 
        }
        else {
            currentOffset.y = startingOffset.y + (destinationOffset.y - startingOffset.y) * (timeRunning / [timerDuration doubleValue]); 
        }
        [self.pagingScrollView setContentOffset:currentOffset animated:YES];
    }
}

- (void) goTo:(int)index {
    [self goTo:index withAnimation:NO];
}

- (void) goTo:(int)index withAnimation:(BOOL)withAnimation {
    
    if (!withAnimation) {
        //move scroll head position
        int count = [self.delegate itemCountFor:self];
        if (index < count && index > 0) {
            self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:index];
            self.pageIndex = index;
        }
        [self render];
    }
    else {
        NSNumber* destinationIndex = [NSNumber numberWithInt:index];
        NSNumber* startingIndex = [NSNumber numberWithInt:self.pageIndex];
        
        NSDate* startTime = [NSDate date];
        
        NSNumber* duration =[NSNumber numberWithDouble:10.2];
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:startTime forKey:an_STARTTIME];
        [userInfo setObject:duration forKey:an_TIMERDURATION];
        [userInfo setObject:destinationIndex forKey:an_DESTINATIONINDEX];
        [userInfo setObject:startingIndex forKey:an_STARTINGINDEX];
        
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(animateScrollView:) userInfo:userInfo repeats:YES];
        
        
    }
} 

- (void)dealloc
{
    [super dealloc];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int count = [self.delegate itemCountFor:self];
    int newIndex = [self indexForContentOffset:scrollView.contentOffset];
    
    if (newIndex < 0) newIndex =0 ;
    
    if (newIndex > count - 1) newIndex = count - 1;
    int oldIndex = self.pageIndex;
    self.pageIndex = newIndex;
    
    if (self.pageIndex != oldIndex) {
        [self.delegate viewSlider:self isAtIndex:self.pageIndex withCellsRemaining:count-self.pageIndex];
        [self render];
    }
    
    //we have now adjusted the lower bound index based on scroll view
    
}

#pragma mark - Tap Handler
#pragma mark - Scroll tap handler
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
    
    // Process the single tap here
    if ([touches count]==1) { 
        
        
        UITouch* touch = [[touches allObjects]objectAtIndex:0];
        CGPoint touchLocation = [touch locationInView:self.pagingScrollView];
        int index = 0;
        int x = touchLocation.x;
        int y = touchLocation.y;
        
        if (m_isHorizontalOrientation) {
            index = (x) / (m_itemSpacing + m_itemWidth);
        }
        else {
            index = (y) / (m_itemSpacing + m_itemHeight); 
        }
        
        
        
        [self.delegate viewSlider:self selectIndex:index];
    }
    
    
}

- (void) reset {
    [self.recycledPages removeAllObjects];
    NSArray* visiblePagesArray = [self.visiblePages allObjects];
    for (int i = 0; i < [visiblePagesArray count];i++) {
        UIPagedViewItem* item = [visiblePagesArray objectAtIndex:i];
        [item.view removeFromSuperview];
    }
    
    [self.visiblePages removeAllObjects];
    
}
#pragma mark - Layout
-(NSArray*) getVisibleViews {
    
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* array  = [self.visiblePages allObjects];
    
    int insertIndex = 0;
    for (int i = 0 ; i < [self.visiblePages count];i++) {
        UIPagedViewItem* page = [array objectAtIndex:i];
        if (page.view != nil) {
            [retVal insertObject:page.view atIndex:insertIndex];
            insertIndex++;
        }
    }
    return retVal;
    
}


@end
