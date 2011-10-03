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
#import "NSStringGUIDCategory.h"
#import "IDGenerator.h"
#import "ThemeBrowserViewController2.h"
#import "CameraButtonManager.h"
#import "CloudEnumeratorFactory.h"

#define kPictureWidth_landscape     480
#define kPictureWidth               320
#define kPictureHeight              480
#define kPictureHeight_landscape    320
#define kPictureSpacing             0



#define kCaptionTextFieldWidth 320
#define kCaptionTextFieldHeight 100
#define kCaptionTextFieldWidth_landscape 480
#define kCaptionTextFieldHeight_landscape 100


@implementation PhotoViewController
@synthesize currentPhoto            = m_currentPhoto;

@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;
@synthesize previousButton          = m_previousButton;
@synthesize nextButton              = m_nextButton;
@synthesize controlVisibilityTimer  = m_controlVisibilityTimer;
@synthesize pagedViewSlider         = __pagedViewSlider;
@synthesize v_pagedViewSlider;
@synthesize h_pagedViewSlider;
@synthesize photoCloudEnumerator    =m_photoCloudEnumerator;
@synthesize captionButton           =m_captionButton;
@synthesize submitButton            =m_submitButton;
@synthesize tv_captionBox           =__tv_captionBox;
@synthesize v_tv_captionBox;
@synthesize h_tv_captionBox;
@synthesize state = m_state;
@synthesize sv_view = __sv_view;
@synthesize v_sv_view;
@synthesize h_sv_view;
@synthesize cancelCaptionButton     =m_cancelCaptionButton;
@synthesize toolbar;
@synthesize tb_facebookButton       =m_tb_facebookButton;
@synthesize tb_twitterButton        =m_tb_twitterButton;
@synthesize tb_cameraButton         =m_tb_cameraButton;
@synthesize tb_voteButton           =m_tb_voteButton;
@synthesize tb_captionButton        =m_tb_captionButton;


#pragma mark - Property Definitions

- (UIScrollView*) sv_view {
    if (self.view == self.v_portrait) {
        return self.v_sv_view;
        
    }
    else {
        return self.h_sv_view;
    }
}
- (UICaptionTextView*) tv_captionBox {
    if (self.view == self.v_portrait) {
        return self.v_tv_captionBox;
    }
    else {
        return self.h_tv_captionBox;
    }
}

-(UIPagedViewSlider2*)pagedViewSlider {

    if (self.view == self.v_portrait) {
        
        return self.v_pagedViewSlider;
    }
    else {
        return self.h_pagedViewSlider;
    }
}


#pragma mark - UIPhotoCaptionScrollViewDelegate
- (UIPhotoCaptionScrollView*)currentlyDisplayedView {
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:[self.pagedViewSlider getPageIndex]];
    NSArray* currentlyDisplayedViews = [self.pagedViewSlider getVisibleViews];
    for (int i = 0; i < [currentlyDisplayedViews count];i++) {
        UIPhotoCaptionScrollView* photoCaptionView = [currentlyDisplayedViews objectAtIndex:i];
        if ([photoCaptionView.photo.objectid isEqualToNumber:photo.objectid]) {
            return photoCaptionView;
        }
    }
    return nil;
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


- (void) addCaptionButtonToNavigationItem {
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    if (authenticationContext != nil) {
        self.navigationItem.rightBarButtonItem = self.captionButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
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
#pragma mark - Navigation Bar Handlers
- (void) onCaptionButtonPressed:(id)sender {
    [self onEnterEditMode];
    
    
}

- (void) onSubmitButtonPressed:(id)sender {
    NSString* activityName = @"PhotoViewController.onSubmitButtonPressed:";
    
    
    NSString* captionText = [self.tv_captionBox getText];
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:[self.pagedViewSlider getPageIndex]];
    Caption* caption = [Caption captionForPhoto:photo.objectid withText:captionText];
    
    NSManagedObjectContext *appContext = self.managedObjectContext;
    [appContext insertObject:caption];
    
    NSError* error = nil;
    [appContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"Could not save caption to database due to %@",[error description]];
        [BLLog e:activityName withMessage:message];
    }
    
    [self onExitEditMode];
    
    //object is created now we need to upload it to the cloud
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    NSString* notificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onCreateCaptionInCloudComplete:) name:notificationID object:nil];
    [transferManager createObjectInCloud:caption.objectid withObjectType:CAPTION onFinishNotify:notificationID];
    
    //now we need to scroll to the caption and display it for the user
    NSArray* currentlyDisplayedViews = [self.pagedViewSlider getVisibleViews];
    
    for (int i = 0; i < [currentlyDisplayedViews count];i++) {
        UIPhotoCaptionScrollView* photoCaptionView = [currentlyDisplayedViews objectAtIndex:i];
        if ([photoCaptionView.photo.objectid isEqualToNumber:photo.objectid]) {
            [photoCaptionView setVisibleCaption:caption.objectid];
        }
    }
    
    
}

- (void) onCancelButtonPressed:(id)sender {
    [self.tv_captionBox cancel];
    [self onExitEditMode];
}

#pragma mark - Cloud response handlers
- (void) onCreateCaptionInCloudComplete:(NSNotification*)notification {
    NSString* activityName = @"PhotoViewController.onCreateCaptionInCloudComplete:";
    [BLLog v:activityName withMessage:@"Caption uploaded to the cloud successfully"];
}

#pragma mark - View lifecycle

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 60;
        rect.size.height += 60;;
        self.state = kZoomedIn;
                
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += 60;
        rect.size.height -= 60;
        self.state = kNormal;
        
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelControlHiding];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_isInEditMode = NO;
   
    self.h_tv_captionBox.hidden = YES;
    self.v_tv_captionBox.hidden = YES;
    
 
    
    //self.captionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCaptionButtonPressed:)];
    self.submitButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSubmitButtonPressed:)];
    self.cancelCaptionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButtonPressed:)];
    
    [self.h_pagedViewSlider initWithWidth:kPictureWidth_landscape withHeight:kPictureHeight_landscape withSpacing:kPictureSpacing useCellIdentifier:@"fullscreenphoto" ];    
    [self.v_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"fullscreenphoto" ];
    self.v_pagedViewSlider.tableView.pagingEnabled = YES;
//    self.h_pagedViewSlider.pagingScrollView.pagingEnabled = YES;
//    self.v_pagedViewSlider.pagingScrollView.pagingEnabled = YES;
//    [self.h_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];
//    [self.v_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];

    self.photoCloudEnumerator = [[CloudEnumeratorFactory getInstance] enumeratorForPhotos:self.currentTheme.objectid];
    //self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.currentTheme.objectid];
    self.photoCloudEnumerator.delegate = self;
    if ([[self.frc_photos fetchedObjects]count]<threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
    }
      // Toolbar
    toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:self.interfaceOrientation]];
    toolbar.tintColor = nil;
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolbar];
    
    // Toolbar Items
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];    

    
    self.tb_facebookButton = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                             style:UIBarButtonItemStylePlain
                             target:self
                              action:@selector(onFacebookButtonPressed:)];
    
    self.tb_twitterButton = [[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                           style:UIBarButtonItemStylePlain
                           target:self
                             action:@selector(onTwitterButtonPressed:)];
    
    self.tb_cameraButton = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"icon-camera2.png"]
                            style:UIBarButtonItemStylePlain
                            //initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                            target:[CameraButtonManager getInstanceWithViewController:self]
                            action:@selector(cameraButtonPressed:)];
    
    self.tb_voteButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"icon-thumbUp.png"]
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(onVoteButtonPressed:)];
    
    self.tb_captionButton = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-compose.png"]
                             style:UIBarButtonItemStylePlain
                             //initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                             target:self
                             action:@selector(onCaptionButtonPressed:)];
    
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    //UIBarButtonItem* fixedSpaceLeft1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    //UIBarButtonItem* fixedSpaceLeft2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    //UIBarButtonItem* fixedSpaceRight1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    //UIBarButtonItem* fixedSpaceRight2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    //fixedSpaceLeft1.width = 20;
    //fixedSpaceLeft2.width = 34;
    //fixedSpaceRight1.width = 40;
    //fixedSpaceRight2.width = 20;
    
    // Add buttons to the array
    //NSMutableArray *items = [NSMutableArray arrayWithObjects: self.tb_facebookButton, fixedSpaceLeft1, self.tb_twitterButton, fixedSpaceLeft2, self.tb_cameraButton, fixedSpaceRight1, self.tb_voteButton, fixedSpaceRight2, self.tb_captionButton, nil];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects: self.tb_facebookButton, flexSpace, self.tb_twitterButton, flexSpace, self.tb_cameraButton, flexSpace, self.tb_voteButton, flexSpace, self.tb_captionButton, nil];
    
    // Release buttons
    [self.tb_facebookButton release];
    [self.tb_twitterButton release];
    [self.tb_cameraButton release];
    [self.tb_voteButton release];
    [self.tb_captionButton release];
    [flexSpace release];
    //[fixedSpaceLeft1 release];
    //[fixedSpaceLeft2 release];
    //[fixedSpaceRight1 release];
    //[fixedSpaceRight2 release];
    
    // Add array of buttons to toolbar
    [toolbar setItems:items animated:NO];
    
    [photoCaptionView release];
    [photoCaptionView release];
    
    m_wantsFullScreenLayout = YES;
    m_hidesBottomBarWhenPushed = YES;
    
      
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}


- (void) viewWillAppear:(BOOL)animated {
    // Super
	[super viewWillAppear:animated];
	
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 
    [notificationCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:self.view.window];
    
    // Navigation bar
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self addCaptionButtonToNavigationItem];

    
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
    [self.pagedViewSlider goTo:index];
   
    //we inform the view to pre-fetch captions if necessary
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    [photoCaptionView loadViewData];
	
  
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didRotate:(NSNotification*)notification {
    
  /*
  // old code to handle rotation of view 
   
    [super didRotate:notification];
    //need to switch out the ladscape and portrait views
    //populate the sv_sliders as needed
    NSString* captionText = nil;
    
    if (m_isInEditMode) {
        captionText = [self.tv_captionBox getText];
    }

    
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //going to potrait
        
        int currentScrollIndex = [self.pagedViewSlider getPageIndex];
        self.view = self.v_portrait;
        [self.pagedViewSlider goTo:currentScrollIndex];
    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        //going to landscape
        int currentScrollIndex = [self.pagedViewSlider getPageIndex];
        self.view = self.v_landscape;        
        [self.pagedViewSlider goTo:currentScrollIndex];
        
        
    }
    
    //if the view is in edit mode, we need to transfer the contents of the various
    //text boxes between the two
    if (m_isInEditMode) {
        self.tv_captionBox.hidden = NO;
        [self.tv_captionBox setText:captionText];
        [self onEnterEditMode];
    }
    else {
        self.tv_captionBox.hidden = YES;
    }
  */
    
}

#pragma mark - Navigation

// Navigation
- (void)updateNavigation {
    NSArray* photos = [self.frc_photos fetchedObjects];
    int index = [self.pagedViewSlider getPageIndex];
    // Title
	if (photos.count > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", index+1, photos.count];		
	} else {
		self.title = nil;
	}
	
	// Buttons
	self.previousButton.enabled = (index > 0);
	self.nextButton.enabled = (index < photos.count-1);
    
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
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
    
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
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];

    // Captions scrollviewer
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    [photoCaptionView.captionScrollView setAlpha:hidden ? 0 : 1];
    
    // Toolbar
    [toolbar setAlpha:hidden ? 0 : 1];
    
    // Vote and Share buttons
    [photoCaptionView.voteButton setAlpha:hidden ? 0 : 1];
    [photoCaptionView.shareButton setAlpha:hidden ? 0 : 1];
    
    // Photo Credits and Votes
    [photoCaptionView.photoCreditsBackground setAlpha:hidden ? 0 : 0.5];
    [photoCaptionView.photoCreditsLabel setAlpha:hidden ? 0 : 1];
    [photoCaptionView.photoVotesLabel setAlpha:hidden ? 0 : 1];
    
    
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	//[self hideControlsAfterDelay];
	
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


- (CGRect) frameForCaptionTextField {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, self.view.frame.size.height-kCaptionTextFieldHeight_landscape , kCaptionTextFieldWidth_landscape, kCaptionTextFieldHeight_landscape);
    }
    else {
        return CGRectMake(0, self.view.frame.size.height-kCaptionTextFieldHeight , kCaptionTextFieldWidth, kCaptionTextFieldHeight);
    }
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
    int count = [[self.frc_photos fetchedObjects]count];
    
    if (count > 0 && index < count) {
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        ImageManager* imageManager = [ImageManager getInstance];
        
        [existingCell resetWithFrame:frame withPhoto:photo];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:existingCell forKey:an_IMAGEVIEW];
        UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
        
        [existingCell displayImage:image];
    }
    
}

- (UIView*)viewSlider:(UIPagedViewSlider2 *)viewSlider cellForRowAtIndex:(int)index withFrame:(CGRect)frame {
   
    int count = [[self.frc_photos fetchedObjects]count];
    
    if (count > 0 && index < count) {
       Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        UIPhotoCaptionScrollView* photoAndCaptionScrollView = [[UIPhotoCaptionScrollView alloc]initWithFrame:frame withPhoto:photo];
    
        
        
        
        photoAndCaptionScrollView.viewController = self;
        ImageManager* imageManager = [ImageManager getInstance];
                
       
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photoAndCaptionScrollView forKey:an_IMAGEVIEW];
        UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
        
        [photoAndCaptionScrollView displayImage:image];

        
        
//        UIImageView* imageview = [[UIImageView alloc]initWithFrame:frame];
//        imageview.image = image;
//        return imageview;
        return photoAndCaptionScrollView;
    }

}

- (void) adjustNavigationButtons {
    if (m_isInEditMode) {
        self.navigationItem.rightBarButtonItem = self.submitButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    if (index != m_currentIndex) {
        m_currentIndex = index;
        [self adjustNavigationButtons];
    }
    
    int numCellsLeft = [[self.frc_photos fetchedObjects]count] - index;
    
    if (numCellsLeft < threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
    }
    
    [self updateNavigation];
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        [self toggleControls];
    }
    
    //we inform the view to pre-fetch captions if necessary
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    [photoCaptionView loadViewData];
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
       
    }
}

#pragma mark - Keyboard Event Handler
- (void) keyboardWillShow:(NSNotification *)notification {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    NSDictionary* info = [notification userInfo];

    CGSize kbSize = [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.sv_view.contentInset = contentInsets;
    self.sv_view.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, (self.tv_captionBox.frame.origin.y+self.tv_captionBox.frame.size.height)-kbSize.height);
    [self.sv_view setContentOffset:scrollPoint animated:YES];


    
    [UIView commitAnimations];
    
}

- (void) keyboardDidHide:(NSNotification *)notification {
    [self onExitEditMode];
}

#pragma mark - Edit Mode Transitions

- (void) onExitEditMode {
    m_isInEditMode = NO;
   
    self.navigationItem.leftBarButtonItem = self.navigationController.navigationItem.backBarButtonItem;
    [self addCaptionButtonToNavigationItem];
    
    
    //animate the fade out of the text view
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.tv_captionBox.alpha = 0;
    [UIView commitAnimations];
    
    //animate the scrolling down of the view back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];     
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.sv_view.contentInset =  contentInsets;
    self.sv_view.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [self.sv_view setContentOffset:scrollPoint animated:YES];
    
    [UIView commitAnimations];
     self.tv_captionBox.hidden = YES;
    [self.tv_captionBox setText:nil];
}

- (void) onEnterEditMode {
    m_isInEditMode = YES;
    self.navigationItem.leftBarButtonItem = self.cancelCaptionButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.tv_captionBox.hidden = NO;
    self.tv_captionBox.alpha = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; 
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.tv_captionBox cache:YES];
    self.tv_captionBox.alpha = 1;
    
    [self.sv_view bringSubviewToFront:self.tv_captionBox];
    [UIView commitAnimations];
}


#pragma mark - Toolbar Button Handlers

- (void) onVoteButtonPressed:(id)sender {
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    
    [photoCaptionView onVoteUpButtonPressed:self];
    
    [photoCaptionView release];
}

- (void) onFacebookButtonPressed:(id)sender {
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    
    [photoCaptionView onFacebookShareButtonPressed:self];
    
    [photoCaptionView release];
}

- (void) onTwitterButtonPressed:(id)sender {
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    
    [photoCaptionView onTwitterShareButtonPressed:self];
    
    [photoCaptionView release];
}



#pragma mark - UICaptionTextViewDelegate Methods
- (void)captionTextView:(UICaptionTextView *)captionTextView finishedWithString:(NSString *)caption {
    self.tv_captionBox.hidden = YES;
    [captionTextView resignFirstResponder];
    [self onSubmitButtonPressed:nil];
    
}


- (void) onUserLoggedIn {
    [super onUserLoggedIn];
    [self addCaptionButtonToNavigationItem];
}

- (void) onUserLoggedOut {
    [super onUserLoggedOut];
    [self addCaptionButtonToNavigationItem];
}
@end
