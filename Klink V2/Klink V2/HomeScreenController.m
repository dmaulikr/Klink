//
//  HomeScreenController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "HomeScreenController.h"
#import "NSStringGUIDCategory.h"
#import "ThemeBrowserViewController2.h"
#import "FullScreenPhotoController.h"
#import "LoginViewController.h"
@implementation HomeScreenController
@synthesize managedObjectContext;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
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

-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewDidLoad
{
    self.shouldShowProfileBar = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void) didRotate : (NSNotification*)notification {
    [super didRotate:notification];
    
    
}


#pragma mark - Event Handlers
- (IBAction)onButtonClicked:(id)sender {
    
    if (sender == button1) {
        LoginViewController* loginViewController = [LoginViewController controllerForFacebookLogin:self onFinishPerform:nil];
        //[self.navigationController pushViewController:loginViewController animated:YES];
       
          [self.navigationController presentModalViewController:loginViewController animated:YES];
      //  [self.navigationController pushViewController:loginViewController animated:YES];
       // [loginViewController beginTwitterAuthentication];
//        AuthenticationManager* authManager = [AuthenticationManager getInstance];
//        if (![authManager getLoggedInUserID]) {
//            //need to login
//            [authManager authenticate];
//        }
//        else {
//            //user is already logged in
//            NSLog(@"No need to log in user, they already are logged in");
//        }
        

    }
    else if (sender == button2) {
        ThemeBrowserViewController2* themeBrowserController2 = [[ThemeBrowserViewController2 alloc]initWithNibName:@"ThemeBrowserViewController2" bundle:nil];
        
        themeBrowserController2.managedObjectContext = self.managedObjectContext;
        themeBrowserController2.shouldShowProfileBar = YES;
        [self.navigationController pushViewController:themeBrowserController2 animated:YES];
        [themeBrowserController2 release];
    }
    else if (sender == button3) {
        //logoff
        AuthenticationManager* authManager = [AuthenticationManager getInstance];
        [authManager logoff];
    }
    else if (sender == button4) {
        //enumerate feed
        [super enumerateFeed];      
    }
}

@end
