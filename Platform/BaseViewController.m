//
//  BaseViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "PlatformAppDelegate.h"
#import "EventManager.h"
#import "CallbackResult.h"

@implementation BaseViewController

@synthesize authenticationManager = __authenticationManager;
@synthesize loggedInUser = __loggedInUser;
@synthesize feedManager           = __feedManager;
@synthesize managedObjectContext    =__managedObjectContext;
@synthesize eventManager          = __eventManager;

#pragma mark - Properties

- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    PlatformAppDelegate* appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication] delegate];
    __managedObjectContext = appDelegate.managedObjectContext;
    return __managedObjectContext;
    
}

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
    
    [self.eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
    [self.eventManager registerCallback:logoutCallback forSystemEvent:kUSERLOGGEDOUT];
    
    [loginCallback release];
    [logoutCallback release];
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


- (void) onUserLoggedIn:(CallbackResult*)result {
    
}

- (void) onUserLoggedOut:(CallbackResult*)result {
    
}

@end
