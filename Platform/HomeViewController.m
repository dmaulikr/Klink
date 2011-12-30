//
//  HomeViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "DraftViewController.h"
#import "ContributeViewController.h"
#import "CallbackResult.h"
#import "ProductionLogViewController.h"
#import "BookViewControllerBase.h"

#import "AuthenticationManager.h"
@implementation HomeViewController
@synthesize productionLogButton = m_productionLogButton;
//@synthesize contributeButton    = m_contributeButton;
//@synthesize newDraftButton      = m_newDraftButton;
@synthesize readButton          = m_readButton;
@synthesize loginButton         = m_loginButton;
@synthesize loginTwitterButton  = m_loginTwitterButton;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //let's refresh the feed
    [self.feedManager refreshFeedOnFinish:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.authenticationManager isUserAuthenticated]) {
        [self.loginButton setTitle:@"Logoff" forState:UIControlStateNormal];
        [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.loginButton addTarget:self action:@selector(onLogoffButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.loginButton addTarget:self action:@selector(onLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - System Event Handlers 
- (void) onUserLoggedIn:(CallbackResult*)result {
    [super onUserLoggedIn:result];
    
    [self.loginButton setTitle:@"Logoff" forState:UIControlStateNormal];
    [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.loginButton addTarget:self action:@selector(onLogoffButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) onUserLoggedOut:(CallbackResult*)result {
    [super onUserLoggedOut:result];
    
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
    [self.loginButton addTarget:self action:@selector(onLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark UI Event Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    BookViewControllerBase* bookController = [BookViewControllerBase createInstance];
    
    //TODO: calculate the page ID which the view controller should open to
    //NSNumber* pageID = [NSNumber numberWithInt:0];
    //pageController.pageID = pageID;
    
    [self.navigationController pushViewController:bookController animated:YES];
   // [bookController release];
    
    
    
    /*BookViewControllerPageView* bookController = [BookViewControllerPageView createInstance];
    
    //TODO: calculate the page ID which the view controller should open to
    //NSNumber* pageID = [NSNumber numberWithInt:0];
    //pageController.pageID = pageID;
    
    [self.navigationController pushViewController:bookController animated:YES];
    [bookController release];*/
    
    
    
    /*BookViewControllerLeaves* bookControllerLeaves = [BookViewControllerLeaves createInstance];
    
    //TODO: calculate the page ID which the view controller should open to
    //NSNumber* pageID = [NSNumber numberWithInt:0];
    //pageController.pageID = pageID;
    
    [self.navigationController pushViewController:bookControllerLeaves animated:YES];
    [bookControllerLeaves release];*/
    
    
    
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    ProductionLogViewController* productionLogController = [[ProductionLogViewController alloc]initWithNibName:@"ProductionLogViewController" bundle:nil];
    
    [self.navigationController pushViewController:productionLogController animated:YES];
    [productionLogController release];
}

/*- (IBAction) onContributeButtonClicked:(id)sender {
    //called when the contribute button is pressed
    DraftViewController* draftController = [[DraftViewController alloc]initWithNibName:@"DraftViewController" bundle:nil];
    
    //TODO: calculate the page ID which the view controller should open to
    NSNumber* pageID = [NSNumber numberWithInt:0];
    draftController.pageID = pageID;
    
    [self.navigationController pushViewController:draftController animated:YES];
    [draftController release];
}*/

/*- (IBAction) onNewDraftButtonClicked:(id)sender {
    //called when the new draft button is pressed
    if (![self.authenticationManager isUserAuthenticated]) {
        //user needs to authenticate first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onNewDraftButtonClicked:) onTargetObject:self withObject:sender];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstance];
        contributeViewController.delegate = self;
        contributeViewController.configurationType = PAGE;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
    }
}*/

- (IBAction) onLoginButtonClicked:(id)sender {
    if (![self.authenticationManager isUserAuthenticated]) {
        //no user is logged in currently
        [self authenticate:YES withTwitter:NO onFinishSelector:NULL onTargetObject:nil withObject:nil];
        
    }
}

- (IBAction) onLogoffButtonClicked:(id)sender {
    if ([self.authenticationManager isUserAuthenticated]) {
        [self.authenticationManager logoff];
    }
}

- (IBAction) onLoginTwitterButtonClicked:(id)sender {
    [self authenticate:NO withTwitter:YES onFinishSelector:NULL onTargetObject:nil withObject:nil];

}

#pragma mark - ConrtibuteViewControllerDelegate methods
- (void)onSubmitButtonPressed:(id)sender {
    
}

+ (HomeViewController*)createInstance {
    HomeViewController* homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    [homeViewController autorelease];
    return homeViewController;
}

@end
