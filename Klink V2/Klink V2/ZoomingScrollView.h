//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"
#import "UIPagedViewSlider.h"
#import "Photo.h"
@class MWPhotoBrowser;

@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate, UIPagedViewSliderDelegate, NSFetchedResultsControllerDelegate> {
	
	// Browser
	MWPhotoBrowser *photoBrowser;
	
	// State
	NSUInteger index;
	
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
    UIPagedViewSlider* captionSlider;
    
    Photo* m_currentPhoto;
	
}

// Properties
@property (nonatomic) NSUInteger index;
@property (nonatomic, assign) MWPhotoBrowser *photoBrowser;
@property (nonatomic, retain) NSFetchedResultsController    *frc_captions;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;
@property (nonatomic, retain) Photo                         *currentPhoto;
// Methods
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
