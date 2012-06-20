//
//  DraftViewController2.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DraftViewController.h"
#import "Macros.h"
#import "DateTimeHelper.h"
#import "CloudEnumeratorFactory.h"
#import "AuthenticationManager.h"
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
#import "PageState.h"
#import "ApplicationSettings.h"
#import "RequestSummaryViewController.h"
#import "PlatformAppDelegate.h"

#define kPAGEID @"pageid"
#define kDRAFTTABLEVIEWCELLHEIGHT_TOP 320
#define kDRAFTTABLEVIEWCELLHEIGHT_LEFTRIGHT 115

@implementation DraftViewController
@synthesize frc_photos                  = __frc_photos;
@synthesize frc_captions                = __frc_captions;
@synthesize pageID                      = m_pageID;
@synthesize lbl_draftTitle              = m_lbl_draftTitle;
@synthesize lbl_deadline                = m_lbl_deadline;
@synthesize viewedCaptionsArray         = m_viewedCaptionsArray;
//@synthesize lbl_deadlineNavBar          = m_lbl_deadlineNavBar;
@synthesize deadline                    = m_deadline;
@synthesize tbl_draftTableView          = m_tbl_draftTableView;
@synthesize photoCloudEnumerator        = m_photoCloudEnumerator;
@synthesize refreshHeader               = m_refreshHeader;
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
        else {
            [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb.png"] forState:UIControlStateNormal];
            [self.btn_notificationBadge setHidden:YES];
        }
    }
    else {
        [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb.png"] forState:UIControlStateNormal];
        [self.btn_notificationBadge setHidden:YES];
    }
}

#pragma mark - Typewriter Button Helpers
- (void) disableCameraButton {
    self.btn_cameraButton.enabled = NO;
}

- (void) enableCameraButton {
    self.btn_cameraButton.enabled = YES;
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    
    self.viewedCaptionsArray = [[[NSMutableArray alloc] init] autorelease];
     
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
    self.frc_photos = nil;
    self.pageID = nil;
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /*// resister callbacks for change events
    Callback* newCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaption:)];
    Callback* newPhotoVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhotoVote:)];
    Callback* newCaptionVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaptionVote:)];
    
    [self.eventManager registerCallback:newCaptionCallback forSystemEvent:kNEWCAPTION];
    [self.eventManager registerCallback:newPhotoVoteCallback forSystemEvent:kNEWPHOTOVOTE];
    [self.eventManager registerCallback:newCaptionVoteCallback forSystemEvent:kNEWCAPTIONVOTE];
    
    [newCaptionCallback release];
    [newPhotoVoteCallback release];
    [newCaptionVoteCallback release];*/

    
    // setup pulldown refresh on tableview
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_draftTableView.bounds.size.height, self.tbl_draftTableView.bounds.size.width, self.tbl_draftTableView.bounds.size.height);
    
    EGORefreshTableHeaderView* erthv = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader = erthv;
    [erthv release];
    
    self.refreshHeader.delegate = self;
    self.refreshHeader.backgroundColor = [UIColor clearColor];
    [self.tbl_draftTableView addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
    
    // Setup the animation to show the typewriter
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = YES;
    
    self.navigationController.delegate = self;
    
    
    
    
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        
        self.lbl_draftTitle.text = draft.displayname;
        
        // Show time remaining on draft
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        NSTimer* deadlineTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                                  target:self
                                                                selector:@selector(timeRemaining:)
                                                                userInfo:nil
                                                                 repeats:YES];
        [self timeRemaining:deadlineTimer];
        
        //we set the cloudphotoenumerator delegate to this view controller with this pageID
        self.photoCloudEnumerator = nil;
        self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
        self.photoCloudEnumerator.delegate = self;
        
        if (!self.photoCloudEnumerator.isLoading) 
        {
            //enumerator is not loading, so we can go ahead and reset it and run it
            
            if ([self.photoCloudEnumerator canEnumerate]) 
            {
                //LOG_DRAFTVIEWCONTROLLER(0, @"%@Refreshing photo count from cloud",activityName);
                [self.photoCloudEnumerator enumerateUntilEnd:nil];
            }
            else 
            {
                //the enumerator is not ready to run, but we reset it and away we go
                [self.photoCloudEnumerator reset];
                [self.photoCloudEnumerator enumerateUntilEnd:nil];
            }
        }
        
        /*self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
         self.photoCloudEnumerator.delegate = self;
         
         if ([self.photoCloudEnumerator canEnumerate]) 
         {
         LOG_DRAFTVIEWCONTROLLER(0, @"%@Refreshing production log from cloud",activityName);
         [self.photoCloudEnumerator enumerateUntilEnd:nil];
         }
         else {
         LOG_PRODUCTIONLOGVIEWCONTROLLER(0,@"%@Skipping refresh of production log, as the enumerator is not ready",activityName);
         
         //optionally if there is no draft query being executed, and we are authenticated, then we then refresh the notification feed
         //Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
         //[[FeedManager instance]tryRefreshFeedOnFinish:callback];
         
         }*/
    }
    
}

- (void) viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    //we check to see if the user has been to this viewcontroller before
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDDRAFTVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Concering Drafts..." message:ui_WELCOME_DRAFT delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
        //we mark that the user has viewed this viewcontroller at least once
        [userDefaults setBool:YES forKey:setting_HASVIEWEDDRAFTVC];
        [userDefaults synchronize];
    }
    
    /*//we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDDRAFTVC]==NO) {
        [userDefaults setBool:YES forKey:setting_HASVIEWEDDRAFTVC];
        [userDefaults synchronize];
    }*/
    
    if (self.shouldCloseTypewriter) {
        [self closeTypewriter];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"DraftViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    /*//we check to see if the user has been to this viewcontroller before
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDDRAFTVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Concering Drafts..." message:ui_WELCOME_DRAFT delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }*/
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    /*if (draft != nil) {
        
        self.lbl_draftTitle.text = draft.displayname;
        
        // Show time remaining on draft
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        NSTimer* deadlineTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                         target:self
                                       selector:@selector(timeRemaining:)
                                       userInfo:nil
                                        repeats:YES];
        [self timeRemaining:deadlineTimer];
        
        //we set the cloudphotoenumerator delegate to this view controller with this pageID
        self.photoCloudEnumerator = nil;
        self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
        self.photoCloudEnumerator.delegate = self;
        
        if (!self.photoCloudEnumerator.isLoading) 
        {
            //enumerator is not loading, so we can go ahead and reset it and run it
            
            if ([self.photoCloudEnumerator canEnumerate]) 
            {
                LOG_DRAFTVIEWCONTROLLER(0, @"%@Refreshing photo count from cloud",activityName);
                [self.photoCloudEnumerator enumerateUntilEnd:nil];
            }
            else 
            {
                //the enumerator is not ready to run, but we reset it and away we go
                [self.photoCloudEnumerator reset];
                [self.photoCloudEnumerator enumerateUntilEnd:nil];
            }
        }
        
     //   self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
     //   self.photoCloudEnumerator.delegate = self;
     //   
     //   if ([self.photoCloudEnumerator canEnumerate]) 
     //   {
     //       LOG_DRAFTVIEWCONTROLLER(0, @"%@Refreshing production log from cloud",activityName);
     //       [self.photoCloudEnumerator enumerateUntilEnd:nil];
     //   }
     //   else {
     //       LOG_PRODUCTIONLOGVIEWCONTROLLER(0,@"%@Skipping refresh of production log, as the enumerator is not ready",activityName);
            
     //       //optionally if there is no draft query being executed, and we are authenticated, then we then refresh the notification feed
     //       //Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
     //       //[[FeedManager instance]tryRefreshFeedOnFinish:callback];
            
     //   }
    }*/
    
    // refresh the notification feed
    //Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
    //[[FeedManager instance]tryRefreshFeedOnFinish:callback];
    
    // refresh the notification feed
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
    BOOL isEnumeratingFeed = [[FeedManager instance]tryRefreshFeedOnFinish:callback];
    
    if (isEnumeratingFeed) 
    {
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Refreshing user's notification feed",activityName);
    }
    
    // if this draft has expired, we need to disable the the vote and caption buttons
    if ([draft.state intValue] == kCLOSED || [draft.state intValue] == kPUBLISHED || [self.deadline compare:[NSDate date]] == NSOrderedAscending) {
        [self disableCameraButton];
    }
    
    // Update notifications button on typewriter
    [self updateNotificationButton];
    
    /*// Setup back button
    //[self.btn_backButton sizeToFit];
    UIImage* backButtonBackground = [[UIImage imageNamed:@"book_button_back.png"] stretchableImageWithLeftCapWidth:25.0 topCapHeight:0.0];
    UIImage* backButtonHighlightedBackground = [[UIImage imageNamed:@"book_button_back_highlighted.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
    [self.btn_backButton setBackgroundImage:backButtonBackground forState:UIControlStateNormal];
    [self.btn_backButton setBackgroundImage:backButtonHighlightedBackground forState:UIControlStateHighlighted];*/
    
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //process viewed captions
    for (Caption* caption in self.viewedCaptionsArray) {
        caption.hasseen = [NSNumber numberWithBool:YES];
    }
    
    //we should recompute the total of value of unread captions 
    //on the page
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    page.numberofunreadcaptions = [NSNumber numberWithInt:[page calculateNumberOfUnreadCaptions]];
    
    //save the change locally
    [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.lbl_draftTitle = nil;
    self.lbl_deadline = nil;
    self.viewedCaptionsArray = nil;
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
            cell.delegate = self;
            [cell.btn_writtenBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btn_illustratedBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.btn_vote addTarget:self action:@selector(onVoteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell renderWithCaptionID:caption.objectid];
        
        // Show the 2nd place ribbion if this is the second entry in the draft
        if ([indexPath row] == 1) {
            cell.iv_ribbon.hidden = NO;
            cell.lbl_place.hidden = NO;
            cell.iv_unreadCaptionBadge.frame = CGRectMake(251, cell.iv_unreadCaptionBadge.frame.origin.y, cell.iv_unreadCaptionBadge.frame.size.width, cell.iv_unreadCaptionBadge.frame.size.height);
        }
        else if ([indexPath row] % 2) {
            cell.iv_ribbon.hidden = YES;
            cell.lbl_place.hidden = YES;
            cell.iv_unreadCaptionBadge.frame = CGRectMake(293, cell.iv_unreadCaptionBadge.frame.origin.y, cell.iv_unreadCaptionBadge.frame.size.width, cell.iv_unreadCaptionBadge.frame.size.height);
        }
        
        // Add the caption to the array of viewed captions to mark as read later
        if ([caption.hasseen boolValue] == NO) {
            [self.viewedCaptionsArray addObject:caption];
        }
        
//        //setup a tag on the follow button so we can look it up if pressed
//        cell.btn_vote.tag = indexPath.row + 1;
        
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
    NSString* activityName = @"DraftViewController.egoRefreshTableHeaderDidTriggerRefresh:";
    //what we need to do is check if the enumerator is actually running
    //if its running lets not do anything
    //if its not running, we re-create a new one and away we go
    
    if (![self.photoCloudEnumerator isLoading]) 
    {
        //enumerator is not loading
        [self.photoCloudEnumerator reset];
        [self.photoCloudEnumerator enumerateUntilEnd:nil];
    }
    else {
        //enumerator is currently loading, no refresh scheduled
        LOG_DRAFTVIEWCONTROLLER(0,@"%@Skipping refresh of draft view as the enumerator is currently running",activityName);
        [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_draftTableView];
    }
    
    /*//[self.photoCloudEnumerator reset];
    self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
    self.photoCloudEnumerator.delegate = self;
    
    [self.photoCloudEnumerator enumerateUntilEnd:nil];*/
    
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
   
/*- (void) onNewCaption:(CallbackResult*)result {
    //[self.tbl_draftTableView reloadData];
}

- (void) onNewPhotoVote:(CallbackResult*)result {
    //[self.tbl_draftTableView reloadData];
}

- (void) onNewCaptionVote:(CallbackResult*)result {
    //[self.tbl_draftTableView reloadData];
}*/

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
        
        NSArray* visibleRows = [self.tbl_draftTableView indexPathsForVisibleRows];
        
        [self.tbl_draftTableView beginUpdates];
        [self.tbl_draftTableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
        [self.tbl_draftTableView endUpdates]; 
        
    }
    else {
        [self.tbl_draftTableView reloadData];
        
        RequestSummaryViewController* rvc = [RequestSummaryViewController createForRequests:pv.requests];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:rvc];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        
    }
}

#pragma mark - Button Handlers
- (void) processOnVotePressed:(NSNumber *)captionID 
{
    PlatformAppDelegate* appDelegate = (PlatformAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    progressView.delegate = self;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //we start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    Caption* caption = (Caption *)[resourceContext resourceWithType:CAPTION withID:captionID];
    Photo* photo = (Photo *)[resourceContext resourceWithType:PHOTO withID:caption.photoid];
    
    photo.numberofvotes = [NSNumber numberWithInt:([photo.numberofvotes intValue] + 1)];
    caption.numberofvotes = [NSNumber numberWithInt:([caption.numberofvotes intValue] + 1)];
    caption.hasvoted = [NSNumber numberWithBool:YES];
    
    //now we need to commit to the store
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
}

//- (void) onVoteButtonPressed:(id)sender {
//    //we check to ensure the user is logged in first
//    if (![self.authenticationManager isUserAuthenticated]) 
//    {
//        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:nil fireOnMainThread:YES];
//        
//        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
//    }
//    else 
//    {
//        UIButton* btn_vote = (UIButton*)sender;
//        
//        // Disable the vote button for this caption
//        [btn_vote setSelected:!btn_vote.selected];
//        
//        //then we determine from which row the follow button was pressed using the button tag
//        int row = btn_vote.tag - 1;
//        
//        int count = [[self.frc_captions fetchedObjects] count];
//        
//        if (row < count) {
//            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:row];
//            
//            //display progress view on the submission of a vote
//            ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
//            NSString* message = @"Casting thy approval...";
//            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
//            
//            [self performSelector:@selector(processOnVotePressed:) withObject:caption.objectid afterDelay:1];
//            
//            NSArray* visibleRows = [self.tbl_draftTableView indexPathsForVisibleRows];
//            
//            [self.tbl_draftTableView beginUpdates];
//            [self.tbl_draftTableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
//            [self.tbl_draftTableView endUpdates]; 
//        }
//    }
//    
//}

- (void) onVoteButtonPressedForCaptionWithID:(NSNumber *)captionID {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) 
    {
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:nil fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    }
    else 
    {
        //display progress view on the submission of a vote
        ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
        NSString* message = @"Casting thy approval...";
        [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        
        [self performSelector:@selector(processOnVotePressed:) withObject:captionID afterDelay:1];
        
        NSArray* visibleRows = [self.tbl_draftTableView indexPathsForVisibleRows];
        
        [self.tbl_draftTableView beginUpdates];
        [self.tbl_draftTableView reloadRowsAtIndexPaths:visibleRows withRowAnimation:UITableViewRowAnimationNone];
        [self.tbl_draftTableView endUpdates];
    }
    
}

- (void) onCaptionButtonPressedForPhotoWithID:(NSNumber *)photoID {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:nil  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewCaptionWithPageID:self.pageID withPhotoID:photoID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
        
    }
}

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
    
    if (![self.authenticationManager isUserAuthenticated]) 
    {
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                              initWithTitle:ui_LOGIN_TITLE
//                              message:ui_LOGIN_REQUIRED
//                              delegate:self
//                              onFinishSelector:@selector(onProfileButtonPressed:)
//                              onTargetObject:self
//                              withObject:nil
//                              cancelButtonTitle:@"Cancel"
//                              otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onProfileButtonPressed:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
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
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                              initWithTitle:ui_LOGIN_TITLE
//                              message:ui_LOGIN_REQUIRED
//                              delegate:self
//                              onFinishSelector:@selector(onCameraButtonPressed:)
//                              onTargetObject:self
//                              withObject:nil
//                              cancelButtonTitle:@"Cancel"
//                              otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onCameraButtonPressed:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
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
    if (![self.authenticationManager isUserAuthenticated]) 
    {
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                                    initWithTitle:ui_LOGIN_TITLE
//                                    message:ui_LOGIN_REQUIRED
//                                    delegate:self
//                                    onFinishSelector:@selector(onNotificationsButtonPressed:)
//                                    onTargetObject:self
//                                    withObject:nil
//                                    cancelButtonTitle:@"Cancel"
//                                    otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onNotificationsButtonClicked:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];
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
