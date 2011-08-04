//
//  UIPagedViewSlider2.m
//  Klink V2
//
//  Created by Bobby Gill on 8/2/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPagedViewSlider2.h"
#import "UIPagedViewItem.h"
#define PADDING 0

@implementation UIPagedViewSlider2
@synthesize pagingScrollView    =   m_pagingScrollView;
@synthesize visiblePages        =   m_visiblePages;
@synthesize recycledPages       =   m_recycledPages;
@synthesize delegate            =   m_delegate;
@synthesize currentPageIndex    =   m_currentPageIndex;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

		m_currentPageIndex = 1;
		m_performingLayout = NO;
		m_rotating = NO;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

- (void)    didReceiveMemoryWarning {
    [self.recycledPages removeAllObjects];
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
        self.pagingScrollView.pagingEnabled = YES;
        self.pagingScrollView.delegate = self;
        self.pagingScrollView.showsHorizontalScrollIndicator = NO;
        self.pagingScrollView.showsVerticalScrollIndicator = NO;
        self.pagingScrollView.backgroundColor = [UIColor blackColor];
        self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
        self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:m_currentPageIndex];        
        [self addSubview:self.pagingScrollView];
        
        
        // Setup pages
        self.visiblePages = [[NSMutableSet alloc] init];
        self.recycledPages = [[NSMutableSet alloc] init];
        [self tilePages];
        
    }
    return self;
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);    
    return frame;
}



// Layout
- (void)    performLayout {
    // Flag
	m_performingLayout = YES;
	
//	// Toolbar
//	toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	
	// Remember index
	NSUInteger indexPriorToLayout = self.currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
    self.pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (UIPagedViewItem *page in self.visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	self.currentPageIndex = indexPriorToLayout;
	m_performingLayout = NO;
}

- (int) getIndex {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    CGPoint offset = self.pagingScrollView.contentOffset;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return (int)floorf(offset.x/(m_itemSpacing+m_itemWidth_landscape));
    }
    else {
        return (int)floorf(offset.x/(m_itemSpacing+m_itemWidth));
    }
}

- (int) getLastVisibleIndex {
    int leftIndex = [self getIndex];
    CGRect visibleBounds = self.pagingScrollView.bounds;
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    
    
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return leftIndex + ceilf(visibleBounds.size.width / (m_itemSpacing+m_itemWidth_landscape));
    }
    else {
        return leftIndex + ceilf(visibleBounds.size.width / (m_itemSpacing+m_itemWidth));
    }
}

// Paging
- (void)    tilePages {
    // Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
    int count = [self.delegate itemCountFor:self];
    if (count > 0) {
        CGRect visibleBounds = self.pagingScrollView.bounds;
        
        int iFirstIndex = [self getIndex];
        int iLastIndex = [self getLastVisibleIndex];
       
//        int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
//        int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
        if (iFirstIndex < 0) iFirstIndex = 0;
        if (iFirstIndex > count - 1) iFirstIndex = count - 1;
        if (iLastIndex < 0) iLastIndex = 0;
        if (iLastIndex > count - 1) iLastIndex = count - 1;
        
        // Recycle no longer needed pages
        for (UIPagedViewItem *page in self.visiblePages) {
            if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
                [self.recycledPages addObject:page];
                /*NSLog(@"Removed page at index %i", page.index);*/
                page.index = NSNotFound; // empty
                [page.view removeFromSuperview];
            }
        }
        [self.visiblePages minusSet:self.recycledPages];
        
        // Add missing pages
        for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
            if (![self isDisplayingPageForIndex:index]) {
                UIPagedViewItem *page = [self dequeueRecycledPage];
                if (!page) {
                    page = [[[UIPagedViewItem alloc] init] autorelease];
                    page.userInteractionEnabled = YES;
                    //				page.photoBrowser = self;
                }
                [self configurePage:page forIndex:index];
                [self.visiblePages addObject:page];
                //[self.pagingScrollView addSubview:page];
                /*NSLog(@"Added page at index %i", page.index);*/
            }
        }
    }
}

- (void)configurePage:(UIPagedViewItem *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
    
    UIView* subview = [self.delegate viewSlider:self cellForRowAtIndex:index withFrame:page.frame];
    [self.pagingScrollView addSubview:subview];    
    page.view = subview;
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
// Properties
- (void)    setInitialPageIndex:    (NSUInteger)    index {
    self.currentPageIndex = index;
    [self performLayout];
    [self tilePages];
}

//Frames
- (CGSize)  contentSizeForPagingScrollView {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int count = [self.delegate itemCountFor:self];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGSizeMake((m_itemWidth_landscape+m_itemSpacing) * count, m_itemHeight_landscape);
    }
    else {
         return CGSizeMake((m_itemWidth+m_itemSpacing) * count, m_itemHeight);
    }
    
}

- (CGRect)  frameForPageAtIndex:            (NSUInteger)    index {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake((m_itemWidth_landscape+m_itemSpacing) * index,0,m_itemWidth_landscape, m_itemHeight_landscape);
    }
    else {
        return CGRectMake((m_itemWidth+m_itemSpacing) * index,0,m_itemWidth, m_itemHeight);

    }
}

- (CGPoint) contentOffsetForPageAtIndex:    (NSUInteger)    index {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
       if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGPointMake((m_itemWidth_landscape+m_itemSpacing) * index, 0);
    }
    else {
        return CGPointMake((m_itemWidth+m_itemSpacing) * index, 0);
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (m_performingLayout || m_rotating) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = self.pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    int count = [self.delegate itemCountFor:self];
    
    if (index < 0) index = 0;
	if (index > count - 1) index = count - 1;
	
    
    NSUInteger previousCurrentPage = m_currentPageIndex;
	self.currentPageIndex = index;
	if (self.currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
        [self.delegate viewSlider:self isAtIndex:index withCellsRemaining:count-index];
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
    //TODO: make a call to view controller to do this
    //	[self setControlsHidden:YES];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
    
    //TODO make a call to the view controller to do this
	[self updateNavigation];
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    
    //TODO: figure out whats supposed to happen here
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {

	
}

#pragma mark - Tap Handler
#pragma mark - Scroll tap handler
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
    
    // Process the single tap here
    if ([touches count]==1) { 
        UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
        
        UITouch* touch = [[touches allObjects]objectAtIndex:0];
        CGPoint touchLocation = [touch locationInView:self.pagingScrollView];
        int index = 0;
        int x = touchLocation.x;
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            index = (x)/(m_itemSpacing+m_itemWidth_landscape);
        }
        else {
             index = (x)/(m_itemSpacing+m_itemWidth);
        }
   
        [self.delegate viewSlider:self selectIndex:index];
    }
    
    
}

@end
