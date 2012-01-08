//
//  FullScreenPhotoViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FullScreenPhotoViewController.h"
#import "ImageManager.h"
#import "CloudEnumeratorFactory.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "Macros.h"
#import "UICaptionView.h"
#import "ContributeViewController.h"
#import "UICaptionView.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "ApplicationSettings.h"
#import "SocialSharingManager.h"
#import "LandscapePhotoViewController.h"
#import "PlatformAppDelegate.h"
#import "NotificationsViewController.h"
#import "DraftViewController.h"

#define kPictureWidth               320
#define kPictureHeight              480
#define kPictureSpacing             0

#define kCaptionWidth               320
#define kCaptionHeight              70
#define kCaptionSpacing             0

#define kPHOTOID @"photoid"
#define kIMAGEVIEW @"imageview"

@implementation FullScreenPhotoViewController

@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;

@synthesize captionCloudEnumerator  = m_captionCloudEnumerator;

@synthesize controlVisibilityTimer  = m_controlVisibilityTimer;

@synthesize pageID                  = m_pageID;
@synthesize photoID                 = m_photoID;
@synthesize captionID               = m_captionID;

@synthesize photoViewSlider         = m_photoViewSlider;
@synthesize captionViewSlider       = m_captionViewSlider;
@synthesize photoMetaData           = m_photoMetaData;
@synthesize iv_photo                = m_iv_photo;
@synthesize iv_photoLandscape       = m_iv_photoLandscape;
@synthesize pg_captionPageIndicator = m_pg_captionPageIndicator;
@synthesize iv_leftArrow            = m_iv_leftArrow;
@synthesize iv_rightArrow           = m_iv_rightArrow;

@synthesize tb_facebookButton       = m_tb_facebookButton;
@synthesize tb_twitterButton        = m_tb_twitterButton;
@synthesize tb_cameraButton         = m_tb_cameraButton;
@synthesize tb_voteButton           = m_tb_voteButton;
@synthesize tb_captionButton        = m_tb_captionButton;


#pragma mark - Properties


- (NSFetchedResultsController*) frc_photos {
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    
    if (self.pageID == nil) {
        return nil;
    }
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:resourceContext.managedObjectContext];
    
    
    NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    NSMutableArray* sortDescriptorArray = [NSMutableArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", THEMEID, self.pageID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    [sortDescriptor1 release];
    [sortDescriptor2 release];
    return __frc_photos;
}

- (NSFetchedResultsController*) frc_captions {
    if (__frc_captions != nil) {
        return __frc_captions;
    }
    
    if (self.photoID == nil) {
        return nil;
    }
    ResourceContext* resourceContext = [ResourceContext instance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    NSMutableArray* sortDescriptorArray = [NSMutableArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", PHOTOID, self.photoID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    [sortDescriptor1 release];
    [sortDescriptor2 release];
    
    return __frc_captions;
}

#pragma mark - Toolbar buttons
- (NSArray*) toolbarButtonsForViewController {
    //returns an array with the toolbar buttons for this view controller
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    //add Facebook share button
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* fb =  [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(onFacebookButtonPressed:)];
    self.tb_facebookButton = fb;
    [fb release];
    
    [retVal addObject:self.tb_facebookButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add Twitter share button
    UIBarButtonItem* tb = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(onTwitterButtonPressed:)];
    self.tb_twitterButton = tb;
    [tb release];
    
    [retVal addObject:self.tb_twitterButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];

    //add camera button
    UIBarButtonItem* cb = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"icon-camera2.png"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(onCameraButtonPressed:)];
    self.tb_cameraButton = cb;
    [cb release];
    
    [retVal addObject:self.tb_cameraButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    UIBarButtonItem* vb = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"icon-thumbUp.png"]
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(onVoteButtonPressed:)];
    self.tb_voteButton = vb;
    [vb release];
    [retVal addObject:self.tb_voteButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add draft button
    UIBarButtonItem* capB = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"icon-compose.png"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onCaptionButtonPressed:)];
    self.tb_captionButton = capB;
    [capB release];
    [retVal addObject:self.tb_captionButton];
    [flexibleSpace release];
    
    return retVal;
}

#pragma mark - Initializers
- (void) commonInit {
    // Custom initialization
    
    self.photoViewSlider.delegate = self;
    self.captionViewSlider.delegate = self;
    
    self.photoViewSlider.tableView.pagingEnabled = YES;
    self.captionViewSlider.tableView.pagingEnabled = YES;
    
    self.photoViewSlider.tableView.allowsSelection = NO;
    self.captionViewSlider.tableView.allowsSelection = NO;
    
    [self.photoViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"photo"];
    [self.captionViewSlider initWithWidth:kCaptionWidth withHeight:kCaptionHeight withSpacing:kPictureSpacing useCellIdentifier:@"caption"];
    
    // add photo metadata view
    UIPhotoMetaDataView* pmdv = [[UIPhotoMetaDataView alloc] initWithFrame:self.photoMetaData.frame];
    self.photoMetaData = pmdv;
    [pmdv release];
    
    [self.view addSubview:self.photoMetaData];
  
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self =  [self commonInit];
        
        self.wantsFullScreenLayout = YES;
        
    }
    return self;
}

- (void)dealloc
{
    self.photoViewSlider = nil;
    self.captionViewSlider = nil;
   // [self.photoViewSlider release];
    //[self.captionViewSlider release];
       [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Navigation
- (void)updateNavigation {
    int photoCount = [[self.frc_photos fetchedObjects]count];
    int index = [self.photoViewSlider getPageIndex];
    
    // Navigation Bar Title
	if (photoCount > 0) {
		self.title = [NSString stringWithFormat:@"%i of %i", index+1, photoCount];		
	} else {
		self.title = nil;
	}    
}

- (int) indexOfPhotoWithID:(NSNumber*)photoid {
    //returns the index location within the frc_photos for the photo with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_photos fetchedObjects];
    int index = 0;
    for (Photo* photo in fetchedObjects) {
        if ([photo.objectid isEqualToNumber:photoid]) {
            retVal = index;
            break;
        }
        index++;
    }
    return retVal;
}

- (int) indexOfCaptionWithID:(NSNumber*)captionid {
    //returns the index location within the frc_photos for the photo with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_captions fetchedObjects];
    int index = 0;
    for (Caption* caption in fetchedObjects) {
        if ([caption.objectid isEqualToNumber:captionid]) {
            retVal = index;
            break;
        }
        index++;
    }
    return retVal;
}

#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		//[self.controlVisibilityTimer release];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO] ;
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
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;
	
	// Navigation and tool bars
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [self.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
    // Caption view slider
    [self.captionViewSlider setAlpha:hidden ? 0 : 1];
    
    // Photo metadata
    [self.photoMetaData setAlpha:hidden ? 0 : 1];
    
    
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	//[self hideControlsAfterDelay];
	
}

- (void)hideControls { 
    [self setControlsHidden:YES]; 
}

- (void)showControls { 
    [self cancelControlHiding];
    [self setControlsHidden:NO];
}

- (void)toggleControls { 
    [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; 
}

- (void)showHideArrows {
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:( UIViewAnimationCurveEaseInOut )
                     animations:^{
                         [self.iv_leftArrow setAlpha:1];
                         [self.iv_rightArrow setAlpha:1];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:1
                                             options:( UIViewAnimationCurveEaseInOut )
                                          animations:^{
                                              [self.iv_leftArrow setAlpha:0];
                                              [self.iv_rightArrow setAlpha:0];
                                          }
                                          completion:nil];
                     }];
    
}

#pragma mark - View lifecycle
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void) enumerateCaptionsFromCloudForPhoto:(Photo*)photo 
{
    NSString* activityName = @"FullScreenPhotoViewController.enumerateCaptionsFromCloud:";
    //we need to see how many captions the photo has, if we do not have all of the captions, we execute an enumeration
    int numCaptionsInPhotos = [photo.numberofcaptions intValue];
    int numCaptionsInStore = [[self.frc_captions fetchedObjects]count];
    
  //  if (numCaptionsInStore < numCaptionsInPhotos) 
  //  {
        self.captionCloudEnumerator = [CloudEnumerator enumeratorForCaptions:self.photoID];
        self.captionCloudEnumerator.delegate = self; 
        LOG_FULLSCREENPHOTOVIEWCONTROLLER(0, @"%@Number of captions in store %d does not match number of captions specified in photo %d, re-enumerating from cloud",activityName,numCaptionsInStore, numCaptionsInPhotos);
        [self.captionCloudEnumerator enumerateUntilEnd:nil];
  //  }


    
}
- (void) renderPhoto {
    NSString* activityName = @"FullScreenPhotoViewController.renderPhoto:";
    
    //retrieves and draws the layout for the current Photo
    ResourceContext* resourceContext = [ResourceContext instance];
    Photo* currentPhoto = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    
    if (currentPhoto != nil) {
        int indexOfPhoto = [self indexOfPhotoWithID:self.photoID];
        //we instruct the page view slider to move to the index of the page which is specified
        [self.photoViewSlider goTo:indexOfPhoto withAnimation:NO];
        
        // only enumerate captions from this view controller if it was initiated by the NotificationsViewController,
        // otherwise, the DraftViewController has already initialed the captionCloudEnumerator and we should not do it again
        /*if ([self.navigationController.topViewController isKindOfClass:[DraftViewController class]]) {
            [self enumerateCaptionsFromCloudForPhoto:currentPhoto];
        }*/
        
        [self enumerateCaptionsFromCloudForPhoto:currentPhoto];
        
        if (self.captionID == nil) {
            [self.captionViewSlider goTo:0 withAnimation:NO];
            
            int captionCount = [[self.frc_captions fetchedObjects]count];
            if (captionCount > 0) {
                int index = [self.captionViewSlider getPageIndex];
                Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
                self.captionID = caption.objectid;
            }
            else {
                self.captionID = nil;
            }
        }
        else {
            //a caption ID has been set, lets scroll to that caption
            int indexOfCaption = [self indexOfCaptionWithID:self.captionID];
            [self.captionViewSlider goTo:indexOfCaption withAnimation:NO];
        }
        
        // update the metadata for the current photo being displayed
        [self.photoMetaData renderMetaDataWithID:self.photoID withCaptionID:self.captionID];
        
    }
    else {
        //error state
        LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Could not find photo with id: %@ in local store",activityName,self.photoID);
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    [self commonInit];
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // we update the toolbar items each time the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
    
    // Render the photo ID specified as a parameter
    if (self.photoID != nil && [self.photoID intValue] != 0) {
        //render the photo specified by the ID passed in
        [self renderPhoto];
    }
    else {
        //need to find the latest photo
        ResourceContext* resourceContext = [ResourceContext instance];
        Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withValueEqual:nil forAttribute:nil sortBy:DATECREATED sortAscending:NO];
        if (photo != nil) {
            //local store does contain photos to enumerate
            self.photoID = photo.objectid;
            [self renderPhoto];
            
        }
        else {
            //empty photo store, will need to thow up a progress dialog to show user of download
            [self enumerateCaptionsFromCloudForPhoto:photo];
            //TODO: need to make a call to a centrally hosted busy indicator view
        }
    }
    
	// Navigation
	[self updateNavigation];
    
    [self cancelControlHiding];

}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    

    
    // Setup notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    // Add flag for review button to navigation bar
    /*UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"icon-flag.png"]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(onFlagButtonPressed:)];*/
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(onFlagButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
  
    
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
    return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Landscape Photo Rotation Event Handler
- (void) didRotate {
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        // hide all the other controls on the screen, including the photo view slider
        //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        //[self.navigationController.navigationBar setAlpha:0];
        //[self.navigationController.toolbar setAlpha:0];
        [self.photoMetaData setHidden:YES];
        [self.photoViewSlider setHidden:YES];
        [self.captionViewSlider setHidden:YES];
        [self hideControlsAfterDelay:0.25];
        
        // set the current image on the landscape image view
        if (self.iv_photo.image) {
            self.iv_photoLandscape.image = self.iv_photo.image;
        }
        else {
            self.iv_photoLandscape.backgroundColor = [UIColor redColor];
        }
        
        // unhide the landscape photo view
        [self.iv_photoLandscape setHidden:NO];
        
        /* 
        //An alternate way using modal view controllers
        LandscapePhotoViewController* landscapePhotoView = [LandscapePhotoViewController createInstanceWithPhotoID:self.photoID];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:landscapePhotoView];
        navigationController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [landscapePhotoView release];
        */
        
    }
    else {
        // unhide all the other controls on the screen, including the photo view slider
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        //[self.navigationController.navigationBar setHidden:NO];
        //[self.navigationController.toolbar setHidden:NO];
        [self.photoMetaData setHidden:NO];
        [self.photoViewSlider setHidden:NO];
        [self.captionViewSlider setHidden:NO];
        [self showControls];
        
        // hide the landscape photo view
        [self.iv_photoLandscape setHidden:YES];
        
        // Reenable the gesture recognizer for the photo image view to handle a single tap
        UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
         
        // Set required taps and number of touches
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the photo image view
        [self.iv_photo addGestureRecognizer:oneFingerTap];
        
        //enable gesture events on the photo
        [self.iv_photo setUserInteractionEnabled:YES];
    }
    
}

#pragma mark - Toolbar Button Helpers
- (void) disableFacebookButton {
    self.tb_facebookButton.enabled = NO;
}

- (void) enableFacebookButton {
    self.tb_facebookButton.enabled = YES;
}

- (void) disableTwitterButton {
    self.tb_twitterButton.enabled = NO;
}

- (void) enableTwitterButton {
    self.tb_twitterButton.enabled = YES;
}

- (void) disableVoteButton {
    self.tb_voteButton.enabled = NO;
}

- (void) enableVoteButton {
    self.tb_voteButton.enabled = YES;
}

- (void) enableDisableVoteButton {
    
    int captionCount = [[self.frc_captions fetchedObjects] count];
    
    if (captionCount > 0) {
        
        //[self enableVoteButton];
        
        int index = [self.captionViewSlider getPageIndex];
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        
        if ([caption.hasvoted boolValue] == YES) {
            [self disableVoteButton];
        }
        else {
            [self enableVoteButton];
        }
        
    }
    else {
        [self disableVoteButton];
    }
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if (buttonIndex == 1 && alertView.delegate == self) {
        if (![self.authenticationManager isUserAuthenticated]) {
            // user is not logged in
            [self authenticate:YES withTwitter:NO onFinishSelector:alertView.onFinishSelector onTargetObject:self withObject:nil];
        }
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* activityName = @"FullScreenPhotoViewController.onFlagButtonPressed:";
    
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        
        //we check to ensure the user is logged in first
        if (![self.authenticationManager isUserAuthenticated]) {
            UICustomAlertView *alert = [[UICustomAlertView alloc]
                                        initWithTitle:@"Login Required"
                                        message:@"Hello! You must punch-in on the production floor to flag these items for review.\n\nPlease login, or join us as a new contributor via Facebook."
                                        delegate:self
                                        onFinishSelector:@selector(onFlagButtonPressed:)
                                        onTargetObject:self
                                        withObject:nil
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Login", nil];
            [alert show];
            [alert release];
        }
        else {
            ResourceContext* resourceContext = [ResourceContext instance];
            //we start a new undo group here
            [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
            
            int photoIndex = [self.photoViewSlider getPageIndex];
            Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:photoIndex];
            
            int captionIndex = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:captionIndex];
            
            photo.numberofflags = [NSNumber numberWithInt:([photo.numberofflags intValue] + 1)];
            caption.numberofflags = [NSNumber numberWithInt:([caption.numberofflags intValue] + 1)];
            
           // PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = self.progressView;
            progressView.delegate = self;
            
            //now we need to commit to the store
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            //display progress view on the submission of a vote
            ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
            NSString* message = @"Flagging for review...";
            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
            
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Flagged photo with id: %@ and caption with id: %@ in local store",activityName, photo.objectid, caption.objectid);
        }
    }
}

#pragma mark - Navigation Bar Button Event Handlers
- (void) onFlagButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Is this item offensive?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Flag for review"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}


#pragma mark - Toolbar Button Event Handlers
- (void) onFacebookButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onFacebookButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        // PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = self.progressView;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        progressView.delegate = self;
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        int count = [[self.frc_captions fetchedObjects]count];
        if (count > 0) {
            //[self disableFacebookButton];
            int index = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            [sharingManager shareCaptionOnFacebook:caption.objectid onFinish:nil trackProgressWith:progressView];
            
            NSString* message = @"Sharing to Facebook...";
            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        }
    }
}

- (void) onTwitterButtonPressed:(id)sender {
    //we check to ensure the user is logged in to Twitter first
    if (![self.authenticationManager isUserAuthenticated] ||
         ![[self.authenticationManager contextForLoggedInUser]hasTwitter]) {
        //user is not logged in, must log in first
        [self authenticate:NO withTwitter:YES onFinishSelector:@selector(onTwitterButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
       //  PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = self.progressView;
        progressView.delegate = self;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        int count = [[self.frc_captions fetchedObjects]count];
        if (count > 0) {
            //[self disableTwitterButton];
            int index = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            [sharingManager shareCaptionOnTwitter:caption.objectid onFinish:nil trackProgressWith:progressView];
            
            NSString* message = @"Sharing to Twitter...";
            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        }
        
      
    }
}

- (void) onCameraButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                              initWithTitle:@"Login Required"
                              message:@"Hello! You must punch-in on the production floor to contribute a new photo on this draft.\n\nPlease login, or join us as a new contributor via Facebook."
                              delegate:self
                              onFinishSelector:@selector(onCameraButtonPressed:)
                              onTargetObject:self
                              withObject:nil
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        int index = [self.photoViewSlider getPageIndex];
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        self.photoID = photo.objectid;
        
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewPhotoWithPageID:self.pageID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
      
    }
}

- (void) onVoteButtonPressed:(id)sender {
    NSString* activityName = @"FullScreenPhotoViewController.onVoteButtonPressed:";
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                              initWithTitle:@"Login Required"
                              message:@"Hello! You must punch-in on the production floor to vote up this caption.\n\nPlease login, or join us as a new contributor via Facebook."
                              delegate:self
                              onFinishSelector:@selector(onVoteButtonPressed:)
                              onTargetObject:self
                              withObject:nil
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        ResourceContext* resourceContext = [ResourceContext instance];
        //we start a new undo group here
        [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        
        int photoIndex = [self.photoViewSlider getPageIndex];
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:photoIndex];
        
        int captionIndex = [self.captionViewSlider getPageIndex];
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:captionIndex];
        
        photo.numberofvotes = [NSNumber numberWithInt:([photo.numberofvotes intValue] + 1)];
        caption.numberofvotes = [NSNumber numberWithInt:([caption.numberofvotes intValue] + 1)];
        
        // PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = self.progressView;
        progressView.delegate = self;
        
        //now we need to commit to the store
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        
        //display progress view on the submission of a vote
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        NSString* message = @"Submitting your vote...";
        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        
        //update photo and caption metadata views
        [self.photoMetaData renderMetaDataWithID:photo.objectid withCaptionID:caption.objectid];
        
        UICaptionView* currentCaptionView = (UICaptionView *)[[self.captionViewSlider getVisibleViews] objectAtIndex:0];
        if ([currentCaptionView.captionID isEqualToNumber:caption.objectid]) {
            [currentCaptionView renderCaptionWithID:caption.objectid];
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Vote metadata update for photo with id: %@ and caption with id: %@ in local store",activityName,photo.objectid, caption.objectid);
        }
        
        caption.hasvoted = [NSNumber numberWithBool:YES];
        
        // Disable the vote button for this caption
        [self disableVoteButton];
    }
    
}

- (void) onCaptionButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                              initWithTitle:@"Login Required"
                              message:@"Hello! You must punch-in on the production floor to contribute a new caption on this photo.\n\nPlease login, or join us as a new contributor via Facebook."
                              delegate:self
                              onFinishSelector:@selector(onCaptionButtonPressed:)
                              onTargetObject:self
                              withObject:nil
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        int index = [self.photoViewSlider getPageIndex];
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        self.photoID = photo.objectid;
        
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewCaptionWithPageID:self.pageID withPhotoID:photo.objectid];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
       
    }
}

#pragma mark - MBProgressHudDelegate members
- (void) hudWasHidden:(MBProgressHUD *)hud {
    //when the hud is hidden we need to remove it from this view
    [self hideProgressBar];
    
    UIProgressHUDView* pv = (UIProgressHUDView*)hud;
    
    if (!pv.didSucceed) {
        //there was an error upon submission
        //we undo the request that was attempted to be made
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        //update photo and caption metadata views
        [self.photoMetaData renderMetaDataWithID:self.photoID withCaptionID:self.captionID];
        
        UICaptionView* currentCaptionView = (UICaptionView *)[[self.captionViewSlider getVisibleViews] objectAtIndex:0];
        if ([currentCaptionView.captionID isEqualToNumber:self.captionID]) {
            [currentCaptionView renderCaptionWithID:self.captionID];
            
        }

        
    }

}
#pragma mark - UIPagedViewSlider2Delegate
- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:         (int)                   index 
             withFrame:         (CGRect)                frame {
    
    if (viewSlider == self.photoViewSlider) {
        int photoCount = [[self.frc_photos fetchedObjects]count];
        
        if (photoCount > 0 && index < photoCount) {
            //setup the photo imageview
            UIImageView* iv = [[UIImageView alloc] initWithFrame:frame];
            self.iv_photo = iv;
            [iv release];
            
            [self.iv_photo setContentMode:UIViewContentModeScaleAspectFit];
            
            // Create gesture recognizer for the photo image view to handle a single tap
            UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
            
            // Set required taps and number of touches
            [oneFingerTap setNumberOfTapsRequired:1];
            [oneFingerTap setNumberOfTouchesRequired:1];
            
            // Add the gesture to the photo image view
            [self.iv_photo addGestureRecognizer:oneFingerTap];
            
            //enable gesture events on the photo
            [self.iv_photo setUserInteractionEnabled:YES];            
            
            [self viewSlider:viewSlider configure:self.iv_photo forRowAtIndex:index withFrame:frame];
            return self.iv_photo;
        }
        else {
            return nil;
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            UICaptionView* v_caption = [[[UICaptionView alloc] initWithFrame:frame]autorelease];
            [self viewSlider:viewSlider configure:v_caption forRowAtIndex:index withFrame:frame];
            return v_caption;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    
    if (viewSlider == self.photoViewSlider) {
        int photoCount = [[self.frc_photos fetchedObjects]count];
        
        if (photoCount > 0 && index < photoCount) {
            Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
            
            self.photoID = photo.objectid;
            
            int captionCount = [[self.frc_captions fetchedObjects]count]; 
            if (captionCount > 0) {
                self.captionViewSlider.hidden = NO;
                int index = [self.captionViewSlider getPageIndex];
                Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
                self.captionID = caption.objectid;
            }
            else {
                self.captionID = nil;
                self.captionViewSlider.hidden = YES;
            }
            
            existingCell.frame = frame;
            
            self.iv_photo = (UIImageView*)existingCell;
            
            ImageManager* imageManager = [ImageManager instance];
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.iv_photo forKey:kIMAGEVIEW];
            
            //add the photo id to the context
            [userInfo setValue:photo.objectid forKey:kPHOTOID];
            
            if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
                [callback release];
                if (image != nil) {
                    [self.iv_photo setContentMode:UIViewContentModeScaleAspectFit];
                    self.iv_photo.image = image;
                    
                    //enable gesture events on the photo
                    [self.iv_photo setUserInteractionEnabled:YES];
                }
                else {
                    // show the photo placeholder icon
                    [self.iv_photo setContentMode:UIViewContentModeCenter];
                    self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
                    
                    //disable gesture events on the photo
                    [self.iv_photo setUserInteractionEnabled:NO];
                }
            }
            else {
                self.iv_photo.backgroundColor = [UIColor redColor];
                self.iv_photo.image = nil;
            }
            
            [self.photoViewSlider addSubview:self.iv_photo];
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            self.captionID = caption.objectid;
            
            existingCell.frame = frame;
            
            UICaptionView* v_caption = (UICaptionView*)existingCell;
            
            if (caption.caption1 != nil) {
                [v_caption renderCaptionWithID:caption.objectid];
            }
            [self.captionViewSlider addSubview:v_caption];
            
            // Update page indicator for captions
            [self.pg_captionPageIndicator setNumberOfPages:captionCount];
            [self.pg_captionPageIndicator setCurrentPage:index];
            
        }
        else if (captionCount <= 0) {
            self.captionID = nil;
            
            // Hide page indicator for captions
            [self.pg_captionPageIndicator setHidden:YES];
        }
    }
    
    [self enableDisableVoteButton];
    
}

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:         (int)                   index; {
    
    if (viewSlider == self.photoViewSlider) {
        
    }
    else if (viewSlider == self.captionViewSlider) {
        
    }
    
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
     
    if (viewSlider == self.photoViewSlider) {
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        self.photoID = photo.objectid;
        
        // reset frc_captions for the new photo
        self.frc_captions = nil;
        [self.frc_captions fetchedObjects];
        [self.captionViewSlider reset];
        
        // unhide the controls of the view if hidden
        [self showControls];
        
        [self renderPhoto];
        
        [self updateNavigation];
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            self.captionID = caption.objectid;
            
            /*if (index == 0) {
                [self.iv_leftArrow setAlpha:0];
                [self.iv_rightArrow setAlpha:1];
            }
            if (index == captionCount - 1) {
                [self.iv_leftArrow setAlpha:1];
                [self.iv_rightArrow setAlpha:0];
            }
            else {
                [self showHideArrows];
            }*/
        }
        else if (captionCount <= 0) {
            self.captionID = nil;
            //[self.iv_leftArrow setAlpha:0];
            //[self.iv_leftArrow setAlpha:0];
        }
    }
    
    [self enableDisableVoteButton];

}

- (int)   itemCountFor:         (UIPagedViewSlider2*)   viewSlider {
    int count = 0;
    if (viewSlider == self.photoViewSlider) {
        count = [[self.frc_photos fetchedObjects]count];
    }
    else if (viewSlider == self.captionViewSlider) {
        count = [[self.frc_captions fetchedObjects]count];
    }
    return count;
}

#pragma mark - Delegates and Protocols
#pragma mark Image Download Protocol
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"FullScreenPhotoViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    UIImageView* imageView = [userInfo valueForKey:kIMAGEVIEW];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        int count = [[self.frc_photos fetchedObjects]count];
        if (count > 0) {
            int index = [self.photoViewSlider getPageIndex];
            if (index == [self indexOfPhotoWithID:photoID]) {
                //we only draw the image if this view hasnt been repurposed for another draft
                LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
                [imageView performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                //[imageView setNeedsDisplay];
            }
        }
    }
    else {
        imageView.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
}

#pragma mark CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    
}

#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    
    if (controller == self.frc_photos) {
        [self.photoViewSlider.tableView beginUpdates];
    }
    else {
        [self.captionViewSlider.tableView beginUpdates];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (controller == self.frc_photos) {
        [self.photoViewSlider.tableView endUpdates];
    }
    else {
        [self.captionViewSlider.tableView endUpdates];
    }
}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"FullScreenPhotoViewController.controller.didChangeObject:";
    if (type == NSFetchedResultsChangeInsert) {
        if (controller == self.frc_photos) {
            //insertion of a new photo
            Resource* resource = (Resource*)anObject;
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
            [self.photoViewSlider onNewItemInsertedAt:[newIndexPath row]];
            [self.photoViewSlider goTo:[newIndexPath row] withAnimation:NO];

            // reset frc_captions for the new photo
            self.frc_captions = nil;
            
            // reset caption slider
            int captionCount = [[self.frc_captions fetchedObjects]count]; 
            if (captionCount > 0) {
                self.captionViewSlider.hidden = NO;
                [self.captionViewSlider reset];
                int index = [self.captionViewSlider getPageIndex];
                Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
                self.captionID = caption.objectid;
            }
            else {
                self.captionViewSlider.hidden = YES;
                self.captionID = nil;
            }
        }
        else if (controller == self.frc_captions) {
            //insertion of a new caption
            self.captionViewSlider.hidden = NO;
            
            Resource* resource = (Resource*)anObject;
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
            [self.captionViewSlider onNewItemInsertedAt:[newIndexPath row]];
            [self.captionViewSlider goTo:[newIndexPath row] withAnimation:NO];
        }
    }
}

#pragma mark - Static Initializers
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID {
    FullScreenPhotoViewController* photoViewController = [[FullScreenPhotoViewController alloc]initWithNibName:@"FullScreenPhotoViewController" bundle:nil];
    photoViewController.pageID = pageID;
    photoViewController.photoID = photoID;
    [photoViewController autorelease];
    return photoViewController;
}

+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber *)pageID withPhotoID:(NSNumber *)photoID withCaptionID:(NSNumber*)captionID 
{
    FullScreenPhotoViewController* photoViewController = [FullScreenPhotoViewController createInstanceWithPageID:pageID withPhotoID:photoID];
    photoViewController.captionID = captionID;
    return photoViewController;
    
}

@end
