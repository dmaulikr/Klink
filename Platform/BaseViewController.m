//
//  BaseViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "PlatformAppDelegate.h"
#import "Photo.h"
#import "CallbackResult.h"
#import "Macros.h"
#import "UICameraActionSheet.h"
#import "ContributeViewController.h"
#import "Page.h"
#import "ImageManager.h"
#import "NotificationsViewController.h"
#import "ProfileViewController.h"
#import "UIStrings.h"
#import "LoginViewController.h"

#define kSELECTOR   @"selector"
#define kTARGETOBJECT   @"targetobject"
#define kPARAMETER   @"parameter"

@implementation BaseViewController

@synthesize authenticationManager = __authenticationManager;
@synthesize loggedInUser = __loggedInUser;
@synthesize feedManager           = __feedManager;
//@synthesize managedObjectContext    =__managedObjectContext;
@synthesize eventManager          = __eventManager;

//@synthesize progressView          = m_progressView;
@synthesize loginView             = m_loginView;

#pragma mark - Properties



- (EventManager*) eventManager {
    if (__eventManager != nil) {
        return __eventManager;
    }
    __eventManager = [EventManager instance];
    return __eventManager;
}

- (FeedManager*)feedManager {
    if (__feedManager != nil) {
        return __feedManager;
    }
    __feedManager = [FeedManager instance];
    return __feedManager;
}

- (AuthenticationManager*) authenticationManager {
    if (__authenticationManager != nil) {
        return __authenticationManager;
    }
    __authenticationManager = [AuthenticationManager instance];
    return __authenticationManager;
}

- (User*) loggedInUser {    
    if ([self.authenticationManager isUserAuthenticated]) {    
        //retrieves the current logged in user
        ResourceContext* resourceContext = [ResourceContext instance];
        return (User*)[resourceContext resourceWithType:USER withID:self.authenticationManager.m_LoggedInUserID];
    } else {
        return nil;
    }
}

- (void) commonInit {
    

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}
#pragma mark - Frames
- (CGRect) frameForLoginView {
    return CGRectMake(0, 0, 320, 460);
}



- (void)dealloc
{
    //[self.loginView release];
   // [self.progressView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Callback* loginCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedIn:)];
    Callback* logoutCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedOut:)];    
    Callback* showProgressBarCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onShowProgressView:)];
    Callback* hideProgressBarCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onHideProgressView:)];    
    Callback* failedAuthenticationCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onAuthenticationFailed:)];    
    Callback* unknownRequestFailureCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUnknownRequestFailure:)];
    Callback* applicationDidBecomeActiveCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onApplicationDidBecomeActive:)];
    Callback* applicationWentToBackgroundCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onApplicationWentToBackground:)];
    
    //we configure each callback to callback on the main thread
    loginCallback.fireOnMainThread = YES;
    logoutCallback.fireOnMainThread = YES;
    showProgressBarCallback.fireOnMainThread = YES;
    hideProgressBarCallback.fireOnMainThread = YES;
    failedAuthenticationCallback.fireOnMainThread = YES;
    unknownRequestFailureCallback.fireOnMainThread = YES;
    applicationDidBecomeActiveCallback.fireOnMainThread = YES;
    applicationWentToBackgroundCallback.fireOnMainThread = YES;
    
    [self.eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
    [self.eventManager registerCallback:logoutCallback forSystemEvent:kUSERLOGGEDOUT];
    [self.eventManager registerCallback:showProgressBarCallback forSystemEvent:kSHOWPROGRESS];
    [self.eventManager registerCallback:hideProgressBarCallback forSystemEvent:kHIDEPROGRESS];
    [self.eventManager registerCallback:failedAuthenticationCallback forSystemEvent:kAUTHENTICATIONFAILED];
    [self.eventManager registerCallback:unknownRequestFailureCallback forSystemEvent:kUNKNOWNREQUESTFAILURE];
    [self.eventManager registerCallback:applicationDidBecomeActiveCallback forSystemEvent:kAPPLICATIONBECAMEACTIVE];
    [self.eventManager registerCallback:applicationWentToBackgroundCallback forSystemEvent:kAPPLICATIONWENTTOBACKGROUND];
    
    [unknownRequestFailureCallback release];
    [failedAuthenticationCallback release];
    [loginCallback release];
    [logoutCallback release];
    [showProgressBarCallback release];
    [hideProgressBarCallback release];
    [applicationDidBecomeActiveCallback release];
    [applicationWentToBackgroundCallback release];

    CGRect frameForLoginView = [self frameForLoginView];
    UILoginView* lv = [[UILoginView alloc] initWithFrame:frameForLoginView withParent:self];
    self.loginView = lv;
    [lv release];
    
    //UIProgressHUDView* pv  = [[UIProgressHUDView alloc]initWithView:self.view];
    //self.progressView = pv;
    //[pv release];
    
    //[self.view addSubview:self.progressView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*// Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:nil];*/
     
    /*// Toolbar
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    [self.navigationController.toolbar setTranslucent:YES];
    
    // unhide navigation bar and toolbar if they are hidden
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.toolbar.hidden = NO;*/
    
}


- (void) viewWillDisappear:(BOOL)animated {
    //NSString* activityName = @"BaseViewController.viewWillDisappear:";
    [super viewWillDisappear:animated];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loginView = nil;
    
    //we need to de-register from all events we may have subscribed too
    EventManager* eventManager = [EventManager instance];
    [eventManager unregisterFromAllEvents:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Progress bar management
- (void) showDeterminateProgressBarWithMaximumDisplayTime: (NSNumber*)maximumTimeInSeconds
                      withHeartbeat:(NSNumber*)heartbeatInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages
{
    
    
    NSString* activityName = @"BaseViewController.showDeterminateProgressBar:";
    
    PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;
    
    
    //first check if this view controller is the top level visible controller
   // if (self.navigationController.visibleViewController == self) {
       
        [progressView removeAllSubviews];
        
        [self.view addSubview:progressView];
        
        progressView.customView = nil;
        progressView.mode = MBProgressHUDModeDeterminate;
        
        
        
        LOG_BASEVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
        
        if (heartbeatInSeconds != nil) 
        {
            [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds withHeartbeatInterval:heartbeatInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        }
        else 
        {
            [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        }
    //}

}

- (void) showDeterminateProgressBarWithMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds 
                   onSuccessMessage:(NSString*)successMessage 
                   onFailureMessage:(NSString*)failureMessage 
                 inProgressMessages:(NSArray*)progressMessages 
{
    [self showDeterminateProgressBarWithMaximumDisplayTime:maximumTimeInSeconds withHeartbeat:nil onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessages];
    
}
- (void) showProgressBar:(NSString *)message 
          withCustomView:(UIView *)view 
  withMaximumDisplayTime:(NSNumber *)maximumTimeInSeconds 
{
    NSString* activityName = @"BaseViewController.showProgressBar:";
    
    PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;

    
    //first check if this view controller is the top level visible controller
   // if (self.navigationController.visibleViewController == self) {
        progressView.labelText = message;
        [progressView removeAllSubviews];
        
        
        [self.view addSubview:progressView];
        
        if (view != nil) {
            progressView.customView = view;
            progressView.mode = MBProgressHUDModeCustomView;
        }
        else {
            progressView.customView = nil;
            progressView.mode = MBProgressHUDModeIndeterminate;
        }
        
        //progressView.maximumDisplayTime = maximumTimeInSeconds;
        
       // [progressView hide:NO];
        LOG_BASEVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
        NSArray* progressMessages = [NSArray arrayWithObject:message];
        NSString* successMessage = @"Success!";
        NSString* failureMessage = @"Failure!";
        [progressView show:YES withMaximumDisplayTime:maximumTimeInSeconds showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
        
    //}
}

- (void) hideProgressBar {
    NSString* activityName = @"BaseViewController.hideProgressBar:";
    PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;

    
    if (self.navigationController.visibleViewController == self) {
        LOG_BASEVIEWCONTROLLER(0, @"%@Hiding progress bar and removing it from this view",activityName);
        [progressView removeFromSuperview];
        //[progressView hide:YES];
        if (!progressView.isHidden) {
            [progressView hide:YES];
        }
        progressView.delegate = nil;
        delegate.progressView = nil;
        
        
    }
}


#pragma mark - Instance Methods 
- (BOOL) isViewControllerActive {
    //returns a boolean indicating whether this instance is the currently shown view in the application
    return  ( [self isViewLoaded] && self.view.window);
}

- (void) clearDisplayedLoginView {
    NSString* activityName = @"BaseViewController.clearDisplayedLoginView:";
    //if the login view is showing, we remove it from the super view so we dont lock the screen potentially.
    if (self.loginView.superview != nil &&
        self.loginView.superview == self.view) {
        
        LOG_BASEVIEWCONTROLLER(0,@"%@Detected login view controller is still showing, clearing the loginview",activityName);
        //remove from superview
        [self.loginView removeFromSuperview];
        

    }
}


- (void) authenticateAndGetFacebook:(BOOL)getFaceobook 
                         getTwitter:(BOOL)getTwitter 
                  onSuccessCallback:(Callback*)successCallback 
                  onFailureCallback:(Callback*)failCallback 
{
    LoginViewController* loginViewController = [LoginViewController createAuthenticationInstance:getFaceobook shouldGetTwitter:getTwitter onSuccessCallback:successCallback onFailureCallback:failCallback];
   
    [self  presentModalViewController:loginViewController animated:YES];
    
    
    
    
}
- (void) authenticate:(BOOL)facebook 
          withTwitter:(BOOL)twitter 
     onFinishSelector:(SEL)sel 
       onTargetObject:(id)targetObject 
           withObject:(id)parameter 
{
   
    
    
    NSMutableDictionary* userInfo = nil;
    if (targetObject != nil) {
        userInfo = [[NSMutableDictionary alloc]init ];
        //we stuff in the callback parameters into the user info, we will
        //use these when dealing with the callback
        NSValue* selectorValue = [NSValue valueWithPointer:sel];
        [userInfo setValue:selectorValue forKey:kSELECTOR];
        [userInfo setValue:targetObject forKey:kTARGETOBJECT];
        [userInfo setValue:parameter forKey:kPARAMETER];
    }
    
    Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginComplete:) withContext:userInfo];
    Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:) withContext:userInfo];
    
    [userInfo release];
    
    [self.view addSubview:self.loginView];
    [self.loginView authenticate:facebook withTwitter:twitter onSuccessCallback:onSucccessCallback onFailCallback:onFailCallback];
    [onSucccessCallback release];
    [onFailCallback release];
}

#pragma mark - ConrtibuteViewControllerDelegate methods
- (NSArray*)submitChangesForController:(ContributeViewController*)controller {
    NSString* activityName = @"BaseViewController.submitChangesForController:";
    ResourceContext* resourceContext = [ResourceContext instance];
    //we start a new undo group here
    [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
    
    //this method will persist changes that are returned from the contribute controller
    if (controller.configurationType == PAGE) {
        //this is a new draft being added
        
       
        
        Page* page = [Page createNewDraftPage];
        if (controller.nPageObjectID == nil)
        {
            //this is the first page being created with this controller
            controller.nPageObjectID = page.objectid;
        
        }
        else 
        {
            //in this case we know there was a previous submission for new page
            //so we set the id the same so we dont possibly recreate the page on the server
            page.objectid = controller.nPageObjectID;
        }
        
        page.displayname = controller.draftTitle;
        page.descr = nil;
        page.hashtags = controller.draftTitle;
        
        //we set the initial number of votes on the page to 0
        page.numberofpublishvotes = [NSNumber numberWithInt:0];
        
        Photo* photo = nil;
        if (controller.img_photo != nil && controller.img_thumbnail != nil) {
            photo = [Photo createPhotoInPage:page.objectid withThumbnailImage:controller.img_thumbnail withImage:controller.img_photo];
            
            if (controller.nPhotoObjectID == nil)
            {
                controller.nPhotoObjectID = photo.objectid;
            }
            else {
                photo.objectid = controller.nPhotoObjectID;
            }
            
            //we set the initial number of photos to 1
            page.numberofphotos = [NSNumber numberWithInt:1];
            
            //we set the initial number of votes on the photo to 0
            photo.numberofvotes = [NSNumber numberWithInt:0];
            
            //check for caption attached to photo
            if (controller.caption == nil || [controller.caption isEqualToString:@""]) 
            {
                //if the caption is empty, we set it equal to the default valuye for an empty caption
                controller.caption = ui_EMPTY_CAPTION;
            }
            Caption* caption = [Caption createCaptionForPhoto:photo.objectid withCaption:controller.caption];
            
            if (controller.nCaptionObjectID == nil)
            {
                controller.nCaptionObjectID = caption.objectid;
            }
            else
            {
                caption.objectid = controller.nCaptionObjectID;
            }
            
            //we set the initial number of votes on the caption to 0
            caption.numberofvotes = [NSNumber numberWithInt:0];
            
            //set the initial caption counters to 1
            photo.numberofcaptions = [NSNumber numberWithInt:1];
            page.numberofcaptions = [NSNumber numberWithInt:1];
            
            caption.pageid = page.objectid;
            
            LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@, along with photo with ID:%@ and caption with ID:%@ (caption: %@) to the local database",activityName, page.objectid,photo.objectid,caption.objectid,caption.caption1);
//            }
//            else {
//                LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@ along with photo with ID:%@ to the local database",activityName,page.objectid,photo.objectid);
//            }
        }
        else {
            LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@ to the local database",activityName,page.objectid,photo.objectid);
        }
        //[resourceContext.managedObjectContext.undoManager endUndoGrouping];
        
    }
    else if (controller.configurationType == PHOTO) {
       

        
        //this is a new photo being added to a draft page
        Photo* photo = [Photo createPhotoInPage:controller.pageID withThumbnailImage:controller.img_thumbnail withImage:controller.img_photo];
        
        //we set the initial number of votes on the photo to 0
        photo.numberofvotes = [NSNumber numberWithInt:0];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:controller.pageID];
        
        //increment the photo counter on the page this new photo belongs to
        page.numberofphotos = [NSNumber numberWithInt:([page.numberofphotos intValue] + 1)];
        
        if (controller.caption == nil || [controller.caption isEqualToString:@""]) 
        {
            controller.caption = ui_EMPTY_CAPTION;
            
        }
        Caption* caption = [Caption createCaptionForPhoto:photo.objectid withCaption:controller.caption];
        LOG_BASEVIEWCONTROLLER(0, @"%@Commiting photo with ID:%@ and caption with ID:%@ (caption: %@) to the local database",activityName,photo.objectid,caption.objectid,caption.caption1);
        
        //we set the initial number of votes on the caption to 0
        caption.numberofvotes = [NSNumber numberWithInt:0];
        
        //we set the initial number of captions on the photo to 1
        photo.numberofcaptions = [NSNumber numberWithInt:1];
        
        //increment the caption counter on the page this new photo belongs to
        page.numberofcaptions = [NSNumber numberWithInt:([page.numberofcaptions intValue] + 1)];
        
        caption.pageid = page.objectid;
             
    }
    else if (controller.configurationType == CAPTION) {
        
    

        Caption* caption = [Caption createCaptionForPhoto:controller.photoID withCaption:controller.caption];
        LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new caption with ID:%@ (caption:%@)",activityName,caption.objectid,caption.caption1);
        
        //we set the initial number of votes on the caption to 0
        caption.numberofvotes = [NSNumber numberWithInt:0];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:controller.pageID];
        Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:controller.photoID];
        
        //increment the caption counters on the photo and page this new caption belongs to
        photo.numberofcaptions = [NSNumber numberWithInt:([photo.numberofcaptions intValue] + 1)];
        page.numberofcaptions = [NSNumber numberWithInt:([page.numberofcaptions intValue] + 1)];
        
        caption.pageid = page.objectid;

    }
    
    //[self dismissModalViewControllerAnimated:YES];
    
    //create callback to this view controller for when the saves are finished
    Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onSaveComplete:)];
    
    PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;

    //we start a new undo group here
   // [resourceContext.managedObjectContext processPendingChanges];
   // [resourceContext.managedObjectContext.undoManager endUndoGrouping];
    NSArray* retVal = [resourceContext save:YES onFinishCallback:callback trackProgressWith:progressView];
    
    [callback release];
    
    return retVal;
   
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* activityName = @"BaseViewController.alertView:clickedButtonAtIndex:";
    
    AuthenticationManager* authnManager = [AuthenticationManager instance];
    AuthenticationContext* authnContext = [authnManager contextForLoggedInUser];
    
    if (alertView.delegate == self && [authnContext.isfirsttime boolValue]) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            // user selected Profile button
            ProfileViewController* profileViewController = [ProfileViewController createInstance];
            
            UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:navigationController animated:YES];
            
            [navigationController release];
        }
        else {
            // user selected the Continue button, now we call the callback passed in originally
            if (alertView.targetObject != nil &&
                [alertView.targetObject respondsToSelector:alertView.onFinishSelector]) {
                LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
                [alertView.targetObject performSelectorOnMainThread:alertView.onFinishSelector withObject:alertView.withObject waitUntilDone:NO];
            }
            else {
                LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
            }
        }
    }
}

#pragma mark - Async Handlers
//this method handles a Login attempt that is either cancelled or returned unsuccessfully
//any view controller subclass can use this as the target for their onFailCallback passed to the
//UILoginView.h
- (void) onLoginFailed:(CallbackResult *)result {
    NSString* activityName = @"BaseViewController.onAuthenticateFailed:";
    
    //need to display an error message to the user
    //TODO: create generic error emssage display
    LOG_BASEVIEWCONTROLLER(1, @"%@Authentication failed, cannot complete initial request",activityName);
}

- (void) onSaveComplete:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onSaveComplete:";
    
    LOG_BASEVIEWCONTROLLER(0, @"%@Save completed successfully",activityName);
}

- (void) onUnknownRequestFailure:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onUnknownRequestFailure:";
    LOG_BASEVIEWCONTROLLER(0,@"%@Unknown request failure",activityName);
}
- (void) onAuthenticationFailed:(CallbackResult*)result {
   // NSString* activityName = @"BaseViewController.onAuthenticationFailed:";
    //we handle an authentication failed by requiring they authenticate again against facebook
//    if ( [self isViewLoaded] && self.view.window) {
//        // we only process if this view controller is on top
//        LOG_BASEVIEWCONTROLLER(0, @"%@Processing Authentication Failed Event",activityName);
//        AuthenticationManager* authnManager = [AuthenticationManager instance];
//        [authnManager logoff];
//        [self authenticate:YES withTwitter:NO onFinishSelector:nil onTargetObject:nil withObject:nil];
//    }
}

- (void) onApplicationWentToBackground:(CallbackResult*)result {
    //this event is raiseda nytime the application to have moved into the background state
    NSString* activityName = @"BaseViewController.onApplicationWentToBackground:";
    if ([self isViewControllerActive]) {
        LOG_BASEVIEWCONTROLLER(0, @"%@Detected application entered background",activityName);
        
       // [self clearDisplayedLoginView];
    }
}
- (void) onApplicationDidBecomeActive:(CallbackResult*)result {
    //this event is raised anytime the application is detected to have moved back into the active state
    NSString* activityName = @"BaseViewController.onApplicationDidBecomeActive:";
    if ([self isViewControllerActive]) {
        LOG_BASEVIEWCONTROLLER(0,@"%@Detected application became active",activityName);
    
        [self clearDisplayedLoginView];
    }
    
}


- (void) onLoginComplete:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onLoginComplete:";
        
    Response* response = result.response;
    
    if (response.didSucceed) {
        LOG_BASEVIEWCONTROLLER(0,@"%@Login completed successfully",activityName);
        
        // unpack the userInfo
        NSDictionary* userInfo = result.context;
        
        SEL selector = nil;
        id target = nil;
        id parameter = nil;
        
        if (userInfo != nil) {
            NSValue* selectorValue = [userInfo valueForKey:kSELECTOR];
            selector =  [selectorValue pointerValue];
            target =  [userInfo valueForKey:kTARGETOBJECT];
            parameter =  [userInfo valueForKey:kPARAMETER];
        }
        
        AuthenticationManager* authnManager = [AuthenticationManager instance];
        AuthenticationContext* authnContext = [authnManager contextForLoggedInUser];
        
        if ([authnContext.isfirsttime boolValue]) {
            LOG_BASEVIEWCONTROLLER(0,@"%@First time user is loggin in",activityName);
            UICustomAlertView *alert = [[UICustomAlertView alloc]
                                        initWithTitle:@"Welcome!"
                                        message:[NSString stringWithFormat:@"Hello %@! We've set up an account for you. Would you like to visit your profile and account settings, or continue from where you left off?", self.loggedInUser.username]
                                        delegate:self
                                        onFinishSelector:selector
                                        onTargetObject:target
                                        withObject:parameter
                                        cancelButtonTitle:@"Profile"
                                        otherButtonTitles:@"Continue", nil];
            
            [alert show];
            [alert release];
        }
        else {
            // we call the callback passed in originally
            if (target != nil &&
                [target respondsToSelector:selector]) {
                LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
                [target performSelectorOnMainThread:selector withObject:parameter waitUntilDone:NO];
            }
            else {
                LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
            }
        }
        
        /*//now we call the callback passed in originally
        if (target != nil &&
            [target respondsToSelector:selector]) {
            LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
            [target performSelectorOnMainThread:selector withObject:parameter waitUntilDone:NO];
        }
        else {
            LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
        }*/
    }
    else {
        LOG_BASEVIEWCONTROLLER(0,@"%@Login failed",activityName);

    }
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage *)thumbnailImage withFullImage:(UIImage *)image {
    //ContributeViewController* contributeViewController = [[ContributeViewController alloc] init];
    //contributeViewController.img_photo = image;
    
    //[self.navigationController pushViewController:contributeViewController animated:YES];
    //[contributeViewController release];
}

- (void) onUserLoggedIn:(CallbackResult*)result {
    
}

- (void) onUserLoggedOut:(CallbackResult*)result {
    
}

- (void) onShowProgressView:(CallbackResult*)result {
    NSDictionary* userInfo = result.context;
    NSString* message = [userInfo valueForKey:kMessage];
    UIView* customView = [userInfo valueForKey:kCustomView];
    NSNumber* maximumTimeInSeconds = [userInfo valueForKey:kMaximumTimeInSeconds];
    [self showProgressBar:message withCustomView:customView withMaximumDisplayTime:maximumTimeInSeconds];
}

- (void) onHideProgressView:(CallbackResult*)result {
    [self hideProgressBar];
}





@end
