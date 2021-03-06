//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import <UIKit/UIKit.h>
#import "MWPhoto.h"
#import "UIPagedViewSlider.h"
#import "ImageDownloadProtocol.h"
#import "Photo.h"
#import "UIPagedViewSlider.h"
@class ZoomingScrollView;

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate,ImageDownloadCallback, MWPhotoDelegate, NSFetchedResultsControllerDelegate,UIPagedViewSliderDelegate> {
	
	// Photos
	NSArray *photos;
	Photo   *m_currentPhoto;
    
    //Enumeration Contexts
    EnumerationContext* m_captionContext;
    BOOL m_IsCaptionEnumerationRunning;
    NSString* m_outstandingCaptionEnumNotificationID;
    
	// Views
	UIScrollView *pagingScrollView;
	
	// Paging
	NSMutableSet *visiblePages, *recycledPages;
	NSUInteger currentPageIndex;
	NSUInteger pageIndexBeforeRotation;
	
	// Navigation & controls
	UIToolbar *toolbar;
	NSTimer *controlVisibilityTimer;
	UIBarButtonItem *previousButton, *nextButton;

    // Misc
	BOOL performingLayout;
	BOOL rotating;
    
    UIPagedViewSlider* m_captionSlider;
    
	
}

@property (nonatomic, retain) NSFetchedResultsController    * frc_captions;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, retain) UIPagedViewSlider             *captionSlider;
@property (nonatomic, retain) Photo                         *currentPhoto;
@property (nonatomic, retain) EnumerationContext            *captionContext;
@property (nonatomic, retain) NSString                      *outstandingCaptionEnumNotificationID;

// Init
- (id)initWithPhotos:(NSArray *)photosArray;

// Photos
- (UIImage *)imageAtIndex:(NSUInteger)index;

// Layout
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (ZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;
- (void) assignPhoto: (Photo*)photo; 

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForCaptionSlider;
- (CGRect)frameForCaptionBackground:(int)index isHorizontalOrientation:(BOOL)isHorizontalOrientation;
- (CGRect)frameForCaption;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

// Properties
- (void)setInitialPageIndex:(NSUInteger)index;

@property (nonatomic, retain) NSArray *photos;

@end

