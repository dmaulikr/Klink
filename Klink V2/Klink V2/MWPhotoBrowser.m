//
//  MWPhotoBrowser.m
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


#import "MWPhotoBrowser.h"
#import "ZoomingScrollView.h"
#import "Photo.h"
#import "ImageManager.h"
#import "DataLayer.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "NSStringGUIDCategory.h"
#import <QuartzCore/QuartzCore.h>
#define PADDING 10


#define kCaptionWidth 100
#define kCaptionHeight 100
#define kCaptionWidth_landscape 480
#define kCaptionHeight_landscape 100
#define kCaptionSpacing 100
#define kCaptionSliderHeight 100
#define kCaptionSliderWidth 320
#define kCaptionSliderHeight_landscape 100
#define kCaptionSliderWidth_landscape 320


// Handle depreciations and supress hide warnings
@interface UIApplication (DepreciationWarningSuppresion)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

// MWPhotoBrowser
@implementation MWPhotoBrowser

@synthesize photos;
@synthesize frc_captions                            = __frc_captions;
@synthesize managedObjectContext                    = __managedObjectContext;
@synthesize captionSlider                           = m_captionSlider;
@synthesize currentPhoto                            = m_currentPhoto;
@synthesize outstandingCaptionEnumNotificationID    = m_outstandingCaptionEnumNotificationID;
@synthesize captionContext                          = m_captionContext;

#pragma mark - Managed Object Context
- (NSManagedObjectContext*) managedObjectContext {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
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


#pragma mark - initializers
- (id)initWithPhotos:(NSArray *)photosArray {
	if ((self = [super init])) {
		
		// Store photos
		photos = [photosArray retain];
		
        
        Photo* activePhoto = [photosArray objectAtIndex:1];
        [self assignPhoto:activePhoto];
        
        // Defaults
		self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
		currentPageIndex = 1;
		performingLayout = NO;
		rotating = NO;
		
	}
	return self;
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	// Release any cached data, images, etc that aren't in use.
	
	// Release images
	[photos makeObjectsPerformSelector:@selector(releasePhoto)];
	[recycledPages removeAllObjects];
	NSLog(@"didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
	currentPageIndex = 0;
    [pagingScrollView release], pagingScrollView = nil;
    [visiblePages release], visiblePages = nil;
    [recycledPages release], recycledPages = nil;
    [toolbar release], toolbar = nil;
    [previousButton release], previousButton = nil;
    [nextButton release], nextButton = nil;
}

- (void)dealloc {
	[photos release];
	[pagingScrollView release];
	[visiblePages release];
	[recycledPages release];
	[toolbar release];
	[previousButton release];
	[nextButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark View

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

   
	//Setup caption slider 
//    self.captionSlider.userInteractionEnabled = YES;
//    self.captionSlider.backgroundColor = [UIColor clearColor];
//    self.captionSlider.opaque = NO;
//    self.captionSlider = [UIPagedViewSlider alloc];
//    CGRect captionSliderFrame = [self frameForCaptionSlider];
//    [self.captionSlider initWithFrame:captionSliderFrame];
//    self.captionSlider.delegate = self;
//    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        [self.captionSlider initWith:kCaptionWidth_landscape itemHeight:kCaptionHeight_landscape itemSpacing:kCaptionSpacing];
//        
//    }
//    else {
//        [self.captionSlider initWith:kCaptionWidth itemHeight:kCaptionHeight itemSpacing:kCaptionSpacing];        
//    }
    
    
    
	// View
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	pagingScrollView.userInteractionEnabled = YES;
    pagingScrollView.pagingEnabled = YES;
	pagingScrollView.delegate = self;
	pagingScrollView.showsHorizontalScrollIndicator = NO;
	pagingScrollView.showsVerticalScrollIndicator = NO;
	pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
//    [pagingScrollView addSubview:self.captionSlider];
	[self.view addSubview:pagingScrollView];
	

        
    BOOL isFirstResponder = [self.captionSlider becomeFirstResponder];
	// Setup pages
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	[self tilePages];
    
    // Navigation bar
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	
    // Only show toolbar if there's more that 1 photo
    if (photos.count > 1) {
    
        // Toolbar
        toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
        toolbar.tintColor = nil;
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
      //  [self.view addSubview:toolbar];
        
        // Toolbar Items
        previousButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowLeft.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoPreviousPage)];
        nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemArrowRight.png"] style:UIBarButtonItemStylePlain target:self action:@selector(gotoNextPage)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:space];
        if (photos.count > 1) [items addObject:previousButton];
        [items addObject:space];
        if (photos.count > 1) [items addObject:nextButton];
        [items addObject:space];
        [toolbar setItems:items];
        [items release];
        [space release];

    }
        
	// Super
    [super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {

	// Super
	[super viewWillAppear:animated];
	
	// Layout
	[self performLayout];
    
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    	
	// Navigation
	[self updateNavigation];
	[self hideControlsAfterDelay];
	[self didStartViewingPageAtIndex:currentPageIndex]; // initial
	
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Super
	[super viewWillDisappear:animated];

	// Cancel any hiding timers
	[self cancelControlHiding];
	
}

#pragma mark -
#pragma mark Layout

// Layout subviews
- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Toolbar
	toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
		
	// Frame needs changing
	pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (ZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
	performingLayout = NO;

}

#pragma mark -
#pragma mark Photos

// Get image if it has been loaded, otherwise nil
- (UIImage *)imageAtIndex:(NSUInteger)index {
	if (photos && index < photos.count) {

        /* ORIGINAL MW code using MWPhoto object
		// Get image or obtain in background
		MWPhoto *photo = [photos objectAtIndex:index];
		if ([photo isImageAvailable]) {
			return [photo image];
		} else {
			[photo obtainImageInBackgroundAndNotify:self];
		}*/
        
        // JORDAN's code using our Photo object
        Photo *photo = [self.photos objectAtIndex:index];
        
        ImageManager* imageManager = [ImageManager getInstance];
        //NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
        //[userInfo setObject:imageView forKey:an_IMAGEVIEW];        
        
        
        
        
        UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:self];   
        
        if (image != nil) {
            return image;
        }
        else {
            // TODO implement return of a placeholder image
            //self.imageView.backgroundColor =[UIColor blackColor];
            return nil;
        }
        
        
		
	}
	return nil;
}

#pragma mark - UIPagedSlider Delegate
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

#pragma mark -
#pragma mark MWPhotoDelegate

- (void)photoDidFinishLoading:(Photo *)photo {
	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page to display image again
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImage];
			
		}
	}
}

- (void)photoDidFailToLoad:(Photo *)photo {
	NSUInteger index = [photos indexOfObject:photo];
	if (index != NSNotFound) {
		if ([self isDisplayingPageForIndex:index]) {
			
			// Tell page it failed
			ZoomingScrollView *page = [self pageDisplayedAtIndex:index];
			if (page) [page displayImageFailure];
			
		}
	}
}

#pragma mark -
#pragma mark Paging

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = pagingScrollView.bounds;
	int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > photos.count - 1) iFirstIndex = photos.count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > photos.count - 1) iLastIndex = photos.count - 1;
	
	// Recycle no longer needed pages
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			/*NSLog(@"Removed page at index %i", page.index);*/
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			ZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[[ZoomingScrollView alloc] init] autorelease];
				page.photoBrowser = self;
			}
			[self configurePage:page forIndex:index];
			[visiblePages addObject:page];
            [pagingScrollView addSubview:page];
			/*NSLog(@"Added page at index %i", page.index);*/
		}
	}
	
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (ZoomingScrollView *page in visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	ZoomingScrollView *thePage = nil;
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

#pragma mark - Enumeration Result Handlers
- (void) onEnumerateCaptionsComplete:(NSNotification*) notification {
    NSString* activityName = @"MWPhotoBrowser.m:";
    NSDictionary* userInfo = [notification userInfo];
    
    if ([notification.name isEqualToString:self.outstandingCaptionEnumNotificationID]) {
        if ([userInfo objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
            EnumerationContext* returnedContext = [userInfo objectForKey:an_ENUMERATIONCONTEXT];
            if ([returnedContext.isDone boolValue] == NO) {
                //enumeration context remains open
                NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved for future use",returnedContext.isDone];
                [BLLog v:activityName withMessage:message];

            }
            else {
                 //enumeration is complete, set the context to nil
                NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@",returnedContext.isDone];
                [BLLog v:activityName withMessage:message];

            }
            self.captionContext = returnedContext;
        }
        m_IsCaptionEnumerationRunning = NO;
        
    }
    
}


#pragma mark - Enumeration Handlers
- (void) enumerateCaptionsFromWebService {
    if (self.currentPhoto != nil && !m_IsCaptionEnumerationRunning) {
        if (self.captionContext == nil) {
            self.captionContext = [EnumerationContext contextForCaptions:self.currentPhoto];
        }
        
        m_IsCaptionEnumerationRunning = true;
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        
        NSString* notificationID = [NSString GetGUID];
        QueryOptions* queryOptions = [QueryOptions queryForCaptions:self.currentPhoto.objectid];
        self.outstandingCaptionEnumNotificationID = notificationID;
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onEnumerateCaptionsComplete:) name:notificationID object:nil];
        
        [enumerationManager enumerateCaptionsForPhoto:self.currentPhoto withPageSize:self.captionContext.pageSize withQueryOptions:queryOptions onFinishNotify:notificationID useEnumerationContext:self.captionContext shouldEnumerateSinglePage:YES];
        
    }
}

#pragma mark - Configure Page

- (void) assignPhoto: (Photo*)photo {
    NSString* activityName = @"MWPhotoBrowser.assignPhoto:";
    NSNumber* oldPhotoID = self.currentPhoto.objectid;
    self.frc_captions = nil;
    
    //TODO: insert code to reload the caption scroll view
    self.currentPhoto = photo;

    
    NSString* message = [NSString stringWithFormat:@"Changing from PhotoID:%@ to PhotoID:%@",[oldPhotoID stringValue],[self.currentPhoto.objectid stringValue]];
    [BLLog v:activityName withMessage:message];
    
    
    //now we need to queue up all of the captions for this photo
    NSArray* captions = [self.frc_captions fetchedObjects];
    [self.captionSlider resetSliderWithItems:captions];
    
    //we need to execute enumeration for remaining captions that we do not have
    self.outstandingCaptionEnumNotificationID = nil;
    m_IsCaptionEnumerationRunning = NO;
    
    [self enumerateCaptionsFromWebService];
    
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
    
    
    Photo* photo = [self.photos objectAtIndex:index];
    page.currentPhoto = photo;
        
}
										  
- (ZoomingScrollView *)dequeueRecycledPage {
	ZoomingScrollView *page = [recycledPages anyObject];
	if (page) {
		[[page retain] autorelease];
		[recycledPages removeObject:page];
	}
	return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    NSUInteger i;
    if (index > 0) {
        
        // Release anything < index - 1
        // ORIGINAL MW code using MWPhoto object
        //for (i = 0; i < index-1; i++) { [(Photo *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
        
        // JORDAN's code using our Photo object
        for (i = 0; i < index-1; i++) {
            Photo *photo = [self.photos objectAtIndex:i];
            photo = nil;
        }
        
        // Preload index - 1
        i = index - 1; 
        
        // ORIGINAL MW code using MWPhoto object
        //if (i < photos.count) { [(Photo *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
        
        // JORDAN's code using our Photo object
        if (i < photos.count) {
            Photo *photo = [self.photos objectAtIndex:i];
            
            ImageManager* imageManager = [ImageManager getInstance];
            //NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
            //[userInfo setObject:imageView forKey:an_IMAGEVIEW];        
            
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:self];   
            
        }
        
    }
    if (index < photos.count - 1) {
        
        // Release anything > index + 1
        // ORIGINAL MW code using MWPhoto object
        //for (i = index + 2; i < photos.count; i++) { [(Photo *)[photos objectAtIndex:i] releasePhoto]; /*NSLog(@"Release image at index %i", i);*/ }
    
        // JORDAN's code using our Photo object
        for (i = index + 2; i < photos.count; i++) {
            Photo *photo = [self.photos objectAtIndex:i];
            photo = nil;
        }
        
        
        // Preload index + 1
        i = index + 1; 
        // ORIGINAL MW code using MWPhoto object
        //if (i < photos.count) { [(Photo *)[photos objectAtIndex:i] obtainImageInBackgroundAndNotify:self]; /*NSLog(@"Pre-loading image at index %i", i);*/ }
        
        // JORDAN's code using our Photo object
        if (i < photos.count) {
            Photo *photo = [self.photos objectAtIndex:i];
            
            ImageManager* imageManager = [ImageManager getInstance];
            //NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
            //[userInfo setObject:imageView forKey:an_IMAGEVIEW];        
            
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:self];   
            
        }
        
    }
}

#pragma mark -
#pragma mark Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        frame.size.height -= kCaptionSliderHeight_landscape;
//    }
//    else {
//        frame.size.height -= kCaptionSliderHeight;
//    }
    
    return frame;
}

- (CGRect)frameForCaptionSlider {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    CGRect viewFrame = self.view.bounds;
    
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

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * photos.count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (performingLayout || rotating) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > photos.count - 1) index = photos.count - 1;
	NSUInteger previousCurrentPage = currentPageIndex;
	currentPageIndex = index;
	if (currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
	[self updateNavigation];
}

#pragma mark -
#pragma mark Navigation

- (void)updateNavigation {

	// Title
	if (photos.count > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", currentPageIndex+1, photos.count];		
	} else {
		self.title = nil;
	}
	
	// Buttons
	previousButton.enabled = (currentPageIndex > 0);
	nextButton.enabled = (currentPageIndex < photos.count-1);
	
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < photos.count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
		[self updateNavigation];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
	
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:currentPageIndex-1]; }
- (void)gotoNextPage { [self jumpToPageAtIndex:currentPageIndex+1]; }

#pragma mark -
#pragma mark Control Hiding / Showing

- (void)setControlsHidden:(BOOL)hidden {
	
	// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;
	
	// Bars
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
	[toolbar setAlpha:hidden ? 0 : 1];
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
	
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		[controlVisibilityTimer release];
		controlVisibilityTimer = nil;
	}
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
}

- (void)hideControls { [self setControlsHidden:YES]; }
- (void)toggleControls { [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; }

#pragma mark -
#pragma mark Rotation

- (UIDeviceOrientation)getCurrentDeviceOrientation {
    UIDevice* device = [UIDevice currentDevice];
    return device.orientation;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

	// Remember page index before rotation
	pageIndexBeforeRotation = currentPageIndex;
	rotating = YES;
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	currentPageIndex = pageIndexBeforeRotation;
	[self performLayout];
	
	// Delay control holding
	[self hideControlsAfterDelay];
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	rotating = NO;
}

#pragma mark -
#pragma mark Properties

- (void)setInitialPageIndex:(NSUInteger)index {
	if (![self isViewLoaded]) {
		if (index >= photos.count) {
			currentPageIndex = 0;
		} else {
			currentPageIndex = index;
		}
	}
}


#pragma mark -
#pragma mark - Image Download Callback
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    //this method is called by the ImageManager whenever it is returning an image that it has downloaded from the internet
    //the userInfo dictionary passed in is the exact same oneyou passed into the DownloadImage method of the ImageManager.
    
}

@end
