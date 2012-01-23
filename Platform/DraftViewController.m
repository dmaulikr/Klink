//
//  DraftViewController2.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DraftViewController.h"
#import "Macros.h"
#import "UIDraftTableViewCell.h"
#import "DateTimeHelper.h"
#import "CloudEnumeratorFactory.h"
#import "AuthenticationManager.h"
#import "UINotificationIcon.h"
#import "UICameraActionSheet.h"
#import "Types.h"
#import "Attributes.h"
#import "Photo.h"
#import "Page.h"
#import "User.h"
#import "FullScreenPhotoViewController.h"
#import "ContributeViewController.h"
#import "ProfileViewController.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "NotificationsViewController.h"
#import "ProductionLogViewController.h"

#define kPAGEID @"pageid"
#define kDRAFTTABLEVIEWCELLHEIGHT_TOP 320
#define kDRAFTTABLEVIEWCELLHEIGHT_LEFTRIGHT 115

@implementation DraftViewController
@synthesize frc_photos = __frc_photos;
@synthesize pageID = m_pageID;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize lbl_deadline = m_lbl_deadline;
//@synthesize lbl_deadlineNavBar = m_lbl_deadlineNavBar;
@synthesize deadline = m_deadline;
@synthesize tbl_draftTableView = m_tbl_draftTableView;
@synthesize photoCloudEnumerator = m_photoCloudEnumerator;
@synthesize captionCloudEnumerator = m_captionCloudEnumerator;
@synthesize refreshHeader = m_refreshHeader;
@synthesize frc_captions = __frc_captions;
@synthesize v_typewriter                = m_v_typewriter;
@synthesize btn_profileButton           = m_btn_profileButton;
@synthesize btn_cameraButton            = m_btn_cameraButton;
@synthesize btn_notificationsButton     = m_btn_notificationsButton;
@synthesize btn_notificationBadge       = m_btn_notificationBadge;
@synthesize shouldOpenTypewriter        = m_shouldOpenTypewriter;
@synthesize shouldCloseTypewriter       = m_shouldCloseTypewriter;
@synthesize btn_backButton              = m_btn_backButton;

#pragma mark - Deadline Date Timers
- (void) timeRemaining:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    NSTimeInterval remaining = [self.deadline timeIntervalSinceDate:now];
    self.lbl_deadline.text = [NSString stringWithFormat:@"deadline: %@", [DateTimeHelper formatTimeInterval:remaining]];
    //self.lbl_deadlineNavBar.text = [NSString stringWithFormat:@"deadline: %@", [DateTimeHelper formatTimeInterval:remaining]];
}

#pragma mark - Properties
- (NSFetchedResultsController*) frc_captions {
    NSString* activityName = @"UIDraftViewController.frc_photos:";
    
    if (__frc_captions != nil) {
        return __frc_captions;
    }
    else {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:resourceContext.managedObjectContext];
        
        NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
        NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
        
        NSMutableArray* sortDescriptorArray = [NSMutableArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
        
        //add predicate to gather only photos for this pageID    
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", PAGEID, self.pageID];
        
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
            LOG_UIDRAFTVIEW(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        
        [sortDescriptor1 release];
        [sortDescriptor2 release];
        [controller release];
        [fetchRequest release];
        
        return __frc_captions;
    }
}


- (NSFetchedResultsController*) frc_photos {
    NSString* activityName = @"UIDraftViewController.frc_photos:";
    
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    else {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
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
            LOG_UIDRAFTVIEW(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        
        [sortDescriptor1 release];
        [sortDescriptor2 release];
        [controller release];
        [fetchRequest release];
        
        return __frc_photos;
    }
}

#pragma mark - Typewriter open animation
- (void) typewriterOpenView:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToOpen.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToOpen.hidden = NO;
    //[self.view bringSubviewToFront:viewToOpen];
    
    // disable the view so it’s not doing anything while animating
    viewToOpen.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the bottom edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToOpen.layer.anchorPoint.y != 1.0f) {
        //viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToOpen.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        //viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
        viewToOpen.center = CGPointMake(viewToOpen.center.x, viewToOpen.center.y);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // start the animation from the current state
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                           -1.0f,
                                                           0.0f,
                                                           0.0f);
    // these values control the 3D projection outlook
    endTransform.m34 = 0.001f;
    endTransform.m24 = 0.0015f;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:endTransform];
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToOpen.tag] forKey:@"viewToOpenTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipViewOpen"];
}

- (void) typewriterCloseView:(UIView *)viewToClose duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToClose.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToClose.hidden = NO;
    //[self.view bringSubviewToFront:viewToClose];
    
    // disable the view so it’s not doing anything while animating
    viewToClose.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the bottom edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToClose.layer.anchorPoint.y != 1.0f) {
        //viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToClose.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        //viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
        viewToClose.center = CGPointMake(viewToClose.center.x, viewToClose.center.y + viewToClose.bounds.size.height/2.0f);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // start the animation from the open state
    // this is the basic rotation by 90 degree along the x-axis
    CATransform3D startTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                             -1.0f,
                                                             0.0f,
                                                             0.0f);
    // these values control the 3D projection outlook
    //startTransform.m34 = 0.001f;
    //startTransform.m14 = -0.0015f;
    startTransform.m34 = 0.001f;
    startTransform.m24 = 0.005f;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:startTransform];
    
    // end the transformation at the default state
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToClose.tag] forKey:@"viewToCloseTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToClose.layer addAnimation:theGroup forKey:@"flipViewClosed"];
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
    // Get the tag from the animation, we use it to find the
    // animated UIView
    NSString *animationKeyClosed = [NSString stringWithFormat:@"flipViewClosed"];
    
    if (flag) {
        for (NSString* animationKey in self.v_typewriter.layer.animationKeys) {
            if ([animationKey isEqualToString:animationKeyClosed]) {
                // typewriter was closed
                
                self.v_typewriter.userInteractionEnabled = YES;
                
            }
            else {
                // typewriter was opened
                
                // Move back to Production Log view controller
                [self.navigationController popViewControllerAnimated:YES];
                
                //[self dismissModalViewControllerAnimated:YES];
                
                // Now we just hide the animated view since
                // animation.removedOnCompletion is not working
                // in animation groups. Hiding the view prevents it
                // from returning to the original state and showing.
                //self.iv_bookCover.hidden = YES;
                //[self.view sendSubviewToBack:self.iv_bookCover];
            }
        }
    }
    
    /*// Get the tag from the animation, we use it to find the
     // animated UIView
     NSNumber *tag = [theAnimation valueForKey:@"viewToOpenTag"];
     // Find the UIView with the tag and do what you want
     // This only searches the first level subviews
     for (UIView *subview in self.view.subviews) {
     if (subview.tag == [tag intValue]) {
     // Code for what's needed to happen after
     // the animation finishes goes here.
     if (flag) {
     // Now we just hide the animated view since
     // animation.removedOnCompletion is not working
     // in animation groups. Hiding the view prevents it
     // from returning to the original state and showing.
     subview.hidden = YES;
     }
     }
     }*/
    
}

- (void)openTypewriter {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = NO;
    
    [self typewriterOpenView:self.v_typewriter duration:0.5f];
}

- (void)closeTypewriter {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = YES;
    
    [self typewriterCloseView:self.v_typewriter duration:0.5f];
}

#pragma mark - Notification Button Handlers
- (void)updateNotificationButton {
    if ([self.authenticationManager isUserAuthenticated]) {
        int unreadNotifications = [User unopenedNotificationsFor:self.loggedInUser.objectid];
        
        if (unreadNotifications > 0) {
            if (unreadNotifications > 99) {
                // limit the label to a count of "99"
                unreadNotifications = 99;
            }
            [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb_lit.png"] forState:UIControlStateNormal];
            
            [self.btn_notificationBadge setTitle:[NSString stringWithFormat:@"%d", unreadNotifications] forState:UIControlStateNormal];
            [self.btn_notificationBadge setHidden:NO];
        }
    }
    else {
        [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb.png"] forState:UIControlStateNormal];
        [self.btn_notificationBadge setHidden:YES];
    }
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
     
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    /*self.tbl_draftTableView = nil;
    self.frc_photos = nil;
    self.pageID = nil;
    self.lbl_deadlineNavBar = nil;*/
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // resister callbacks for change events
    Callback* newCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaption:)];
    Callback* newPhotoVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhotoVote:)];
    Callback* newCaptionVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaptionVote:)];
    
    [self.eventManager registerCallback:newCaptionCallback forSystemEvent:kNEWCAPTION];
    [self.eventManager registerCallback:newPhotoVoteCallback forSystemEvent:kNEWPHOTOVOTE];
    [self.eventManager registerCallback:newCaptionVoteCallback forSystemEvent:kNEWCAPTIONVOTE];
    
    [newCaptionCallback release];
    [newPhotoVoteCallback release];
    [newCaptionVoteCallback release];

    
    // setup pulldown refresh on tableview
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_draftTableView.bounds.size.height, self.tbl_draftTableView.bounds.size.width, self.tbl_draftTableView.bounds.size.height);
    
    EGORefreshTableHeaderView* erthv = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader = erthv;
    [erthv release];
    
    self.refreshHeader.delegate = self;
    self.refreshHeader.backgroundColor = [UIColor clearColor];
    [self.tbl_draftTableView addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
    
    // Navigationbar title label with deadline
    //self.lbl_deadlineNavBar = [[[UILabel alloc]initWithFrame:CGRectMake(140,0, 180, 40)] autorelease];
    //self.lbl_deadlineNavBar.font = [UIFont fontWithName:@"American Typewriter" size: 12.0];
	//self.lbl_deadlineNavBar.text = @"";
	//[self.lbl_deadlineNavBar setBackgroundColor:[UIColor clearColor]];
	//[self.lbl_deadlineNavBar setTextColor:[UIColor whiteColor]];
    //[self.lbl_deadlineNavBar setTextAlignment:UITextAlignmentRight];
    //[self.lbl_deadlineNavBar adjustsFontSizeToFitWidth];
	//self.navigationItem.titleView = self.lbl_deadlineNavBar;
    
    // Setup the animation to show the typewriter
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = YES;
    
    self.navigationController.delegate = self;
    
}

- (void) viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDDRAFTVC]==NO) {
        [userDefaults setBool:YES forKey:setting_HASVIEWEDDRAFTVC];
        [userDefaults synchronize];
    }
    
    if (self.shouldCloseTypewriter) {
        [self closeTypewriter];
    }
    
}
- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"DraftViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    //we check to see if the user has been to this viewcontroller before
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDDRAFTVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Concering Drafts..." message:ui_WELCOME_DRAFT delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        
        self.lbl_draftTitle.text = draft.displayname;
        
        // Show time remaining on draft
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timeRemaining:)
                                       userInfo:nil
                                        repeats:YES];
        
        self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
        self.photoCloudEnumerator.delegate = self;
        
        if ([self.photoCloudEnumerator canEnumerate]) 
        {
            LOG_DRAFTVIEWCONTROLLER(0, @"%@Refreshing production log from cloud",activityName);
            [self.photoCloudEnumerator enumerateUntilEnd:nil];
        }
        else {
            LOG_PRODUCTIONLOGVIEWCONTROLLER(0,@"%@Skipping refresh of production log, as the enumerator is not ready",activityName);
            
            //optionally if there is no draft query being executed, and we are authenticated, then we then refresh the notification feed
            Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
            [[FeedManager instance]tryRefreshFeedOnFinish:callback];
            
        }
    }
    
    // Update notifications button on typewriter
    [self updateNotificationButton];
    
    // Setup back button
    //[self.btn_backButton sizeToFit];
    UIImage* backButtonBackground = [[UIImage imageNamed:@"book_button_back.png"] stretchableImageWithLeftCapWidth:25.0 topCapHeight:0.0];
    UIImage* backButtonHighlightedBackground = [[UIImage imageNamed:@"book_button_back_highlighted.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
    [self.btn_backButton setBackgroundImage:backButtonBackground forState:UIControlStateNormal];
    [self.btn_backButton setBackgroundImage:backButtonHighlightedBackground forState:UIControlStateHighlighted];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.lbl_draftTitle = nil;
    self.lbl_deadline = nil;
    //self.lbl_deadlineNavBar = nil;
    self.tbl_draftTableView = nil;
    self.refreshHeader = nil;
    
    self.v_typewriter = nil;
    self.btn_profileButton = nil;
    self.btn_cameraButton = nil;
    self.btn_notificationsButton = nil;
    self.btn_notificationBadge = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table View Delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        // leading draft, show version of draft table view cell for the leading draft
        return kDRAFTTABLEVIEWCELLHEIGHT_TOP;
    }
    else {
        // else, show version of draft table view cell with image on the right
        return kDRAFTTABLEVIEWCELLHEIGHT_LEFTRIGHT;
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    //[self.tbl_draftTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 63.0f, 0.0f)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //ResourceContext* resourceContext = [ResourceContext instance];
    //Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    Caption* selectedCaption = [[self.frc_captions fetchedObjects]objectAtIndex:[indexPath row]];
    //Photo* selectedPhoto = [[self.frc_photos fetchedObjects] objectAtIndex:[indexPath row]];
    
    // Set up navigation bar back button with draft title
    //self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:page.displayname
    //                                                                          style:UIBarButtonItemStyleBordered
    //                                                                         target:nil
    //                                                                         action:nil] autorelease];
    
    FullScreenPhotoViewController* photoViewController = [FullScreenPhotoViewController createInstanceWithPageID:self.pageID withPhotoID:selectedCaption.photoid withCaptionID:selectedCaption.objectid];
    
    [self.navigationController pushViewController:photoViewController animated:YES];
  
}


#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [[self.frc_photos fetchedObjects]count];
    return [[self.frc_captions fetchedObjects]count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int captionCount = [[self.frc_captions fetchedObjects]count];
    //int photoCount = [[self.frc_photos fetchedObjects]count];
    if ([indexPath row] < captionCount) 
    {
        Caption* caption = [[self.frc_captions fetchedObjects] objectAtIndex:[indexPath row]];
        //Photo* photo = [[self.frc_photos fetchedObjects] objectAtIndex:[indexPath row]];
        
        NSString* reusableCellIdentifier = nil;
        
        if ([indexPath row] == 0) {
            // leading draft, show version of draft table view cell for the leading draft
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierTop];
        }
        else if ([indexPath row] % 2) {
            // row is odd, show version of draft table view cell with image on the left
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierLeft];
        }
        else {
            // row is even, show version of draft table view cell with image on the right
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierRight];
        }
        
        UIDraftTableViewCell* cell = (UIDraftTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UIDraftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellIdentifier]autorelease];
            [cell.btn_writtenBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btn_illustratedBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell renderWithCaptionID:caption.objectid];
         return cell;
    }
    else {
        return nil;
    }
}

//called by the draft view cells whens omeone clicks on the author links in them
- (void) onLinkButtonClicked:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    UIResourceLinkButton* rlb = (UIResourceLinkButton*)sender;
    //extract the user profile id
    ProfileViewController* pvc = [ProfileViewController createInstanceForUser:rlb.objectID];
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:pvc];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

#pragma mark - NSFetchedResultsControllerDelegate
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_draftTableView endUpdates];
    [self.tbl_draftTableView reloadData];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_draftTableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject 
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //new photo has been downloaded
        [self.tbl_draftTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        //[self.tbl_draftTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
      
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tbl_draftTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        //[self.tbl_draftTableView reloadData];
    }
}

#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
    self.photoCloudEnumerator.delegate = self;
    
    [self.photoCloudEnumerator enumerateUntilEnd:nil];
    
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    if (self.photoCloudEnumerator != nil) {
        return [self.photoCloudEnumerator isLoading];
    }
    else {
        return NO;
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    //NSString* activityName = @"DraftViewController.onEnumerateComplete:";
    //we tell the ego fresh header that we've stopped loading items
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_draftTableView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    [self.tbl_draftTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 63.0f, 0.0f)];
    
}


#pragma mark - Callback Event Handlers
- (void) onFeedRefreshComplete:(CallbackResult*)result
{
    // Update notifications button on typewriter
    [self updateNotificationButton];
}
   
- (void) onNewCaption:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
}

- (void) onNewPhotoVote:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
}

- (void) onNewCaptionVote:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
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

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //if ([viewController isKindOfClass:[ProductionLogViewController class]]) {
    //    if (self.shouldOpenTypewriter) {
    //        [self openTypewriter];
    //    }
    //}
}

#pragma mark - Button Handlers
#pragma mark Navigation Button Handlers
- (IBAction) onBackButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = YES;
    
    if (self.shouldOpenTypewriter) {
        [self openTypewriter];
    }
}

#pragma mark Tyewriter Button Handlers
- (void) onProfileButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                              initWithTitle:@"Login Required"
                              message:@"Hello! You must punch-in on the production floor to access your profile.\n\nPlease login, or join us as a new contributor via Facebook."
                              delegate:self
                              onFinishSelector:@selector(onProfileButtonPressed:)
                              onTargetObject:self
                              withObject:nil
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        ProfileViewController* profileViewController = [ProfileViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
    
}

- (void) onCameraButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                              initWithTitle:@"Login Required"
                              message:@"Hello! You must punch-in on the production floor to contribute to this draft.\n\nPlease login, or join us as a new contributor via Facebook."
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
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewPhotoWithPageID:self.pageID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
    }
}

- (void) onNotificationsButtonClicked:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                                    initWithTitle:@"Login Required"
                                    message:@"Hello! You must punch-in on the production floor to see your notifications.\n\nPlease login, or join us as a new contributor via Facebook."
                                    delegate:self
                                    onFinishSelector:@selector(onNotificationsButtonPressed:)
                                    onTargetObject:self
                                    withObject:nil
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        NotificationsViewController* notificationsViewController = [NotificationsViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
}


#pragma mark - Static Initializers
+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID {
    DraftViewController* draftViewController = [[DraftViewController alloc]initWithNibName:@"DraftViewController" bundle:nil];
    draftViewController.pageID = pageID;
    [draftViewController autorelease];
    return draftViewController;
}

+ (DraftViewController*)createInstanceWithPageID:(NSNumber *)pageID 
                                     withPhotoID:(NSNumber *)photoID 
                                   withCaptionID:(NSNumber *)captionID 
{
    //this constructor called by notification view controller to
    //create a draft view controller for the page,photo and caption specified
    DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:pageID];
    return draftViewController;
}


@end
