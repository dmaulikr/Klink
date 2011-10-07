//
//  LoginViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "LoginViewController.h"
#import "BLLog.h"
#import "SA_OAuthTwitterEngine.h"
#import "ApplicationSettings.h"
#import "AuthenticationManager.h"
#import "FBConnect.h"
#import "NSStringGUIDCategory.h"
#import "User.h"

#define kMinimumBusyWaitTime    1
#define kMaximumBusyWaitTimePutAuthenticator    6
#define kMaximumBusyWaitTimeFacebookLogin       6
#define kTimeToShowCompleteIndicator 2


@implementation LoginViewController
@synthesize twitterEngine           = __twitterEngine;
@synthesize selPerformOnFinish      = m_selPerformOnFinish;
@synthesize doTwitterAuth           = m_doTwitterAuth;
@synthesize doFacebookAuth          = m_doFacebookAuth;
@synthesize callbackTarget          = m_callbackTarget;
@synthesize progressIndicator       = m_progressIndicator;
@synthesize isBusy                  = m_isBusy;
@synthesize isProgressBarShowing    = m_isProgressBarShowing;
#pragma mark - Properties
- (SA_OAuthTwitterEngine*) twitterEngine {
    if (__twitterEngine != nil) {
        return __twitterEngine;
    }
    __twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
	__twitterEngine.consumerKey = twitter_CONSUMERKEY;
	__twitterEngine.consumerSecret = twitter_CONSUMERSECRET;
    
    return __twitterEngine;
    
}
- (id) init {
    self = [super init];
    if (self) {
        self.view.opaque = NO;
        self.view.backgroundColor = [UIColor clearColor];
        self.isBusy = NO;
        self.isProgressBarShowing = NO;
    }
    return self;
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
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Progress Bar Monitoring
- (void) waitUntilNotBusy:(NSNumber*)maximumDisplayTime {
    NSString* activityName = @"LoginVieController.waitUntilNotBusy";
    NSDate* startTime = [NSDate date];
    BOOL shouldContinueWaiting = YES;
    
    while (shouldContinueWaiting) {
        [NSThread sleepForTimeInterval:1];
        
        NSDate* currentTime = [NSDate date];
        double timeRunningInSeconds = [currentTime timeIntervalSinceDate:startTime];
        
        if ( (self.isBusy && timeRunningInSeconds > kMinimumBusyWaitTime)) {
            //in this branch, the operation has completed and the minimum time threshold met, we break
            shouldContinueWaiting = NO;
        }
        else if ((!self.isBusy && timeRunningInSeconds > [maximumDisplayTime intValue])) {
            //error condition, somethind has gone wrong and we have timed out
            shouldContinueWaiting = NO;
            NSString* message =[NSString stringWithFormat:@"Progress indicator has exceeded maximum threshold time of %d",[maximumDisplayTime intValue]];
            [BLLog e:activityName withMessage:message];
        }
        currentTime = nil;
    }

}

- (void) showProgressBar: (NSString*)message withCustomView:(UIView*)view withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds {

    self.isBusy = YES;
    self.progressIndicator.labelText = message;
    
    if (view != nil) {
        self.progressIndicator.customView = view;
        self.progressIndicator.mode = MBProgressHUDModeCustomView;
    }
    else {
        self.progressIndicator.customView = nil;
        self.progressIndicator.mode = MBProgressHUDModeIndeterminate;
    }
    
    self.isProgressBarShowing = YES;
    [self.progressIndicator showWhileExecuting:@selector(waitUntilNotBusy:) onTarget:self withObject:maximumTimeInSeconds animated:YES];

}

- (void) showProgressBarComplete {
    self.isBusy = YES;
    self.progressIndicator.labelText = @"Login Complete";
    [self.progressIndicator.customView removeFromSuperview];
    self.progressIndicator.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.progressIndicator.mode = MBProgressHUDModeCustomView;
  
    self.isProgressBarShowing = YES;
    [self.progressIndicator showWhileExecuting:@selector(waitUntilNotBusy:) onTarget:self withObject:[NSNumber numberWithInt:kTimeToShowCompleteIndicator] animated:YES];
    
}



#pragma mark - Async Notification handlers
- (void) processUpdateAuthenticatorCompleted {
    
    
    //wait for the progress indicator to hide itself   
    while (self.isProgressBarShowing) {
        sleep(1);
    }
    
    self.isProgressBarShowing = YES;
    [self performSelectorOnMainThread:@selector(showProgressBarComplete) withObject:nil waitUntilDone:NO]; 
    while (self.isProgressBarShowing) {
        [NSThread sleepForTimeInterval:1];
    }
    
    //close the view controller
    [self dismiss];

}

- (void) onUpdateAuthenticatorCompleted:(NSNotification*)notification {
   //we process this response on a background thread to prevent it from interfering with
    //the progress indicator
    self.isBusy = NO;
    [NSThread detachNewThreadSelector:@selector(processUpdateAuthenticatorCompleted) toTarget:self withObject:nil];
}

- (void) processGetAuthenticationDownloaded:(NSDictionary*)userInfo {
    NSString* activityName = @"LoginViewController.processGetAuthenticationDownloaded:";
    AuthenticationContext* newContext = [[userInfo objectForKey:an_AUTHENTICATIONCONTEXT]retain];
    User* user = [[userInfo objectForKey:an_USER]retain];
    
    NSString* message = [NSString stringWithFormat:@"Authentication context received from server, logging in user: %@",newContext.userid];
    [BLLog v:activityName withMessage:message];
    
    //save the user object that is returned to us in the database
    [ServerManagedResource refreshWithServerVersion:user];
    
    //now we instruct the AuthenticationManager to login the user within our app
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    [authnManager loginUser:newContext.userid withAuthenticationContext:newContext];
    
    AuthenticationContext* context = [authnManager getAuthenticationContext];
    
    //we have to wait for the progress bar to disappear
    self.isBusy = NO;
    //[self.progressIndicator hide:YES];
    while (self.isProgressBarShowing) {
        //sleep for a second and re-check
        [NSThread sleepForTimeInterval:1];
    }
    
    //at this point the progress indicator should be hidden
    
    if (self.doTwitterAuth) {
        if (![context hasTwitter]) {
            [self performSelectorOnMainThread:@selector(beginTwitterAuthentication) withObject:self waitUntilDone:NO];
        }
        else {
            self.isProgressBarShowing = YES;
            [self performSelectorOnMainThread:@selector(showProgressBarComplete) withObject:nil waitUntilDone:NO];
            while (self.isProgressBarShowing) {
                [NSThread sleepForTimeInterval:1];
            }
            [self dismiss];
        }
    }
    else {
        self.isProgressBarShowing = YES;
        [self performSelectorOnMainThread:@selector(showProgressBarComplete) withObject:nil waitUntilDone:NO];
        while (self.isProgressBarShowing) {
            [NSThread sleepForTimeInterval:1];
        }
        [self dismiss];
    }
 
}


- (void) onGetAuthenticationContextDownloaded:(NSNotification*)notification {
   
    NSDictionary* userInfo = [notification userInfo];
    [NSThread detachNewThreadSelector:@selector(processGetAuthenticationDownloaded:) toTarget:self withObject:userInfo];
        
}

#pragma mark - Instance Methods
-(void) beginTwitterAuthentication {
    //we check to see if the user has supplied their Twitter accessToken, if not, then we move to the next page
    //and display a twitter authn screen
    NSString* activityName = @"LoginViewController.beginTwitterAuthentication:";
    AuthenticationContext* newContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    if (newContext != nil && ![newContext hasTwitter]) 
    {
        
        NSString* message = [NSString stringWithFormat:@"User's twitter data missing, starting  twitter authentication"];
        [BLLog v:activityName withMessage:message];
        
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: self.twitterEngine delegate: self];
        
        if (controller) 
            [self presentModalViewController: controller animated: YES];
        else {
            
            [self.twitterEngine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
        }
        
    }


}
-(void) beginFacebookAuthentication {
    //now we need to grab their facebook authentication data, and then log them into our app    
    NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", @"publish_stream",@"user_about_me", nil];
    Facebook* facebook = [AuthenticationManager getInstance].facebook;
    
    if (![facebook isSessionValid]) {
       
        
        [facebook authorize:permissions delegate:self];
    }
    
}

#pragma mark - View lifecycle
- (void) dismiss {
    if (self.callbackTarget != nil && self.selPerformOnFinish != nil) {
        [self.callbackTarget performSelector:self.selPerformOnFinish withObject:self];
    }
    [self.parentViewController dismissModalViewControllerAnimated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
//    [super viewWillAppear:animated];
//    
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.tintColor = nil;
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.progressIndicator = [[MBProgressHUD alloc]initWithView:self.view];
    self.progressIndicator.delegate = self;
    [self.view addSubview:self.progressIndicator]; 

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    
    //everytime the view appears, we check to see if the user is logged in, if not, then we begin
    //the login sequence starting with facebook
    if (self.doFacebookAuth) {
        AuthenticationManager* authnManager = [AuthenticationManager getInstance];
        if (![authnManager isUserLoggedIn]) {
            //authenticate with facebook
            [self beginFacebookAuthentication];
        }
        else {
           // [self dismiss];
        }
    }
    else if (self.doTwitterAuth) {
        AuthenticationManager* authnManager = [AuthenticationManager getInstance];
        if ([authnManager isUserLoggedIn]) {
            AuthenticationContext* context = [authnManager getAuthenticationContext];
            if (![context hasTwitter]) {
                //authenticate with twitter 
                [self beginTwitterAuthentication];
            }
            else {
               // [self dismiss];
               

            }
        }
        else {
            [self beginFacebookAuthentication];
        }
    }
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.progressIndicator.delegate = nil;
    [self.progressIndicator removeFromSuperview];
    self.progressIndicator = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
    
    //now we need to update the user's object and twitter information
    AuthenticationManager* authManager = [AuthenticationManager getInstance];
    
    NSArray* components = [data componentsSeparatedByString:@"&"];
    if ([components count] == 4) {

        NSString* oAuthToken = [[[components objectAtIndex:0]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* oAuthTokenSecret = [[[components objectAtIndex:1]componentsSeparatedByString:@"="]objectAtIndex:1];
        NSString* twitterUserName = [[[components objectAtIndex:3]componentsSeparatedByString:@"="]objectAtIndex:1];
        
        NSString* notificationID = [NSString GetGUID];
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onUpdateAuthenticatorCompleted:) name:notificationID object:nil];
        
        //need to dismiss the Twitter view controller here
        [self dismissModalViewControllerAnimated:YES];
        
        //display progress indicator
        
        [self showProgressBar:@"Contacting Twitter..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimePutAuthenticator]];
               
        
        [authManager updateAuthentiationContextWith:twitterUserName withAccessToken:oAuthToken withAccessTokenSecret:oAuthTokenSecret withExpiryDate:@"" onFinishNotify:notificationID];
    }
    else {
        //error condition
        //need to dismiss the Twitter view controller here
        [self dismissModalViewControllerAnimated:YES];
    }
    
    
    

}


#pragma mark - MBProgressHudDelegate
- (void) hudWasHidden {
    self.isProgressBarShowing = NO;
}

- (void) hudWasHidden:(MBProgressHUD *)hud {
    self.isProgressBarShowing = NO;
}

#pragma mark - FBRequestDelegate
- (void) request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"LoginViewController.request:didLoad:";
    Facebook* facebook = [AuthenticationManager getInstance].facebook;
    WS_EnumerationManager *enumerationManager = [WS_EnumerationManager getInstance];
    NSString* facebookIDString = [result valueForKey:an_ID];
    NSNumber* facebookID = [facebookIDString numberValue];
    NSString* displayName = [result valueForKey:an_NAME];
    NSString* notificationID = [NSString GetGUID];
    
    //we request offline permission, so the FB expiry date isnt needed. we set this to the current date, itsmeaningless
    
    //Add an observer so that we can listen in for when authentication is complete
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onGetAuthenticationContextDownloaded:) name:notificationID object:nil];
    
    
    NSString* nm = [NSString stringWithFormat:@"Returned facebook token: %@",facebook.accessToken];
    [BLLog v:activityName withMessage:nm];
    [enumerationManager getAuthenticatorToken:facebookID withName:displayName withFacebookAccessToken:facebook.accessToken withFacebookTokenExpiry:facebook.expirationDate onFinishNotify:notificationID];
}

#pragma mark - FBSessionDelegate
- (void) fbDidLogin {
    NSString* activityName = @"AuthenticationManager.fbDidLogin:";
    Facebook* facebook = [AuthenticationManager getInstance].facebook;
    
    //this method is called upon the completion of the authorize operation
    NSString* message = [NSString stringWithFormat:@"Facebook login successful, accessToken:%@, expiryDate:%@",facebook.accessToken,facebook.expirationDate];    
    [BLLog v:activityName withMessage:message];
        
    
    [self showProgressBar:@"Getting Facebook data..." withCustomView:nil withMaximumDisplayTime:[NSNumber numberWithInt:kMaximumBusyWaitTimeFacebookLogin]];
    //the user has authorized our app, now we get his user object to complete authentication
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    


}

- (void) fbDidNotLogin:(BOOL)cancelled {
        //TODO: what to do on user cancellation
    self.isBusy = NO;
    
}


#pragma mark - Static Initializers
+ (id) controllerForTwitterLogin:(id)callbackTarget onFinishPerform:(SEL)performOnFinish {
    LoginViewController* newController = [[[LoginViewController alloc]init]autorelease];
    newController.selPerformOnFinish = performOnFinish;
    newController.callbackTarget = callbackTarget;
    newController.doTwitterAuth = YES;
    newController.doFacebookAuth = NO;
    return newController;
}


+ (id) controllerForFacebookLogin:(id)callbackTarget onFinishPerform:(SEL)performOnFinish{
    LoginViewController* newController = [[[LoginViewController alloc]init]autorelease];
    newController.selPerformOnFinish = performOnFinish;
    newController.callbackTarget= callbackTarget;
    newController.doTwitterAuth = NO;
    newController.doFacebookAuth = YES;
    return newController;
}
@end
