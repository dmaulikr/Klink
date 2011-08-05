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
#import "UIPhotoCaptionScrollView.h"

#define kPictureWidth_landscape     480
#define kPictureWidth               320
#define kPictureHeight              370
#define kPictureHeight_landscape    245
#define kPictureSpacing             0


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
@synthesize photoCloudEnumerator    =m_photoCloudEnumerator;
#pragma mark - Property Definitions

-(UIPagedViewSlider2*)pagedViewSlider {

    if (self.view == self.v_portrait) {
        
        return self.v_pagedViewSlider;
    }
    else {
        return self.h_pagedViewSlider;
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

    self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.currentTheme.objectid];
    self.photoCloudEnumerator.delegate = self;
    if ([[self.frc_photos fetchedObjects]count]<threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
    }
    
    m_wantsFullScreenLayout = YES;
    m_hidesBottomBarWhenPushed = YES;
    
      
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    // Super
	[super viewWillAppear:animated];
	
    // Navigation bar
    self.navigationController.navigationBar.translucent = YES;
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
    [self.pagedViewSlider setInitialPageIndex:index];
   
	// Layout
	[self.pagedViewSlider performLayout];
  
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
	[self updateNavigation];
	//[self hideControlsAfterDelay];
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
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didRotate:(NSNotification*)notification {
    [super didRotate:notification];
    //need to switch out the ladscape and portrait views
    //populate the sv_sliders as needed
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //going to potrait
        
        int currentScrollIndex = self.pagedViewSlider.currentPageIndex;
        self.view = self.v_portrait;
        [self.pagedViewSlider setInitialPageIndex:currentScrollIndex];
    }
    else {
        //going to landscape
        int currentScrollIndex = self.pagedViewSlider.currentPageIndex;
        self.view = self.v_landscape;        
        [self.pagedViewSlider setInitialPageIndex:currentScrollIndex];
    }
    
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

#pragma mark - UIPagedViewSlider2Delegate

- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider configure:(UIPhotoCaptionScrollView *)existingCell forRowAtIndex:(int)index withFrame:(CGRect)frame {
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
    ImageManager* imageManager = [ImageManager getInstance];
//    existingCell.frc_captions = nil;
//    existingCell.frame = frame;
//    existingCell.photo = photo;
    [existingCell resetWithFrame:frame withPhoto:photo];
   // [existingCell initWithFrame:frame withPhoto:photo];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:existingCell forKey:an_IMAGEVIEW];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
    
    [existingCell displayImage:image];
 
    
}

- (UIView*)viewSlider:(UIPagedViewSlider2 *)viewSlider cellForRowAtIndex:(int)index withFrame:(CGRect)frame {
   
       Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        UIPhotoCaptionScrollView* photoAndCaptionScrollView = [[UIPhotoCaptionScrollView alloc]initWithFrame:frame withPhoto:photo];
        
        photoAndCaptionScrollView.viewController = nil;
        ImageManager* imageManager = [ImageManager getInstance];
        
       
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photoAndCaptionScrollView forKey:an_IMAGEVIEW];
        UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
        
        [photoAndCaptionScrollView displayImage:image];
        
//        [self configureCaptionSlider:zoomingScrollView forPhotoAtIndex:index];
        return photoAndCaptionScrollView;

}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    int numCellsLeft = [[self.frc_photos fetchedObjects]count] - index;
    
    if (numCellsLeft < threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
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

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete {
    
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [self.pagedViewSlider onNewItemInsertedAt:newIndexPath.row];
        [self.pagedViewSlider tilePages];
    }
}
@end
