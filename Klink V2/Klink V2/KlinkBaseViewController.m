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

#pragma mark - Properties
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
    ;
    [UIView commitAnimations];
}

- (void)showProfileBar {
    [self.profileBar setHidden:NO];
    [UIView beginAnimations:@"animationOn" context:NULL]; 
    [UIView setAnimationDuration:1.3f];
    CGRect existingFrame = self.profileBar.frame;
    self.profileBar.frame = CGRectMake(existingFrame.origin.x, existingFrame.origin.y, existingFrame.size.width, self.profileBarHeight);
    [UIView commitAnimations];
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

-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    self.navigationController.navigationBar.translucent = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //need to register for global notifications of events
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
    [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
    
    AuthenticationManager *authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==YES) {
        [self onUserLoggedIn];
    }
    else {
        [self onUserLoggedOut];
    }
    
    
    
    
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_profileBar_landscape_height = m_profileBar_landscape.frame.size.height;
    m_profileBar_portrait_height =m_profileBar_portrait.frame.size.height;
    
    
    
    //load the profile bar view
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice]orientation];
//    int x;
//    int y;
//    int width;
//    int height;
//    
//    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
//        x = kProfileBarX_Landscape;
//        y = kProfileBarY_Landscape;
//        width = kProfileBarWidth_Landscape;
//        height = kProfileBarHeight_Landscape;
//    }
//    else {
//        x = kProfileBarX;
//        y = kProfileBarY;
//        width = kProfileBarWidth;
//        height = kProfileBarHeight;
//    }
//    
//    
//    CGRect profileBarFrame = CGRectMake(x, y, width, height);
//    self.profileBar = [[UIProfileBar alloc]initWithFrame:profileBarFrame];
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
    NSString* activityName = @"HomeScreenController.onGetUserComplete";
}

-(void)onEnumerateFeedsComplete:(NSNotification*) notification {
    NSString* activityName = @"HomeScreenController.onEnumerateFeedsComplete:";
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

#pragma mark - System Event Handlers
- (void) onUserLoggedIn: (NSNotification*)notification {
    [self onUserLoggedIn];  
}

- (void) onUserLoggedOut:(NSNotification*)notification {
    [self onUserLoggedOut];
}

- (void) onUserLoggedIn {
    [self showProfileBar];
    [self enumerateFeed];
    
}

- (void) onUserLoggedOut {
    [self hideProfileBar];
}
@end
