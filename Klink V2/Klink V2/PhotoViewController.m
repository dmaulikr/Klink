//
//  PhotoViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 8/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PhotoViewController.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "ImageManager.h"
#import "UIZoomingScrollView.h"

#define kPictureWidth_landscape     480
#define kPictureWidth               320
#define kPictureHeight              370
#define kPictureHeight_landscape    245
#define kPictureSpacing             10
#define kCaptionWidth_landscape     480
#define kCaptionWidth               320
#define kCaptionHeight_landscape    50
#define kCaptionHeight              50
#define kCaptionSpacing             0

@implementation PhotoViewController
@synthesize currentPhoto            = m_currentPhoto;
@synthesize currentTheme            = m_currentTheme;
@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;
@synthesize managedObjectContext    = __managedObjectContext;
@synthesize pvs_photoSlider         = __pvs_photoSlider;
@synthesize pvs_captionSlider       = __pvs_captionSlider;
@synthesize v_pvs_captionSlider;
@synthesize v_pvs_photoSlider;
@synthesize h_pvs_photoSlider;
@synthesize h_pvs_captionSlider;
@synthesize previousButton          = m_previousButton;
@synthesize nextButton              = m_nextButton;
@synthesize controlVisibilityTimer  = m_controlVisibilityTimer;
@synthesize pagedViewSlider         = __pagedViewSlider;
@synthesize v_pagedViewSlider;
@synthesize h_pagedViewSlider;

#pragma mark - Property Definitions

-(UIPagedViewSlider2*)pagedViewSlider {

    if (self.view == self.v_portrait) {
        
        return self.v_pagedViewSlider;
    }
    else {
        return self.h_pagedViewSlider;
    }
}
-(UIPagedViewSlider2*)pvs_photoSlider {
    if (self.view == self.v_portrait) {
        return self.v_pvs_photoSlider;
    }
    else {
        return self.h_pvs_photoSlider;
    }
}


-(UIPagedViewSlider2*)pvs_captionSlider {
    if (self.view == self.v_landscape) {
        return self.h_pvs_captionSlider;
    }
    else {
        return self.v_pvs_captionSlider;
    }
}

- (NSManagedObjectContext*)managedObjectContext {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}


- (NSFetchedResultsController*) frc_photos {
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    if (self.currentTheme == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"themeid=%@",self.currentTheme.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_photos = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_photos;
}

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

- (void) assignPhoto: (Photo*)photo {
    NSString* activityName = @"PhotoViewController.assignPhoto:";
    NSNumber* currentPhotoID = self.currentPhoto.objectid;
   
    __frc_captions = nil;
    
    self.currentPhoto = photo;
    NSString* message = [NSString stringWithFormat:@"Changed active Photo from %@ to %@",currentPhotoID,photo.objectid];
    [BLLog v:activityName withMessage:message];        
}


#pragma mark - initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	NSLog(@"didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.h_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];
    [self.v_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];

 
    
    m_wantsFullScreenLayout = YES;
    m_hidesBottomBarWhenPushed = YES;
    
      
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    // Super
	[super viewWillAppear:animated];
	
    // Navigation bar
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    

    
    //set the initial index properly 
    int index = 0;
    NSArray* photos = [self.frc_photos fetchedObjects];
    
    if (self.currentPhoto != nil) {
        for (int i = 0; i < [photos count];i++) {
            Photo* currPhoto = [photos objectAtIndex:i];
            if ([self.currentPhoto.objectid isEqualToNumber:currPhoto.objectid]) {
                index = i;
                break;
            }
        }
    }
    
    self.pagedViewSlider.currentPageIndex = index;
	// Layout
	[self.pagedViewSlider performLayout];
  
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
	[self updateNavigation];
	//[self hideControlsAfterDelay];
	[self didStartViewingPageAtIndex:self.pagedViewSlider.currentPageIndex]; // initial
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation

// Navigation
- (void)updateNavigation {
    NSArray* photos = [self.frc_photos fetchedObjects];
    // Title
	if (photos.count > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", self.pagedViewSlider.currentPageIndex+1, photos.count];		
	} else {
		self.title = nil;
	}
	
	// Buttons
	self.previousButton.enabled = (self.pagedViewSlider.currentPageIndex > 0);
	self.nextButton.enabled = (self.pagedViewSlider.currentPageIndex < photos.count-1);
}


// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
}




#pragma mark Control Hiding / Showing

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		[self.controlVisibilityTimer release];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay {
    [self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		self.controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
    
    
}



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

	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
	
}

- (void)hideControls { 
        [self setControlsHidden:YES]; 
}

- (void)toggleControls { 
        [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; 
}

#pragma mark - Frames
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}


- (CGRect)frameForPhoto:(int)index sliderIsHorizontal:(BOOL)isHorizontalOrientation {
    if (isHorizontalOrientation == NO) {
        
        return CGRectMake(0, 0, kPictureWidth_landscape, kPictureHeight_landscape);
    }
    else {
        int xcoordinate = index * (kPictureWidth + kPictureSpacing);
       return CGRectMake(xcoordinate, 0, kPictureWidth, kPictureHeight); 
    }
}

- (CGRect)frameForCaption:(int)index sliderIsHorizontal:(BOOL)isHorizontalOrientation {
    if (isHorizontalOrientation == NO) {
        
        return CGRectMake(0, 0, kCaptionWidth_landscape, kCaptionHeight_landscape);
    }
    else {
        int xcoordinate = index * (kCaptionWidth + kCaptionSpacing);
        return CGRectMake(xcoordinate, 0, kCaptionWidth, kCaptionHeight); 
    }
}

#pragma mark - UIPagedViewSlider Delegate


- (UIView*)viewSlider:(UIPagedViewSlider2 *)viewSlider cellForRowAtIndex:(int)index withFrame:(CGRect)frame {
    
    UIZoomingScrollView* zoomingScrollView = [[UIZoomingScrollView alloc]initWithFrame:frame];
    zoomingScrollView.viewController = self;
    ImageManager* imageManager = [ImageManager getInstance];
    
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:zoomingScrollView forKey:an_IMAGEVIEW];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
    
    [zoomingScrollView displayImage:image];
 
    return zoomingScrollView;
}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    if (viewSlider == self.pvs_photoSlider) {
        if (index != m_currentIndex) {
            m_currentIndex = index;
            Photo* currentPhoto = [[self.frc_photos fetchedObjects]objectAtIndex:index];
            [self assignPhoto:currentPhoto];
        }
    }
}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider selectIndex:(int)index {
    NSLog(@"Dandarr");
}


- (int) itemCountFor: (UIPagedViewSlider2*)viewSlider {
    return [[self.frc_photos fetchedObjects]count];
}

#pragma mark - Image Download Protocol
- (void)onImageDownload:(UIImage *)image withUserInfo:(NSDictionary *)userInfo {
    UIZoomingScrollView* imageView = [userInfo objectForKey:an_IMAGEVIEW];
    [imageView displayImage:image];
}
@end
