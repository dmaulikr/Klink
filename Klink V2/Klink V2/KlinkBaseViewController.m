//
//  KlinkBaseViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "KlinkBaseViewController.h"
#import "NotificationNames.h"
#import "AuthenticationManager.h"
#import "NSStringGUIDCategory.h"

#define kProfileBarHeight_Landscape 70 
#define kProfileBarHeight 70
#define kProfileBarWidth_Landscape 480
#define kProfileBarWidth 322
#define kProfileBarX_Landscape 0
#define kProfileBarX 0
#define kProfileBarY_Landscape 206
#define kProfileBarY 346

@implementation KlinkBaseViewController
@synthesize profileBar = __profileBar;
@synthesize v_landscape = m_v_landscape;
@synthesize v_portrait = m_v_portrait;
@synthesize profileBarHeight = __profileBarHeight;
@synthesize shouldShowProfileBar = m_shouldShowProfileBar;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize currentTheme = m_currentTheme;

#pragma mark - Properties
- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    __managedObjectContext = appContext;
    return __managedObjectContext;
}

- (int)profileBarHeight {
    if (self.view == self.v_portrait) {
        return m_profileBar_portrait_height;
    }
    else {
        return m_profileBar_landscape_height;
    }
}

- (UIProfileBar*)profileBar {
    if (self.view == self.v_portrait) {
        return m_profileBar_portrait;
    }
    else {
        return m_profileBar_landscape;
    }
}



#pragma mark - Private Methods

- (void)hideProfileBar {
    [self.profileBar setHidden:YES];
    [UIView beginAnimations:@"animationOff" context:NULL]; 
    [UIView setAnimationDuration:1.3f];
    CGRect existingFrame = self.profileBar.frame;
    self.profileBar.frame = CGRectMake(existingFrame.origin.x, existingFrame.origin.y, existingFrame.size.width, 0);
    [UIView commitAnimations];
}

- (void)showProfileBar {
    if (self.shouldShowProfileBar) {
        [self.profileBar setHidden:NO];
        [UIView beginAnimations:@"animationOn" context:NULL]; 
        [UIView setAnimationDuration:1.3f];
        CGRect existingFrame = self.profileBar.frame;
        self.profileBar.frame = CGRectMake(existingFrame.origin.x, existingFrame.origin.y, existingFrame.size.width, self.profileBarHeight);
        [UIView commitAnimations];
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
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [self.profileBar release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    self.profileBar = nil;
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}
-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    AuthenticationManager *authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==YES) {
        [self onUserLoggedIn];
    }
    else {
        [self onUserLoggedOut];
    }
    

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //need to register for global notifications of events
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
    [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
    [notificationCenter addObserver:self selector:@selector(onPhotoUploadCompleteNotificationHandler:) name:n_PHOTO_UPLOAD_COMPLETE object:nil];
    [notificationCenter addObserver:self selector:@selector(onPhotoUploadStartNotificationHandler:) name:n_PHOTO_UPLOAD_START object:nil];

    [notificationCenter addObserver:self selector:@selector(onFeedRefreshed:) name:n_FEED_REFRESHED object:nil];

    
    
    
    
}

-(void) didRotate:(NSNotification*)notification {
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (!self.shouldShowProfileBar) {
        [self hideProfileBar];
    }
    
    m_profileBar_landscape_height = m_profileBar_landscape.frame.size.height;
    m_profileBar_portrait_height =m_profileBar_portrait.frame.size.height;
    self.profileBar.viewController = self;


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
    return YES;
}



-(void)onGetUserComplete:(NSNotification*)notification {
//    NSString* activityName = @"HomeScreenController.onGetUserComplete";
}

-(void)onEnumerateFeedsComplete:(NSNotification*) notification {
//    NSString* activityName = @"HomeScreenController.onEnumerateFeedsComplete:";
}

- (void) enumerateFeed {
    NSString* notificationID = [NSString GetGUID];
    AuthenticationContext* context = [[AuthenticationManager getInstance]getAuthenticationContext];
    NSString* userNotificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    
    
    if (context != nil) {
        [notificationCenter addObserver:self selector:@selector(onGetUserComplete:) name:userNotificationID object:nil];
        [notificationCenter addObserver:self selector:@selector(onEnumerateFeedsComplete:) name:notificationID object:nil];
        
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        [enumerationManager enumerateFeeds:[NSNumber numberWithInt:100] 
                              withPageSize:[NSNumber numberWithInt:10] 
                          withQueryOptions:[QueryOptions queryForFeedsForUser:context.userid] 
                            onFinishNotify:notificationID 
                     useEnumerationContext:nil 
                 shouldEnumerateSinglePage:NO];
        
        
        //need to update the user object for the current person as well
        
        [enumerationManager getUser:context.userid onFinishNotify:userNotificationID ];
    }

}

- (BOOL) deviceInPortraitOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    return UIDeviceOrientationIsPortrait(orientation);
}

#pragma mark - System Event Handlers
- (void) onUserLoggedIn: (NSNotification*)notification {
    [self onUserLoggedIn];  
}

- (void) onUserLoggedOut:(NSNotification*)notification {
    [self onUserLoggedOut];
}

- (void) onUserLoggedIn {
    [self showProfileBar];
//    [self enumerateFeed];
    
}

- (void) onUserLoggedOut {
    [self hideProfileBar];
}

- (void) onFeedRefreshed:(NSNotification*)notification {
    
}

- (void) onPhotoUploadCompleteNotificationHandler:(NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSString* activityName = @"KlinkBaseViewController.onPhotoUploadCompleteNotificationHandler:";
    
    NSString* message = @"handling system event notification";
    [BLLog v:activityName withMessage:message];
    
    if ([userInfo objectForKey:an_OBJECTID] != nil) {
        Photo* photo = [DataLayer getObjectByID:[userInfo objectForKey:an_OBJECTID] withObjectType:PHOTO];
        [self onPhotoUploadComplete:photo];
        
        
    }
}

- (void) onPhotoUploadStartNotificationHandler:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSString* activityName = @"KlinkBaseViewController.onPhotoUploadStartNotificationHandler:";
    
    NSString* message = @"handling system event notification";
    [BLLog v:activityName withMessage:message];
    
    if ([userInfo objectForKey:an_OBJECTID] != nil) {
        Photo* photo = [DataLayer getObjectByID:[userInfo objectForKey:an_OBJECTID] withObjectType:PHOTO];
        [self onPhotoUploadStart:photo];
    }
}


- (void) onPhotoUploadComplete:(Photo*)photo {
    
}

- (void) onPhotoUploadStart:(Photo *)photo {
    
}

@end
