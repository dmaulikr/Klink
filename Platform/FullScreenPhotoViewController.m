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
#import "PlatformAppDelegate.h"
#import "NotificationsViewController.h"
#import "DraftViewController.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "PageState.h"
#import "DateTimeHelper.h"
#import "RequestSummaryViewController.h"
#import "UITutorialView.h"
#import "Flurry.h"

#define kPictureWidth               320
#define kPictureHeight              480
#define kPictureSpacing             0

#define kCaptionWidth               320
#define kCaptionHeight              75
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
@synthesize lbl_downloading         = m_lbl_downloading;
//@synthesize pg_captionPageIndicator = m_pg_captionPageIndicator;
@synthesize iv_leftArrow            = m_iv_leftArrow;
@synthesize iv_rightArrow           = m_iv_rightArrow;

@synthesize tb_facebookButton       = m_tb_facebookButton;
@synthesize tb_twitterButton        = m_tb_twitterButton;
@synthesize tb_cameraButton         = m_tb_cameraButton;
@synthesize tb_voteButton           = m_tb_voteButton;
@synthesize tb_captionButton        = m_tb_captionButton;

@synthesize isSinglePhotoAndCaption = m_isSinglePhotoAndCaption;

@synthesize btn_info                = m_btn_info;

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
    NSPredicate* predicate;
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    if ([draft.state intValue] == kPUBLISHED || self.isSinglePhotoAndCaption == YES) {
        // if this draft has been published, we need to grab only the specific photo and caption requested
        predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", THEMEID, self.pageID, OBJECTID, self.photoID];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", THEMEID, self.pageID];
    }
    
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
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", PHOTOID, self.photoID];
    
    //add predicate to gather only photos for this pageID
    NSPredicate* predicate;
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    if ([draft.state intValue] == kPUBLISHED || self.isSinglePhotoAndCaption == YES) {
        // if this draft has been published, we need to grab only the specific photo and caption requested
        predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", PHOTOID, self.photoID, OBJECTID, self.captionID];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", PHOTOID, self.photoID];
    }
    
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
    
    //self.captionViewSlider.tableView.showsVerticalScrollIndicator = NO;
    
    [self.photoViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"photo"];
    [self.captionViewSlider initWithWidth:kCaptionWidth withHeight:kCaptionHeight withSpacing:kCaptionSpacing useCellIdentifier:@"caption"];
    
    /*// add photo metadata view
    UIPhotoMetaDataView* pmdv = [[UIPhotoMetaDataView alloc] initWithFrame:self.photoMetaData.frame];
    self.photoMetaData = pmdv;
    [pmdv release];
    
    [self.view addSubview:self.photoMetaData];*/
  
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
    self.frc_photos = nil;
    self.frc_captions = nil;
    self.pageID = nil;
    self.photoID = nil;
    self.captionID = nil;
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

- (void) markCaptionRead {
    ResourceContext* resourceContext = [ResourceContext instance];
    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.captionID];
    
    // mark the caption as read if it has not been already
    if ([caption.hasseen boolValue] == NO) {
        caption.hasseen = [NSNumber numberWithBool:YES];
        //also mark the page
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        page.numberofunreadcaptions  =[NSNumber numberWithInt:[page calculateNumberOfUnreadCaptions]];
        
        //save the change
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
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
	
	// Navigation bar
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    
    // Toolbar
    [self.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // Caption view slider
        [self.captionViewSlider setAlpha:hidden ? 0 : 1];
    }
    else {
        // Always ensure the caption slider is hidden in ladscape mode
        [self.captionViewSlider setAlpha:0];
    }
    
    // Photo metadata
    //[self.photoMetaData setAlpha:hidden ? 0 : 1];
    
    // Caption page indicator
    //[self.pg_captionPageIndicator setAlpha:hidden ? 0 : 1];
    
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

- (void)showHideLeftArrow:(BOOL)leftArrow rightArrow:(BOOL)rightArrow {
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:( UIViewAnimationCurveEaseInOut )
                     animations:^{
                         [self.iv_leftArrow setAlpha:leftArrow ? 1 : 0];
                         [self.iv_rightArrow setAlpha:rightArrow ? 1 : 0];
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

- (void) disableCaptionButton {
    self.tb_captionButton.enabled = NO;
}

- (void) enableCaptionButton {
    self.tb_captionButton.enabled = YES;
}

- (void) disableCameraButton {
    self.tb_cameraButton.enabled = NO;
}

- (void) enableCameraButton {
    self.tb_cameraButton.enabled = YES;
}

- (void) enableDisableVoteButton {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    NSDate* deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
    
    int captionCount = [[self.frc_captions fetchedObjects] count];
    int index = [self.captionViewSlider getPageIndex];
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
    
    if (self.loggedInUser.objectid && [self.loggedInUser.objectid isEqualToNumber:caption.creatorid]) {
        // if this caption belongs to the currently logged in user, we then disable the voting button
        [self disableVoteButton];
    }
    else if ([draft.state intValue] == kCLOSED || [draft.state intValue] == kPUBLISHED || [deadline compare:[NSDate date]] == NSOrderedAscending) {
        // if this draft has expired, we need to disable the the vote buttons
        [self disableVoteButton];
    }
    else if (captionCount > 0) {
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

#pragma mark - View lifecycle

- (void) enumerateCaptionsFromCloudForPhoto:(Photo*)photo 
{
    NSString* activityName = @"FullScreenPhotoViewController.enumerateCaptionsFromCloud:";
    //we need to see how many captions the photo has, if we do not have all of the captions, we execute an enumeration
    int numCaptionsInPhotos = [photo.numberofcaptions intValue];
    int numCaptionsInStore = [[self.frc_captions fetchedObjects]count];
    
  //  if (numCaptionsInStore < numCaptionsInPhotos) 
  //  {
        //[self.captionCloudEnumerator reset];
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
        //[self.photoMetaData renderMetaDataWithID:self.photoID withCaptionID:self.captionID];
        
    }
    else {
        //error state
        LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Could not find photo with id: %@ in local store",activityName,self.photoID);
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    // Setup notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    

    [self commonInit];
    
    // we update the toolbar items each time the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    // Render the photo ID specified as a parameter
    if (self.photoID != nil && [self.photoID intValue] != 0) {
        //render the photo specified by the ID passed in
        [self renderPhoto];
    }
    else {
        //need to find the latest photo
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
	//[self updateNavigation];
    
    // Set Navigation bar title style with typewriter font
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    self.title = [NSString stringWithFormat:@"%@", draft.displayname];
    CGSize labelSize = [self.title sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = self.navigationItem.title;
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
    // if this draft has expired, we need to disable the the vote and caption buttons
    NSDate* deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
    if ([draft.state intValue] == kCLOSED || [draft.state intValue] == kPUBLISHED || [deadline compare:[NSDate date]] == NSOrderedAscending) {        
        [self disableCameraButton];
        [self disableCaptionButton];
        [self disableVoteButton];
    }
    else {
        if (self.isSinglePhotoAndCaption == NO) {
            // The draft is still active. Add flag for review button to navigation bar
            UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                            initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                            target:self
                                            action:@selector(onFlagButtonPressed:)];
            self.navigationItem.rightBarButtonItem = rightButton;
            [rightButton release];
        }
    }
    
    [self cancelControlHiding];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // Unhide the navigation bar and toolbar
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Set Navigation bar and toolbar style to black translucent
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    [self.navigationController.toolbar setTranslucent:YES];
    [self.navigationController.toolbar setTintColor:nil];
    
//    // If in portrait mode, make sure the landscape image view photo is not in the way
//    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        [self.iv_photoLandscape setHidden:YES];
//    }

    // Adjust layout based on orientation
    [self didRotate];
    
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    [self showControls];
    [self cancelControlHiding];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    // Set status bar style back to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Hide the navigation bar and toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Set Navigation bar and toolbar style back to black
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    [self.navigationController.toolbar setTranslucent:NO];
    [self.navigationController.toolbar setTintColor:nil];
    
    // Remove observer for device orientation change
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"VIEWING_FULLSCREENVIEW" timed:YES];
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDFULLSCREENVC]==NO) 
    {
        [self onInfoButtonPressed:nil];
        [userDefaults setBool:YES forKey:setting_HASVIEWEDFULLSCREENVC];
        [userDefaults synchronize];
    }
    
    // Show/hide the caption slider arrows as appropriate
    int captionCount = [[self.frc_captions fetchedObjects]count];
    if (captionCount > 0) {
        int index = [self.captionViewSlider getPageIndex];
        
        if (index == 0 && captionCount == 1) {
            [self showHideLeftArrow:NO rightArrow:NO];
        }
        else if (index == 0 && captionCount > 1) {
            [self showHideLeftArrow:NO rightArrow:YES];
        }
        else if (index == captionCount - 1) {
            [self showHideLeftArrow:YES rightArrow:NO];
        }
        else {
            [self showHideLeftArrow:YES rightArrow:YES];
        }
    }
    else {
        [self.iv_leftArrow setAlpha:0];
        [self.iv_rightArrow setAlpha:0];
    }
    
    // Mark the currently visible caption read
    if (self.captionID != nil) {
        [self markCaptionRead];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"VIEWING_FULLSCREENVIEW" withParameters:nil];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    // Subviews
    self.photoViewSlider = nil;
    self.captionViewSlider = nil;
    self.photoMetaData = nil;
    self.iv_photo = nil;
    self.iv_photoLandscape = nil;
    self.lbl_downloading = nil;
    //self.pg_captionPageIndicator = nil;
    self.iv_leftArrow = nil;
    self.iv_rightArrow = nil;
    
    // Toolbar Buttons
    self.tb_facebookButton = nil;
    self.tb_twitterButton = nil;
    self.tb_cameraButton = nil;
    self.tb_voteButton = nil;
    self.tb_captionButton = nil;
    
    self.btn_info = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate {
    return YES;
}


#pragma mark - Landscape Photo Rotation Event Handler
- (void) didRotate {
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        // hide all the other controls on the screen, including the photo view slider
        //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        //[self.navigationController.navigationBar setAlpha:0];
        //[self.navigationController.toolbar setAlpha:0];
        [self.navigationController setToolbarHidden:YES animated:NO];
        //[self.photoMetaData setHidden:YES];
        [self.photoViewSlider setHidden:YES];
        [self.captionViewSlider setHidden:YES];
        [self.btn_info setHidden:YES];
        //[self.pg_captionPageIndicator setHidden:YES];
        [self hideControlsAfterDelay:0.25];
        
        
        // set the current image on the landscape image view
        int index = [self.photoViewSlider getPageIndex];
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.iv_photoLandscape forKey:kIMAGEVIEW];
        
        //add the photo id to the context
        [userInfo setValue:self.photoID forKey:kPHOTOID];
        
        if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            if (image != nil) {
                [self.iv_photoLandscape setContentMode:UIViewContentModeScaleAspectFit];
                self.iv_photoLandscape.image = image;
            }
            else {
                // show the photo placeholder icon
                [self.iv_photo setContentMode:UIViewContentModeCenter];
                self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
            }
        }
        else {
            //self.iv_photo.backgroundColor = [UIColor redColor];
            //self.iv_photo.image = nil;
            // show the photo placeholder icon
            [self.iv_photo setContentMode:UIViewContentModeCenter];
            self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
        }
        
        // Enable the gesture recognizer for the photo image view to handle a single tap
        UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
        
        // Set required taps and number of touches
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the photo image view
        [self.iv_photoLandscape addGestureRecognizer:oneFingerTap];
        
        //enable gesture events on the photo
        [self.iv_photoLandscape setUserInteractionEnabled:YES];
        
        // unhide the landscape photo view
        [self.iv_photoLandscape setHidden:NO];
        
    }
    else {
        // unhide all the other controls on the screen, including the photo view slider
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        //[self.navigationController.navigationBar setHidden:NO];
        //[self.navigationController.toolbar setHidden:NO];
        [self.navigationController setToolbarHidden:NO animated:NO];
        //[self.photoMetaData setHidden:NO];
        [self.photoViewSlider setHidden:NO];
        [self.captionViewSlider setHidden:NO];
        [self.btn_info setHidden:NO];
        //[self.pg_captionPageIndicator setHidden:NO];
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

#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if (buttonIndex == 1 && alertView.delegate == self) {
        if (![self.authenticationManager isUserAuthenticated]) {
            // user is not logged in
//            [self authenticate:YES withTwitter:NO onFinishSelector:alertView.onFinishSelector onTargetObject:self withObject:nil];
            Callback* onSuccessCallback = [Callback callbackForTarget:self selector:alertView.onFinishSelector  fireOnMainThread:YES];
            [self authenticateAndGetFacebook:YES getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
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
//            UICustomAlertView *alert = [[UICustomAlertView alloc]
//                                        initWithTitle:ui_LOGIN_TITLE
//                                        message:ui_LOGIN_REQUIRED
//                                        delegate:self
//                                        onFinishSelector:@selector(onFlagButtonPressed:)
//                                        onTargetObject:self
//                                        withObject:nil
//                                        cancelButtonTitle:@"Cancel"
//                                        otherButtonTitles:@"Login", nil];
//            [alert show];
//            [alert release];
            
                      
            [self authenticateAndGetFacebook:NO getTwitter:YES onSuccessCallback:nil onFailureCallback:nil];

        }
        else {
            //display progress view on the submission of a vote
            ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
            NSString* message = @"Flagging for review...";
            NSString* successMessage = @"Item is flagged for review";
            NSString* failureMessage = @"Ooops, something went wrong. Please flag again";
            
            
            [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:[NSArray arrayWithObject:message]];
            
            ResourceContext* resourceContext = [ResourceContext instance];
            //we start a new undo group here
            [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
            
            int photoIndex = [self.photoViewSlider getPageIndex];
            Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:photoIndex];
            
            int captionIndex = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:captionIndex];
            
            photo.numberofflags = [NSNumber numberWithInt:([photo.numberofflags intValue] + 1)];
            caption.numberofflags = [NSNumber numberWithInt:([caption.numberofflags intValue] + 1)];
            
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            progressView.delegate = self;
            
            //now we need to commit to the store
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            
            
            //[self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
            
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
    AuthenticationContext* loggedInContext = [[AuthenticationManager instance]contextForLoggedInUser];
    if (loggedInContext == nil ||
        loggedInContext.hasFacebook == NO) 
    {
        [Flurry logEvent:@"LOGIN_SHARE_FACEBOOK_FULLSCREENVIEW"];
        
        //user is not logged in, must log in first and also ensure they have a facebook account
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onFacebookButtonPressed:)  fireOnMainThread:YES];
        [self authenticateAndGetFacebook:YES getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];

    }
    else {
        [Flurry logEvent:@"SHARE_FACEBOOK_FULLSCREENVIEW"];
        
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
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

- (IBAction) onInfoButtonPressed:(id)sender
{
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewFullScreen"];
    [self.view addSubview:infoView];
    [infoView release];
}

- (void) onTwitterButtonPressed:(id)sender {
    //we check to ensure the user is logged in to Twitter first
    AuthenticationContext* loggedInContext = [[AuthenticationManager instance]contextForLoggedInUser];

    if (loggedInContext == nil ||
        loggedInContext.hasTwitter == NO) 
    {
        [Flurry logEvent:@"LOGIN_SHARE_TWITTER_FULLSCREENVIEW"];
        
        //user is not logged in, must log in first
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onTwitterButtonPressed:)  fireOnMainThread:YES];
     
        [self authenticateAndGetFacebook:NO getTwitter:YES onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    
    }
    else {
        [Flurry logEvent:@"SHARE_TWITTER_FULLSCREENVIEW"];
        
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
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
    if (![self.authenticationManager isUserAuthenticated]) 
    {
        [Flurry logEvent:@"LOGIN_NEW_PHOTO_FULLSCREENVIEW"];
        
        //user is not logged in, must log in first
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onCameraButtonPressed:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    }
    else {
        [Flurry logEvent:@"NEW_PHOTO_FULLSCREENVIEW" timed:YES];
        
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


- (void) processOnVotePressed 
{
    PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    progressView.delegate = self;
    
    
    ResourceContext* resourceContext = [ResourceContext instance];
    //we start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    int photoIndex = [self.photoViewSlider getPageIndex];
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:photoIndex];
    
    int captionIndex = [self.captionViewSlider getPageIndex];
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:captionIndex];
    
    photo.numberofvotes = [NSNumber numberWithInt:([photo.numberofvotes intValue] + 1)];
    caption.numberofvotes = [NSNumber numberWithInt:([caption.numberofvotes intValue] + 1)];
    caption.hasvoted = [NSNumber numberWithBool:YES];
    
    //now we need to commit to the store
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
    
    UICaptionView* currentCaptionView = (UICaptionView *)[[self.captionViewSlider getVisibleViews] objectAtIndex:0];
    if ([currentCaptionView.captionID isEqualToNumber:caption.objectid]) {
        [currentCaptionView setNeedsDisplay];
        [currentCaptionView renderCaptionWithID:caption.objectid];
     //   LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Vote metadata update for photo with id: %@ and caption with id: %@ in local store",activityName,photo.objectid, caption.objectid);
    }
    
    //caption.hasvoted = [NSNumber numberWithBool:YES];
}


- (void) onVoteButtonPressed:(id)sender {
   // NSString* activityName = @"FullScreenPhotoViewController.onVoteButtonPressed:";
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) 
    {
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                              initWithTitle:ui_LOGIN_TITLE
//                              message:ui_LOGIN_REQUIRED
//                              delegate:self
//                              onFinishSelector:@selector(onVoteButtonPressed:)
//                              onTargetObject:self
//                              withObject:nil
//                              cancelButtonTitle:@"Cancel"
//                              otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        [Flurry logEvent:@"LOGIN_LIKE_FULLSCREENVIEW"];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onVoteButtonPressed:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    }
    else 
    {
        [Flurry logEvent:@"LIKE_FULLSCREENVIEW"];
        
        //display progress view on the submission of a vote
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        NSString* message = @"Casting thy approval...";
        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        
        // Disable the vote button for this caption
        [self disableVoteButton];
        
        [self performSelector:@selector(processOnVotePressed) withObject:nil afterDelay:1];
       // [self performSelectorOnMainThread:@selector(processOnVotePressed) withObject:nil waitUntilDone:NO];
        
        
    }
    
}

- (void) onCaptionButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                              initWithTitle:ui_LOGIN_TITLE
//                              message:ui_LOGIN_REQUIRED
//                              delegate:self
//                              onFinishSelector:@selector(onCaptionButtonPressed:)
//                              onTargetObject:self
//                              withObject:nil
//                              cancelButtonTitle:@"Cancel"
//                              otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        
        [Flurry logEvent:@"LOGIN_NEW_CAPTION_FULLSCREENVIEW"];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onCameraButtonPressed:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    }
    else {
        [Flurry logEvent:@"NEW_CAPTION_FULLSCREENVIEW" timed:YES];
        
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
        UICaptionView* currentCaptionView = (UICaptionView *)[[self.captionViewSlider getVisibleViews] objectAtIndex:0];
        if ([currentCaptionView.captionID isEqualToNumber:self.captionID]) {
            [currentCaptionView setNeedsDisplay];
            [currentCaptionView renderCaptionWithID:self.captionID];
            
        }
    }
    else {
        [self.captionViewSlider.tableView reloadData];
        
        //we only show the request summary screen if the Request was not a flag review request
        if (![Request isThisAFlagContentRequest:pv.requests])
        {
            //it is not a flag content request, let us display the request summary screen
            RequestSummaryViewController* rvc = [RequestSummaryViewController createForRequests:pv.requests];
            
            UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:rvc];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:navigationController animated:YES];
            
            [navigationController release];
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
            
            if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
                ImageManager* imageManager = [ImageManager instance];
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.iv_photo forKey:kIMAGEVIEW];
                
                //add the photo id to the context
                [userInfo setValue:photo.objectid forKey:kPHOTOID];
                
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
                [callback release];
                
                if (image != nil) {
                    [self.iv_photo setContentMode:UIViewContentModeScaleAspectFit];
                    self.iv_photo.image = image;
                    
                    [self.lbl_downloading setHidden:YES];
                    
                    //enable gesture events on the photo
                    [self.iv_photo setUserInteractionEnabled:YES];
                }
                else {
                    // show the photo placeholder icon
                    [self.iv_photo setContentMode:UIViewContentModeCenter];
                    self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
                    
                    [self.lbl_downloading setHidden:NO];
                    
                    //disable gesture events on the photo
                    [self.iv_photo setUserInteractionEnabled:NO];
                }
            }
            else {
                //self.iv_photo.backgroundColor = [UIColor redColor];
                //self.iv_photo.image = nil;
                // show the photo placeholder icon
                [self.iv_photo setContentMode:UIViewContentModeCenter];
                self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
                
                [self.lbl_downloading setHidden:YES];
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
            //[self.pg_captionPageIndicator setNumberOfPages:captionCount];
            //[self.pg_captionPageIndicator setCurrentPage:index];
            
        }
        else if (captionCount <= 0) {
            self.captionID = nil;
            
            // Hide page indicator for captions
            //[self.pg_captionPageIndicator setHidden:YES];
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
        
        //[self renderPhoto];
        
        //[self updateNavigation];
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            self.captionID = caption.objectid;
            
            // Show/hide the caption slider arrows as appropriate
            if (index == 0 && captionCount == 1) {
                [self showHideLeftArrow:NO rightArrow:NO];
            }
            else if (index == 0 && captionCount > 1) {
                [self showHideLeftArrow:NO rightArrow:YES];
            }
            else if (index == captionCount - 1) {
                [self showHideLeftArrow:YES rightArrow:NO];
            }
            else {
                [self showHideLeftArrow:YES rightArrow:YES];
            }
            
            // Update page indicator for captions
            //[self.pg_captionPageIndicator setNumberOfPages:captionCount];
            //[self.pg_captionPageIndicator setCurrentPage:index];
            
            // Mark the currently visible caption read
            if (self.captionID != nil) {
                [self markCaptionRead];
            }
        }
        else if (captionCount <= 0) {
            self.captionID = nil;
            [self.iv_leftArrow setAlpha:0];
            [self.iv_rightArrow setAlpha:0];
            
            // Hide page indicator for captions
            //[self.pg_captionPageIndicator setHidden:YES];
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
                [self.lbl_downloading setHidden:YES];
                //[imageView setNeedsDisplay];
            }
        }
    }
    else {
        //imageView.backgroundColor = [UIColor redColor];
        // show the photo placeholder icon
        [self.iv_photo setContentMode:UIViewContentModeCenter];
        self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
        [self.lbl_downloading setHidden:YES];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
}

#pragma mark CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    
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
    photoViewController.isSinglePhotoAndCaption = NO;
    [photoViewController autorelease];
    return photoViewController;
}

+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber *)pageID withPhotoID:(NSNumber *)photoID withCaptionID:(NSNumber*)captionID 
{
    FullScreenPhotoViewController* photoViewController = [FullScreenPhotoViewController createInstanceWithPageID:pageID withPhotoID:photoID];
    photoViewController.captionID = captionID;
    photoViewController.isSinglePhotoAndCaption = NO;
    return photoViewController;
    
}

+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber *)pageID withPhotoID:(NSNumber *)photoID withCaptionID:(NSNumber*)captionID isSinglePhotoAndCaption:(BOOL)isSingle
{
    FullScreenPhotoViewController* photoViewController = [FullScreenPhotoViewController createInstanceWithPageID:pageID withPhotoID:photoID];
    photoViewController.captionID = captionID;
    photoViewController.isSinglePhotoAndCaption = isSingle;
    return photoViewController;
    
}

@end
