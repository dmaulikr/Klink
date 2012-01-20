//
//  BookViewControllerBase.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/22/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerBase.h"
#import "Macros.h"
#import "Page.h"
#import "CloudEnumeratorFactory.h"
#import "UINotificationIcon.h"
#import "SocialSharingManager.h"
#import "PageState.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "PlatformAppDelegate.h"
#import "BookViewControllerPageView.h"
#import "BookViewControllerLeaves.h"
#import "CloudEnumerator.h"
#import "ApplicationSettings.h"
#import "UserDefaultSettings.h"
#import "NotificationsViewController.h"
#import "ProfileViewController.h"
#import "ProductionLogViewController.h"

@implementation BookViewControllerBase
@synthesize pageID              = m_pageID;
@synthesize topVotedPhotoID     = m_topVotedPhotoID;
@synthesize frc_published_pages = __frc_published_pages;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;
@synthesize iv_background          = m_iv_background;
@synthesize iv_bookCover           = m_iv_bookCover;
@synthesize captionCloudEnumerator = m_captionCloudEnumerator;
@synthesize shouldOpenBookCover    = m_shouldOpenBookCover;
@synthesize shouldCloseBookCover   = m_shouldCloseBookCover;
@synthesize shouldOpenToTitlePage  = m_shouldOpenToTitlePage;
@synthesize shouldOpenToSpecificPage = m_shouldOpenToSpecificPage;
@synthesize shouldAnimatePageTurn  = m_shouldAnimatePageTurn;

#define kENUMERATIONTHRESHOLD   1

#pragma mark - Properties
//this NSFetchedResultsController will query for all published pages
- (NSFetchedResultsController*) frc_published_pages {
    NSString* activityName = @"BookViewController.frc_published_pages:";
    if (__frc_published_pages != nil) {
        return __frc_published_pages;
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_published_pages = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_published_pages;
    
}

//called when a new page is loaded into the display, will check to see thast given
//the value for kENUMARTIONTHRESHOLD whether to perform an enumeration against the cloud,
//and if so, perform it.
- (void) evaluateAndEnumeratePagesFromCloud:(int)pagesRemaining {
    NSString* activityName = @"BookViewControllerBase.evaluateAndEnumeratePagesFromCloud:";
    //we need to make a check to see how many objects we have left
    //if we are below a threshold, we need to execute a fetch to the server
    
    if (pagesRemaining < kENUMERATIONTHRESHOLD &&
        !self.pageCloudEnumerator.isLoading) {
        //enumerate
        LOG_BOOKVIEWCONTROLLER(0, @"Detected only %d pages remaining, initiating re-enumeration from cloud",activityName,pagesRemaining);
        self.pageCloudEnumerator = nil;
        self.pageCloudEnumerator = [CloudEnumerator enumeratorForPages];
        self.pageCloudEnumerator.delegate = self;
        [self.pageCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location within the frc_published_photos for the photo with the id specified
    NSArray* fetchedObjects = [self.frc_published_pages fetchedObjects];
    int index = 0;
    for (Page* page in fetchedObjects) {
        
        if ([page.objectid isEqualToNumber:pageid]) {
           
            break;
        }
        index++;
    }
    return index;
}

#pragma mark - Book cover open animation
- (void) pageOpenView:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToOpen.layer removeAllAnimations];
    
    // Make sure view is visible
    //viewToOpen.hidden = NO;
    [self.view bringSubviewToFront:viewToOpen];
    
    // disable the view so it’s not doing anything while animating
    viewToOpen.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the left edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToOpen.layer.anchorPoint.x != 0.0f) {
        viewToOpen.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToOpen.center = CGPointMake(viewToOpen.center.x - viewToOpen.bounds.size.width/2.0f, viewToOpen.center.y);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // start the animation from the current state
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                           0.0f,
                                                           -1.0f,
                                                           0.0f);
    // these values control the 3D projection outlook
    endTransform.m34 = 0.001f;
    endTransform.m14 = -0.0015f;
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

- (void) pageCloseView:(UIView *)viewToClose duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToClose.layer removeAllAnimations];
    
    // Make sure view is visible
    //viewToClose.hidden = NO;
    [self.view bringSubviewToFront:viewToClose];
    
    // disable the view so it’s not doing anything while animating
    viewToClose.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the left edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToClose.layer.anchorPoint.x != 0.0f) {
        viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // start the animation from the open state
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D startTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                             0.0f,
                                                             -1.0f,
                                                             0.0f);
    // these values control the 3D projection outlook
    startTransform.m34 = 0.001f;
    startTransform.m14 = -0.0015f;
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
        for (NSString* animationKey in self.iv_bookCover.layer.animationKeys) {
            if ([animationKey isEqualToString:animationKeyClosed]) {
                // book closed, move to production log
                
                // Set up navigation bar back button
                self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                                                          style:UIBarButtonItemStyleBordered
                                                                                         target:nil
                                                                                         action:nil] autorelease];
                
                ProductionLogViewController* productionLogController = [[ProductionLogViewController alloc]initWithNibName:@"ProductionLogViewController" bundle:nil];
                
                // Modal naviation to production log
                UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:productionLogController];
                navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                navigationController.toolbarHidden = NO;
                
                [self presentModalViewController:navigationController animated:YES];
                
                [navigationController release];
                [productionLogController release];
            }
            else {
                // book was opened, hide the cover
                
                // Now we just hide the animated view since
                // animation.removedOnCompletion is not working
                // in animation groups. Hiding the view prevents it
                // from returning to the original state and showing.
                //self.iv_bookCover.hidden = YES;
                [self.view sendSubviewToBack:self.iv_bookCover];
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

- (void)openBook {
    [self pageOpenView:self.iv_bookCover duration:1.0f];
}

- (void)closeBook {
    [self pageCloseView:self.iv_bookCover duration:0.5f];
}


#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (!m_controlsHidden) {
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)setControlsHidden:(BOOL)hidden {
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	
	/*// Get status bar height if visible
     CGFloat statusBarHeight = 0;
     if (![UIApplication sharedApplication].statusBarHidden) {
     CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
     statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
     }
     
     // Status Bar
     if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
     [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
     } else {
     [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
     }
     
     // Get status bar height if visible
     if (![UIApplication sharedApplication].statusBarHidden) {
     CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
     statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
     }
     
     // Set navigation bar frame
     CGRect navBarFrame = self.navigationController.navigationBar.frame;
     navBarFrame.origin.y = statusBarHeight;
     self.navigationController.navigationBar.frame = navBarFrame;*/
    
	[UIView commitAnimations];
	
    // reset the controls hidden flag
    m_controlsHidden = hidden;
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay:5];
	
}

- (void)hideControls { 
    [self setControlsHidden:YES]; 
}

- (void)showControls { 
    [self cancelControlHiding];
    [self setControlsHidden:NO];
}

- (void)toggleControls {
    [self setControlsHidden:!m_controlsHidden]; 
}


#pragma mark - Button Handlers
#pragma mark Book Page Delegate Methods
- (IBAction) onHomeButtonPressed:(id)sender {
    
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onFacebookButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        progressView.delegate = self;
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            [sharingManager sharePageOnFacebook:page.objectid onFinish:nil trackProgressWith:progressView];
            
            NSString* message = @"Sharing page to Facebook...";
            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        }
    }
}

- (IBAction) onTwitterButtonPressed:(id)sender {
    //we check to ensure the user is logged in to Twitter first
    if (![self.authenticationManager isUserAuthenticated] ||
        ![[self.authenticationManager contextForLoggedInUser]hasTwitter]) {
        //user is not logged in, must log in first
        [self authenticate:NO withTwitter:YES onFinishSelector:@selector(onTwitterButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        progressView.delegate = self;
        
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            [sharingManager sharePageOnTwitter:page.objectid onFinish:nil trackProgressWith:progressView];
            
            NSString* message = @"Sharing to Twitter...";
            [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        }
    }
}

#pragma mark Home Page Delegate Methods
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = YES;
    
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = YES;
    self.shouldOpenBookCover = YES;
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
    // navigation to the production log happens after the book is closed
    [self closeBook];
}

- (void) showNotificationViewController
{
    NotificationsViewController* notificationsViewController = [NotificationsViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
    //UINavigationController* navigationController = self.navigationController;
    // [navigationController pushViewController:notificationsViewController animated:NO];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    //[self.navigationController presentModalViewController:notificationsViewController animated:YES];
    [navigationController release];
    
}

- (void) showProfileViewController
{
    ProfileViewController* profileViewController = [ProfileViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    //UINavigationController* navigationController = self.navigationController;
    // [navigationController pushViewController:notificationsViewController animated:NO];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    //[self.navigationController presentModalViewController:notificationsViewController animated:YES];
    [navigationController release];
    
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
    //called when the writer's log button is pressed
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                                    initWithTitle:@"Login Required"
                                    message:@"Hello! You must punch-in on the production floor to access your profile.\n\nPlease login, or join us as a new contributor via Facebook."
                                    delegate:self
                                    onFinishSelector:@selector(onWritersLogButtonClicked:)
                                    onTargetObject:self
                                    withObject:nil
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else 
    {
        int unreadNotifications = [User unopenedNotificationsFor:self.loggedInUser.objectid];
        
        if (unreadNotifications > 0) {
            [self showNotificationViewController];
        }
        else {
            [self showProfileViewController];
        }
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

#pragma mark - MBProgressHUD Delegate Methods
- (void) hudWasHidden:(MBProgressHUD *)hud 
{
        //todo: implement this
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //NSString* activityName = @"BookViewControllerBase.viewDidLoad:";
    
    // let's refresh the feed
    [self.feedManager refreshFeedOnFinish:nil];
    
    self.pageCloudEnumerator = [CloudEnumerator enumeratorForPages];
    self.pageCloudEnumerator.delegate = self;
    
    // Navigation bar buttons
    UIBarButtonItem* homePageButton = [[UIBarButtonItem alloc]initWithTitle:@"Home"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(onHomeButtonPressed:)];
    self.navigationItem.leftBarButtonItem  = homePageButton;
    [homePageButton release];
    
    // by default the book cover should always open on first load
    self.shouldOpenBookCover = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.controlVisibilityTimer invalidate];
    self.controlVisibilityTimer = nil;
    
    self.iv_background = nil;
    self.iv_bookCover = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"BookViewControllerBase.viewWillAppear:";
    
    //Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController.navigationBar setHidden:YES];
    
    int count = [[self.frc_published_pages fetchedObjects] count];
    if (count == 0) {
        //there are no published page objects in local store, update from cloud
        //will need to thow up a progress dialog to show user of download
        LOG_BOOKVIEWCONTROLLER(0, @"%@No local drafts found, initiating query against cloud",activityName);
        [self.pageCloudEnumerator enumerateUntilEnd:nil];
        
        //TODO: need to make a call to a centrally hosted busy indicator view
    }
    
    //we also make a call to try and refres the feed if it hanst already been done
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
    [[FeedManager instance]tryRefreshFeedOnFinish:callback];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self showControls];
    [self cancelControlHiding];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldOpenBookCover) {
        [self openBook];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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


#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"BookViewController.controller.didChangeObject:";
    if (controller == self.frc_published_pages) {
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        Resource* resource = (Resource*)anObject;
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a page
            LOG_BOOKVIEWCONTROLLER(0, @"%@deleted a resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
        }
        
    }
    else {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - FeedRefreshCallback Handler
- (void) onFeedRefreshComplete:(CallbackResult*)result
{
    //insert on feed refresh complete items here, probably the label
}
#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
    NSString* activityName = @"BookViewController.onEnumerateComplete:";
    //on this method we need to enumerate all the captions that are part of the pages
    //to do this, we enumerate through each page and extract the finished caption ID
    //and make a fixed ID enumerate call to it.
    
    //we need to check if this enumeration brought down the entire book or was an optimized query
    //we check by counting the number of query expressions in the enumerator (its a hack, i know)
    //if its 2, then we know it was optimized, if its 1, we brough down the whole book
    if ([[self.pageCloudEnumerator.query attributeExpressions]count] == 1) {
        //it was a complete enumeration
        //we mark the userdefault setting that we have downloaded the whole book
        LOG_BOOKVIEWCONTROLLER(0, @"%@Marking that we have successfully downloaded the book into user settings",activityName);
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:setting_HASDOWNLOADEDBOOK];
    }
    self.captionCloudEnumerator = nil;
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSMutableArray* captionList = [[NSMutableArray alloc]init];
    NSMutableArray* captionTypeList = [[NSMutableArray alloc]init];
    
    for (Page* page in [self.frc_published_pages fetchedObjects]) {
        if (page.finishedcaptionid != nil) {
            //we check to see if ti exists in the local store
            id caption = [resourceContext resourceWithType:CAPTION withID:page.finishedcaptionid];
            if (caption == nil) {
                //caption isnt in local store, add it to the list of captions to be downloaded
                [captionList addObject:page.finishedcaptionid];
                [captionTypeList addObject:CAPTION];
            }
           
        }
    }
    if ([captionList count] > 0) {
        //at this point we have all the captions that are in the frc
        LOG_BOOKVIEWCONTROLLER(0, @"%@ Enumerating %d missing captions from the cloud",activityName,[captionList count]);
        self.captionCloudEnumerator = [CloudEnumerator enumeratorForIDs:captionList withTypes:captionTypeList];
        
        [self.captionCloudEnumerator enumerateUntilEnd:nil];
    }
    [captionList release];
    [captionTypeList release];
}

#pragma mark - Static Initializers
+ (BookViewControllerBase*) createInstance {
    //BookViewControllerBase* instance = [[BookViewControllerBase alloc]initWithNibName:@"BookViewControllerBase" bundle:nil];
    //[instance autorelease];
    //return instance;
    
    // Determine which supported book view controller type to return
	if (NSClassFromString(@"UIPageViewController")) {
		// iOS 5 UIPageViewController style with native page curling
        BookViewControllerPageView* pageViewInstance = [[BookViewControllerPageView alloc]initWithNibName:@"BookViewControllerPageView" bundle:nil];
        // by default the book should always open to the title page on first load
        pageViewInstance.shouldOpenToTitlePage = YES;
        pageViewInstance.shouldOpenToSpecificPage = NO;
        pageViewInstance.shouldAnimatePageTurn = NO;
        [pageViewInstance autorelease];
        return pageViewInstance;
	}
    else {
		// iOS 3-4x LeaveViewController style with custom page curling
        BookViewControllerLeaves* leavesInstance = [[BookViewControllerLeaves alloc]initWithNibName:@"BookViewControllerLeaves" bundle:nil];
        // by default the book should always open to the title page on first load
        leavesInstance.shouldOpenToTitlePage = YES;
        leavesInstance.shouldOpenToSpecificPage = NO;
        leavesInstance.shouldAnimatePageTurn = NO;
        [leavesInstance autorelease];
        return leavesInstance;
	}
}

+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerBase* vc = [BookViewControllerBase createInstance];
    vc.pageID = pageID;
    vc.shouldOpenToTitlePage = NO;
    vc.shouldOpenToSpecificPage = YES;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}


@end
