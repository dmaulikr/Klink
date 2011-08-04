//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//



#import "ZoomingScrollView.h"
#import "MWPhotoBrowser.h"
#import "AttributeNames.h"
#import "TypeNames.h"

#define kCaptionWidth 100
#define kCaptionHeight 100
#define kCaptionWidth_landscape 480
#define kCaptionHeight_landscape 100
#define kCaptionSpacing 100
#define kCaptionSliderHeight 100
#define kCaptionSliderWidth 320
#define kCaptionSliderHeight_landscape 100
#define kCaptionSliderWidth_landscape 320

@implementation ZoomingScrollView

@synthesize index, photoBrowser;
@synthesize frc_captions = __frc_captions;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize currentPhoto = m_currentPhoto;

#pragma mark - Managed Object Context
- (NSManagedObjectContext*) managedObjectContext {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

CGFloat initialZoomScale = 1;   // ADDED BY JORDANG

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		// Tap view for background
		tapView = [[UIViewTap alloc] initWithFrame:frame];
		tapView.tapDelegate = self;
		tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:tapView];
		
		// Image view
		photoImageView = [[UIImageViewTap alloc] initWithFrame:CGRectZero];
		photoImageView.tapDelegate = self;
		photoImageView.contentMode = UIViewContentModeCenter;
		photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:photoImageView];
		
		// Spinner
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.hidesWhenStopped = YES;
		spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:spinner];
		
        captionSlider = [UIPagedViewSlider alloc];
        captionSlider.userInteractionEnabled = YES;
        captionSlider.backgroundColor = [UIColor clearColor];
        captionSlider.opaque = NO;
        
      
        CGRect captionSliderFrame = CGRectMake(0, 0, 0, 0);
        [captionSlider initWithFrame:captionSliderFrame];
        captionSlider.delegate = self;

        [self addSubview:captionSlider];
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	}
	return self;
}

#pragma mark - Fetched Results Controllers
- (NSFetchedResultsController*) frc_captions {
    if (__frc_captions != nil) {
        return __frc_captions;
    }
    if (self.currentPhoto == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"photoid=%@",self.currentPhoto.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_captions = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_captions;
    
    
}
#pragma mark - Fetched Results Controller Delegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    
    
    
}

#pragma mark - UIPagedSlider Delegate
- (CGRect)frameForCaptionSlider {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    CGRect viewFrame = self.bounds;
    
    if (UIInterfaceOrientationIsLandscape(orientation)){
        
        CGRect frame = CGRectMake(0, (viewFrame.size.height-kCaptionHeight_landscape), kCaptionSliderWidth_landscape, kCaptionSliderHeight_landscape);
        return frame;
    }
    else {
        CGRect frame = CGRectMake(0,  0,kCaptionSliderWidth, kCaptionSliderHeight);
        return frame;
        
    }
    
}

- (CGRect)frameForCaptionBackground:(int)index isHorizontalOrientation:(BOOL)isHorizontalOrientation {
    int xCoordinate = 0;
    int yCoordinate = 0;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        xCoordinate = index * (kCaptionWidth_landscape + kCaptionSpacing);
        return CGRectMake(xCoordinate,yCoordinate,kCaptionWidth_landscape,kCaptionHeight);
    }
    else {
        xCoordinate = index * (kCaptionWidth + kCaptionSpacing);
        return CGRectMake(xCoordinate,yCoordinate,kCaptionWidth,kCaptionHeight);
    }
    
}

- (CGRect)frameForCaption {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0,0,kCaptionWidth_landscape,kCaptionHeight);
    }
    else {
        
        return CGRectMake(0,0,kCaptionWidth,kCaptionHeight);
    }
    
    
    
    
}
- (void)viewSlider:(UIPagedViewSlider*)viewSlider selectIndex:(int)index {
    
}

-(void)onButtonClicked:(id)sender {
    NSLog(@"hadaa");
}
- (UIView*)viewSlider:(UIPagedViewSlider *)viewSlider cellForRowAtIndex:(int)index sliderIsHorizontal:(BOOL)isHorizontalOrientation {
    
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
    
    CGRect captionFrame = [self frameForCaption];
    CGRect captionBackgroundFrame = [self frameForCaptionBackground:index isHorizontalOrientation:isHorizontalOrientation];
    
    UIView* view = [[UIView alloc]initWithFrame:captionBackgroundFrame];
    view.backgroundColor = [UIColor blackColor];
    view.opaque = YES;
    
    
    UILabel* captionLabel = [[[UILabel alloc]initWithFrame:captionFrame]autorelease];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.backgroundColor = [UIColor blackColor];
    captionLabel.opaque = NO;
    captionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    captionLabel.text = caption.caption1;
    captionLabel.textAlignment = UITextAlignmentCenter;
    [view addSubview:captionLabel];
    
    UIButton* button = [[UIButton alloc]initWithFrame:captionBackgroundFrame];
    [button setTitle:@"dick" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.userInteractionEnabled = YES;
    
    
    return button;
}

- (void)viewSlider:(UIPagedViewSlider*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    
}

- (void)dealloc {
	[tapView release];
	[photoImageView release];
	[spinner release];
	[super dealloc];
}

- (void)setIndex:(NSUInteger)value {
	if (value == NSNotFound) {
		
		// Release image
		photoImageView.image = nil;
		
	} else {
		
		// Reset for new page at index
		index = value;
		
		// Display image
		[self displayImage];
		
	}
}

#pragma mark -
#pragma mark Image

// Get and display image
- (void)displayImage {
	if (index != NSNotFound && photoImageView.image == nil) {
		
        // ADDED BY JORDANG
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
        [userInfo setObject:photoImageView forKey:an_IMAGEVIEW];  
        
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
		
		// Get image
		UIImage *img = [self.photoBrowser imageAtIndex:index withUserInfo:userInfo]; // EDITED BY JORDANG
		if (img) {
			
			// Hide spinner
			[spinner stopAnimating];
			
			// Set image
			photoImageView.image = img;
			photoImageView.hidden = NO;
			
			// Setup photo frame
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
			photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;

			// Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
			
		} else {
			
			// Hide image view
			photoImageView.hidden = YES;
			[spinner startAnimating];
			
		}
		[self setNeedsLayout];
	}
}

// Image failed so just show black!
- (void)displayImageFailure {
	[spinner stopAnimating];
}

#pragma mark -
#pragma mark Setup Content

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
	
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}
    
	// Calculate Max
	CGFloat maxScale = 2.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
    
    // ADDED BY JORDANG Calculate initial Zoom
    if (imageSize.height > imageSize.width) {
        initialZoomScale = yScale;
    } else {
        initialZoomScale = xScale;
    }
	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = initialZoomScale;      // EDITED BY JORDANG

	
	// Reset position
	photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height);
	[self setNeedsLayout];

}

#pragma mark -
#pragma mark UIView Layout

- (void)layoutSubviews {
	
	// Update tap view frame
	tapView.frame = self.bounds;
	
    //paged slider
    NSArray* captions = [self.frc_captions fetchedObjects];
    [captionSlider initWith:kCaptionWidth itemHeight:kCaptionHeight itemSpacing:kCaptionSpacing];  
    [captionSlider resetSliderWithItems:captions];
    CGRect newFrame = CGRectMake(0, self.bounds.size.height-kCaptionHeight, self.bounds.size.width, kCaptionHeight);
    captionSlider.frame = newFrame;

	// Spinner
	if (!spinner.hidden) spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
													  floorf(self.bounds.size.height/2.0));
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(photoImageView.frame, frameToCenter))
		photoImageView.frame = frameToCenter;
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[photoBrowser hideControlsAfterDelay];
}

#pragma mark -
#pragma mark Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
	[photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	
	// Cancel any single tap handling
	[NSObject cancelPreviousPerformRequestsWithTarget:photoBrowser];
	
	// Zoom
	if (self.zoomScale == self.maximumZoomScale || (self.zoomScale == self.minimumZoomScale && self.minimumZoomScale != initialZoomScale)) {    // EDITED BY JORDANG
		
		// Zoom out
		[self setZoomScale:initialZoomScale animated:YES];     // EDITED BY JORDANG
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
	
	// Delay controls
	[photoBrowser hideControlsAfterDelay];
	
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:imageView]]; }
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:imageView]]; }

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:view]]; }
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:view]]; }

@end
