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
#import "UIStrings.h"
#import "BookTableOfContentsViewController.h"
#import "FullScreenPhotoViewController.h"
#import "Attributes.h"
#import "UITutorialView.h"
#import "Flurry.h"

@implementation BookViewControllerBase
@synthesize pageID                  = m_pageID;
@synthesize userID                  = m_userID;
@synthesize topVotedPhotoID         = m_topVotedPhotoID;
@synthesize topVotedCaptionID       = m_topVotedCaptionID;
@synthesize frc_published_pages     = __frc_published_pages;
@synthesize pageCloudEnumerator     = m_pageCloudEnumerator;
@synthesize iv_background           = m_iv_background;
@synthesize iv_bookCover            = m_iv_bookCover;
@synthesize captionCloudEnumerator  = m_captionCloudEnumerator;
@synthesize shouldOpenBookCover     = m_shouldOpenBookCover;
@synthesize shouldCloseBookCover    = m_shouldCloseBookCover;
@synthesize shouldOpenToTitlePage   = m_shouldOpenToTitlePage;
@synthesize shouldOpenToSpecificPage = m_shouldOpenToSpecificPage;
@synthesize shouldOpenToLastPage    = m_shouldOpenToLastPage;
@synthesize shouldAnimatePageTurn   = m_shouldAnimatePageTurn;
@synthesize tempLastViewedPage      = m_tempLastViewedPage;

#define kENUMERATIONTHRESHOLD   0

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
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATEPUBLISHED ascending:YES];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    
    NSPredicate* predicate;
    if (self.userID != nil) {
        //add predicate to gather only pages for a specific userID
        predicate = [NSPredicate predicateWithFormat:@"%K=%d AND (%K=%@ OR %K=%@)", stateAttributeNameStringValue, kPUBLISHED, FINISHEDILLUSTRATORID, self.userID, FINISHEDWRITERID, self.userID];
    }
    else {
        //add predicate to gather all published pages
        predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    }
    
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
    
    if (pagesRemaining <= kENUMERATIONTHRESHOLD && (!self.pageCloudEnumerator.isLoading) && ([self.pageCloudEnumerator canEnumerate])) {
        //enumerate
        LOG_BOOKVIEWCONTROLLER(0, @"Detected only %d pages remaining, initiating re-enumeration from cloud",activityName,pagesRemaining);
        self.pageCloudEnumerator = nil;
        self.pageCloudEnumerator = [CloudEnumerator enumeratorForPages];
        self.pageCloudEnumerator.delegate = self;
        [self.pageCloudEnumerator enumerateUntilEnd:nil];
        
        [self showHUDForBookDownload];
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
                
                ProductionLogViewController* productionLogController = [ProductionLogViewController createInstance];
                productionLogController.shouldOpenBookCover = NO;
                
                // Modal naviation to production log
                UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:productionLogController];
                navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [navigationController.navigationBar setHidden:YES];
                [navigationController.toolbar setHidden:YES];
                
                [self presentModalViewController:navigationController animated:YES];
                
                [navigationController release];
            }
            else {
                // book was opened, hide the cover
                
                // Now we just hide the animated view since
                // animation.removedOnCompletion is not working
                // in animation groups. Hiding the view prevents it
                // from returning to the original state and showing.
                //self.iv_bookCover.hidden = YES;
                [self.view sendSubviewToBack:self.iv_bookCover];
                
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                if ([userDefaults boolForKey:setting_ISFIRSTRUN] == NO) {
                    //we mark that the user has viewed this viewcontroller at least once
                    [userDefaults setBool:YES forKey:setting_ISFIRSTRUN];
                    [userDefaults synchronize];
                    
                    //this is the first time opening, so we show a intro screen
                    [self onHomeInfoButtonPressed:nil];
                    
                }
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


#pragma mark - Button Handlers
#pragma mark Book Page Delegate Methods
- (IBAction) onHomeButtonPressed:(id)sender {
    
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    if (![self.authenticationManager isUserAuthenticated]) {
        [Flurry logEvent:@"LOGIN_SHARE_FACEBOOK_BOOKBASEVIEW"];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onFacebookButtonPressed:)  fireOnMainThread:YES];
      [self authenticateAndGetFacebook:NO getTwitter:YES onSuccessCallback:onSuccessCallback onFailureCallback:nil];
       
    }
    else {
        [Flurry logEvent:@"SHARE_FACEBOOK_BOOKBASEVIEW"];
        
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

        [Flurry logEvent:@"LOGIN_SHARE_TWITTER_BOOKBASEVIEW"];
        
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onTwitterButtonPressed:)  fireOnMainThread:YES];
        
        //user is not logged in, must log in first
        [self authenticateAndGetFacebook:NO getTwitter:YES onSuccessCallback:onSuccessCallback onFailureCallback:nil];
        
        
    }
    else {
        [Flurry logEvent:@"SHARE_TWITTER_BOOKBASEVIEW"];
        
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

- (IBAction) onLinkButtonClicked:(id)sender {
    
}

- (IBAction) onTableOfContentsButtonPressed:(id)sender {
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = NO;
    
    BookTableOfContentsViewController* bookTableOfContentsViewController;
    if (self.userID != nil) {
        bookTableOfContentsViewController = [BookTableOfContentsViewController createInstanceWithUserID:self.userID];
    }
    else {
        bookTableOfContentsViewController = [BookTableOfContentsViewController createInstance];
    }
    bookTableOfContentsViewController.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookTableOfContentsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (IBAction) onZoomOutPhotoButtonPressed:(id)sender {
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = NO;
    
    FullScreenPhotoViewController* fullScreenController = [FullScreenPhotoViewController createInstanceWithPageID:self.pageID withPhotoID:self.topVotedPhotoID withCaptionID:self.topVotedCaptionID isSinglePhotoAndCaption:YES];
    [self.navigationController pushViewController:fullScreenController animated:YES];
}

- (IBAction)onPageInfoButtonPressed:(id)sender {
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewPage"];
    [self.view addSubview:infoView];
    [infoView release];
}

#pragma mark Home Page Delegate Methods
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = YES;
    
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = YES;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = YES;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = NO;
    
    // navigation to the production log happens after the book is closed
    [self closeBook];
}

- (void) showNotificationViewController
{
    NotificationsViewController* notificationsViewController = [NotificationsViewController createInstanceAndRefreshFeedOnAppear];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    
}

- (void) showProfileViewController
{
    ProfileViewController* profileViewController = [ProfileViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = YES;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = NO;
    
    //called when the writer's log button is pressed
    if (![self.authenticationManager isUserAuthenticated]) {
//        UICustomAlertView *alert = [[UICustomAlertView alloc]
//                                    initWithTitle:ui_LOGIN_TITLE
//                                    message:ui_LOGIN_REQUIRED
//                                    delegate:self
//                                    onFinishSelector:@selector(showProfileViewController)
//                                    onTargetObject:self
//                                    withObject:nil
//                                    cancelButtonTitle:@"Cancel"
//                                    otherButtonTitles:@"Login", nil];
//        [alert show];
//        [alert release];
        Callback* onSuccessCallback = [Callback callbackForTarget:self selector:@selector(onWritersLogButtonClicked:)  fireOnMainThread:YES];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSuccessCallback onFailureCallback:nil];

    }
    else 
    {
        //int unreadNotifications = [User unopenedNotificationsFor:self.loggedInUser.objectid];
        
        //if (unreadNotifications > 0) {
            [self showNotificationViewController];
        //}
        //else {
            //[self showProfileViewController];
        //}
    }
}

- (IBAction) onUserWritersLogButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onHomeInfoButtonPressed:(id)sender {
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = YES;
    self.shouldOpenToLastPage = NO;
    self.shouldAnimatePageTurn = NO;
    
    IntroViewController* introViewController = [IntroViewController createInstance];
    introViewController.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:introViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navigationController.navigationBarHidden = YES;
    
    [self.navigationController presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
    [introViewController release];
}


#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    NSString* activityName = @"BookViewControllerBase.commonInit";
    
    if (self.pageCloudEnumerator == nil) 
    {
        self.pageCloudEnumerator = [[CloudEnumeratorFactory instance]enumeratorForPages];
        self.pageCloudEnumerator.delegate = self;
    }
    
    if (!self.pageCloudEnumerator.isLoading) 
    {
        //enumerator is not loading, so we can go ahead and reset it and run it
        
        if ([self.pageCloudEnumerator canEnumerate]) 
        {
            LOG_BOOKVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
            [self.pageCloudEnumerator enumerateUntilEnd:nil];
        }
        else 
        {
            //the enumerator is not ready to run, but we reset it and away we go
            [self.pageCloudEnumerator reset];
            [self.pageCloudEnumerator enumerateUntilEnd:nil];
        }
        
        //[self showHUDForBookDownload];
    }
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

#pragma mark - Render Page from BookPageViewController
- (void)showHUDForBookDownload {
    PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    progressView.delegate = self;
    
    NSNumber* heartbeat = [NSNumber numberWithInt:10];
    
    //we need to construc the appropriate success, failure and progress messages for the book download
    NSString* failureMessage = @"Failed!\nSomeone has an overdue book out.";
    NSString* successMessage = @"Success!";
    NSArray* progressMessage = [NSArray arrayWithObjects:@"Downloading pages of Bahndr...", @"Searching Library of Alexandria...", @"Retrieving pages...", @"Breaking for afternoon tea...", @"Binding book...", nil];
    
    //ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    //NSNumber* maxDisplayTime = settings.http_timeout_seconds;
    
    NSNumber* maxDisplayTime = [NSNumber numberWithInt:25];
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:maxDisplayTime withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
}

- (void)savePageIndex:(int)index {
    if (self.userID == nil) {
        //we only save the last viewed page if we are not in a user specific book
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:index forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
    }
    else {
        //we temporarily store the last viewed page index for user specific books
        self.tempLastViewedPage = index;
    }
}

- (int)getLastViewedPageIndex {
    if (self.userID == nil) {
        //we only check the user default settings for the last page of the book the user viewed if we are not in a user specific book
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        int lastViewedPublishedPageIndex = [userDefaults integerForKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
        return lastViewedPublishedPageIndex;
    }
    else {
        //return the temporary stored value of the last viewed page for user specific books
        return self.tempLastViewedPage;
    }
}

- (void)renderPage {
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //NSString* activityName = @"BookViewControllerBase.viewDidLoad:";
    
    self.shouldOpenBookCover = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_background = nil;
    self.iv_bookCover = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"BookViewControllerBase.viewWillAppear:";
    
    /*ResourceContext* resourceContext = [ResourceContext instance];
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    self.topVotedPhotoID = page.finishedphotoid;
    self.topVotedCaptionID = page.finishedcaptionid;*/
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    //Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
////    if ([userDefaults boolForKey:setting_ISFIRSTRUN] == NO) {
////        [self showHUDForBookDownload];
////        
////        //this is the first time opening, so we show a welcome message
////        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Welcome to Bahndr!" message:ui_WELCOME_BOOK delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
////        
////        [alert show];
////        [alert release];
////    }
//    if ([userDefaults boolForKey:setting_ISFIRSTRUN] == NO) {
//        [self showHUDForBookDownload];
//        
//        //this is the first time opening, so we show a intro screen
//        [self onHomeInfoButtonPressed:nil];
//    }
    
    int count = [[self.frc_published_pages fetchedObjects] count];
    if (count == 0) {
        //there are no published page objects in local store, update from cloud
        
        //we set the clouddraftenumerator delegate to this view controller
        self.pageCloudEnumerator.delegate = self;
        if ([self.pageCloudEnumerator canEnumerate]) 
        {
            LOG_BOOKVIEWCONTROLLER(0, @"%@Refreshing book from cloud",activityName);
            
            [self.pageCloudEnumerator enumerateUntilEnd:nil];
            
            [self showHUDForBookDownload];
        }
    }
    
    if (!self.shouldOpenBookCover) {
        [self.view sendSubviewToBack:self.iv_bookCover];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"VIEWING_BOOKBASEVIEW" timed:YES];
    
    if (self.shouldOpenBookCover) {
        [self openBook];
    }
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"VIEWING_BOOKBASEVIEW" withParameters:nil];
    
    __frc_published_pages = nil;
    self.frc_published_pages = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
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

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"ProfileViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucesful
        LOG_REQUEST(0, @"%@ Enumeration request was successful",activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(0, @"%@ Enumeration request failure",activityName);
    
    }
}

- (void) progressViewHeartbeat:(UIProgressHUDView *)progressView 
          timeElapsedInSeconds:(NSNumber *)elapsedTimeInSeconds
{
    //heart beat processing
    //NSString* activityName = @"BookViewControllerBase.progressViewHeartbeat:";
    
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


#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
    NSString* activityName = @"BookViewController.onEnumerateComplete:";
    
    [self hideProgressBar];
    
    //on this method we need to enumerate all the captions that are part of the pages
    //to do this, we enumerate through each page and extract the finished caption ID
    //and make a fixed ID enumerate call to it.
    
    //we need to check if this enumeration brought down the entire book or was an optimized query
    //we check by counting the number of query expressions in the enumerator (its a hack, i know)
    //if its 2, then we know it was optimized, if its 1, we brough down the whole book
    
    if (enumerator == self.pageCloudEnumerator) {
        if ([[self.pageCloudEnumerator.query attributeExpressions]count] == 1 &&
            [results count] > 0) {
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
                //we check to see if it exists in the local store
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
}

#pragma mark - Static Initializers
+ (BookViewControllerBase*) createInstance {    
    // Determine which supported book view controller type to return
	if (NSClassFromString(@"UIPageViewController")) {
		// iOS 5 UIPageViewController style with native page curling
        BookViewControllerPageView* pageViewInstance = [[BookViewControllerPageView alloc]initWithNibName:@"BookViewControllerPageView" bundle:nil];
        pageViewInstance.pageID = nil;
        pageViewInstance.userID = nil;
        
        // by default the book should always open to the title page on first load
        pageViewInstance.shouldOpenBookCover = YES;
        pageViewInstance.shouldOpenToTitlePage = YES;
        pageViewInstance.shouldOpenToSpecificPage = NO;
        pageViewInstance.shouldOpenToLastPage = NO;
        pageViewInstance.shouldAnimatePageTurn = NO;
        [pageViewInstance autorelease];
        return pageViewInstance;
	}
    else {
		// iOS 3-4x LeaveViewController style with custom page curling
        BookViewControllerLeaves* leavesInstance = [[BookViewControllerLeaves alloc]initWithNibName:@"BookViewControllerLeaves" bundle:nil];
        leavesInstance.pageID = nil;
        leavesInstance.userID = nil;
        
        // by default the book should always open to the title page on first load
        leavesInstance.shouldOpenBookCover = YES;
        leavesInstance.shouldOpenToTitlePage = YES;
        leavesInstance.shouldOpenToSpecificPage = NO;
        leavesInstance.shouldOpenToLastPage = NO;
        leavesInstance.shouldAnimatePageTurn = NO;
        [leavesInstance autorelease];
        return leavesInstance;
	}
}

+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber*)pageID {
    BookViewControllerBase* vc = [BookViewControllerBase createInstance];
    vc.pageID = pageID;
    vc.shouldOpenBookCover = YES;
    vc.shouldOpenToTitlePage = NO;
    vc.shouldOpenToSpecificPage = YES;
    vc.shouldOpenToLastPage = NO;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}

+ (BookViewControllerBase*) createInstanceWithUserID:(NSNumber*)userID {
    BookViewControllerBase* vc = [BookViewControllerBase createInstance];
    vc.userID = userID;
    vc.shouldOpenBookCover = YES;
    vc.shouldOpenToTitlePage = YES;
    vc.shouldOpenToSpecificPage = NO;
    vc.shouldOpenToLastPage = NO;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}

+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber*)pageID withUserID:(NSNumber*)userID {
    BookViewControllerBase* vc = [BookViewControllerBase createInstance];
    vc.pageID = pageID;
    vc.userID = userID;
    vc.shouldOpenBookCover = YES;
    vc.shouldOpenToTitlePage = NO;
    vc.shouldOpenToSpecificPage = YES;
    vc.shouldOpenToLastPage = NO;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}


@end
