//
//  BaseViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "PlatformAppDelegate.h"

#import "CallbackResult.h"
#import "Macros.h"
#import "UICameraActionSheet.h"
#import "ContributeViewController.h"

#define kSELECTOR   @"selector"
#define kTARGETOBJECT   @"targetobject"
#define kPARAMETER   @"parameter"
@implementation BaseViewController

@synthesize authenticationManager = __authenticationManager;
@synthesize loggedInUser = __loggedInUser;
@synthesize feedManager           = __feedManager;
//@synthesize managedObjectContext    =__managedObjectContext;
@synthesize eventManager          = __eventManager;

@synthesize progressView          = m_progressView;
@synthesize loginView             = m_loginView;

#pragma mark - Properties
//
//- (NSManagedObjectContext*)managedObjectContext {
//    if (__managedObjectContext != nil) {
//        return __managedObjectContext;
//    }
//    PlatformAppDelegate* appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication] delegate];
//    __managedObjectContext = appDelegate.managedObjectContext;
//    return __managedObjectContext;
//    
//}

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

#pragma mark - Frames
- (CGRect) frameForLoginView {
    return CGRectMake(0, 0, 320, 460);
}

- (void) commonInit {
    CGRect frameForLoginView = [self frameForLoginView];
    self.loginView = [[UILoginView alloc] initWithFrame:frameForLoginView withParent:self];
    
    //self.progressView = [[MBProgressHUD alloc]initWithView:self.view];
    
    self.progressView = [[UIProgressHUDView alloc]initWithView:self.view];
    [self.view addSubview:self.progressView];
   // [self.view addSubview:self.loginView];
}

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
    [self.loginView release];
    [self.progressView release];
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
    
    [self.eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
    [self.eventManager registerCallback:logoutCallback forSystemEvent:kUSERLOGGEDOUT];
    [self.eventManager registerCallback:showProgressBarCallback forSystemEvent:kSHOWPROGRESS];
    [self.eventManager registerCallback:hideProgressBarCallback forSystemEvent:kHIDEPROGRESS];

    [loginCallback release];
    [logoutCallback release];
    [showProgressBarCallback release];
    [hideProgressBarCallback release];
    
    [self commonInit];
    //setup the progress view
    
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
#pragma mark - Progress bar management

- (void) showProgressBar:(NSString *)message 
          withCustomView:(UIView *)view 
  withMaximumDisplayTime:(NSNumber *)maximumTimeInSeconds 
{
    NSString* activityName = @"BaseViewController.showProgressBar:";
    
    //first check if this view controller is the top level visible controller
    if (self.navigationController.visibleViewController == self) {
        self.progressView.labelText = message;
        [self.progressView removeAllSubviews];
        
        if (view != nil) {
            self.progressView.customView = view;
            self.progressView.mode = MBProgressHUDModeCustomView;
        }
        else {
            self.progressView.customView = nil;
            self.progressView.mode = MBProgressHUDModeIndeterminate;
        }
        
        
        
        LOG_OVERLAYVIEWCONTROLLER(0, @"%@showing progress bar", activityName);
        [self.progressView show:YES];
        //    [self.progressView showWhileExecuting:@selector(waitUntilNotBusy:) onTarget:self withObject:maximumTimeInSeconds animated:YES];
    }
}

- (void) hideProgressBar {
    if (self.navigationController.visibleViewController == self) {
        [self.progressView hide:YES];
    }
}


#pragma mark - Instance Methods 
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
    
    Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginComplete:) withContext:userInfo];
    [userInfo release];
    
    [self.view addSubview:self.loginView];
    [self.loginView authenticate:facebook withTwitter:twitter onFinishCallback:callback];
}


#pragma mark - Async Handlers
- (void) onLoginComplete:(CallbackResult*)result {
    NSString* activityName = @"BaseViewController.onLoginComplete:";
        
    Response* response = result.response;
    
    if (response.didSucceed) {
        LOG_BASEVIEWCONTROLLER(0,@"%@Login completed successfully",activityName);
        //now we call the callback passed in originally
        NSDictionary* userInfo = result.context;
        
        if (userInfo != nil) {
            NSValue* selectorValue = [userInfo valueForKey:kSELECTOR];
            SEL selector =  [selectorValue pointerValue];
            id target =  [userInfo valueForKey:kTARGETOBJECT];
            id parameter =  [userInfo valueForKey:kPARAMETER];
            
            if (target != nil &&
                [target respondsToSelector:selector]) {
                LOG_BASEVIEWCONTROLLER(0,@"%@Resuming original method",activityName);
                [target performSelectorOnMainThread:selector withObject:parameter waitUntilDone:NO];
            }
            else {
                LOG_BASEVIEWCONTROLLER(1,@"%@Callback target object is nil, cannot resume",activityName);
            }
        }
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
