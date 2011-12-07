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

- (void) baseInit {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
       //self.view.backgroundColor = [UIColor blackColor];
        
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
    
    //Callback* newCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaption:)];
    
    [self.eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
    [self.eventManager registerCallback:logoutCallback forSystemEvent:kUSERLOGGEDOUT];
    [self.eventManager registerCallback:showProgressBarCallback forSystemEvent:kSHOWPROGRESS];
    [self.eventManager registerCallback:hideProgressBarCallback forSystemEvent:kHIDEPROGRESS];
    //[self.eventManager registerCallback:newCaptionCallback forSystemEvent:kNEWCAPTION];
    
    [loginCallback release];
    [logoutCallback release];
    [showProgressBarCallback release];
    [hideProgressBarCallback release];
    
    CGRect frameForLoginView = [self frameForLoginView];
    self.loginView = [[UILoginView alloc] initWithFrame:frameForLoginView withParent:self];
    self.progressView = [[UIProgressHUDView alloc]initWithView:self.view];
    [self.view addSubview:self.progressView];
    
    // the notifications tableview that will sit under every view
    //NotificationsViewController* notificationsViewController = [NotificationsViewController createInstance];
    //[self.view sendSubviewToBack:notificationsViewController.view];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTintColor:nil];
    
    // Toolbar
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    [self.navigationController.toolbar setTranslucent:YES];
    
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
    
    Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginComplete:) withContext:userInfo];
    Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:) withContext:userInfo];
    
    [userInfo release];
    
    [self.view addSubview:self.loginView];
    [self.loginView authenticate:facebook withTwitter:twitter onSuccessCallback:onSucccessCallback onFailCallback:onFailCallback];
}

#pragma mark - ConrtibuteViewControllerDelegate methods
- (void)submitChangesForController:(ContributeViewController*)controller {
    NSString* activityName = @"BaseViewController.submitChangesForController:";
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //this method will persist changes that are returned from the contribute controller
    if (controller.configurationType == PAGE) {
        //this is a new draft being added
        Page* page = [Page createNewDraftPage];
        
        page.displayname = controller.draftTitle;
        page.descr = nil;
        page.hashtags = controller.draftTitle;
        
        //we set the initial number of votes on the page to 0
        page.numberofpublishvotes = [NSNumber numberWithInt:0];
        
        Photo* photo = nil;
        if (controller.img_photo != nil && controller.img_thumbnail != nil) {
            photo = [Photo createPhotoInPage:page.objectid withThumbnailImage:controller.img_thumbnail withImage:controller.img_photo];
            
            //we set the initial number of photos to 1
            page.numberofphotos = [NSNumber numberWithInt:1];
            
            //we set the initial number of votes on the photo to 0
            photo.numberofvotes = [NSNumber numberWithInt:0];
            
            //check for caption attached to photo
            if (controller.caption != nil && ![controller.caption isEqualToString:@""]) {
                Caption* caption = [Caption createCaptionForPhoto:photo.objectid withCaption:controller.caption];
                
                //we set the initial number of votes on the caption to 0
                caption.numberofvotes = [NSNumber numberWithInt:0];
                
                //set the initial caption counters to 1
                photo.numberofcaptions = [NSNumber numberWithInt:1];
                page.numberofcaptions = [NSNumber numberWithInt:1];
                
                LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@, along with photo with ID:%@ and caption with ID:%@ (caption: %@) to the local database",activityName, page.objectid,photo.objectid,caption.objectid,caption.caption1);
            }
            else {
                LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@ along with photo with ID:%@ to the local database",activityName,page.objectid,photo.objectid);
            }
        }
        else {
            LOG_BASEVIEWCONTROLLER(0, @"%@Commiting new page with ID:%@ to the local database",activityName,page.objectid,photo.objectid);
        }
        
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
        
        if (controller.caption != nil && ![controller.caption isEqualToString:@""]) {
            Caption* caption = [Caption createCaptionForPhoto:photo.objectid withCaption:controller.caption];
            LOG_BASEVIEWCONTROLLER(0, @"%@Commiting photo with ID:%@ and caption with ID:%@ (caption: %@) to the local database",activityName,photo.objectid,caption.objectid,caption.caption1);
            
            //we set the initial number of votes on the caption to 0
            caption.numberofvotes = [NSNumber numberWithInt:0];
            
            //we set the initial number of captions on the photo to 1
            photo.numberofcaptions = [NSNumber numberWithInt:1];
            
            //increment the caption counter on the page this new photo belongs to
            page.numberofcaptions = [NSNumber numberWithInt:([page.numberofcaptions intValue] + 1)];
        }
        else {
            LOG_BASEVIEWCONTROLLER(0, @"%@Commiting photo with ID:%@ to the local database",activityName,photo.objectid);
        }
        
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
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    //create callback to this view controller for when the saves are finished
    Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onSaveComplete:)];
    [resourceContext save:YES onFinishCallback:callback];
    
    [callback release];
    
    //after this point, the platforms should automatically begin syncing the data back to the cloud
    
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

/*- (void) onNewCaption:(CallbackResult*)result {

}*/

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
