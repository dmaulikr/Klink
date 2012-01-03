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
#import "NotificationsViewController.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"

#import "AuthenticationManager.h"
@implementation HomeViewController
@synthesize btn_productionLogButton = m_btn_productionLogButton;
//@synthesize contributeButton    = m_contributeButton;
//@synthesize newDraftButton      = m_newDraftButton;
@synthesize btn_readButton          = m_btn_readButton;
//@synthesize loginButton         = m_loginButton;
//@synthesize loginTwitterButton  = m_loginTwitterButton;
@synthesize btn_writersLogButton    = m_btn_writersLogButton;
@synthesize iv_bookCover            = m_iv_bookCover;
@synthesize lbl_numContributors     = m_lbl_numContributors;

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


#pragma mark - Book cover open animation
- (void) pageOpenView:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToOpen.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToOpen.hidden = NO;
    
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
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipViewOpen"];
}

- (void) pageCloseView:(UIView *)viewToClose duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToClose.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToClose.hidden = NO;
    
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
                ProductionLogViewController* productionLogController = [[ProductionLogViewController alloc]initWithNibName:@"ProductionLogViewController" bundle:nil];
                
                // Set up navigation bar back button
                self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Book"
                                                                                          style:UIBarButtonItemStyleBordered
                                                                                         target:nil
                                                                                         action:nil] autorelease];
                [self.navigationController pushViewController:productionLogController animated:YES];
                [productionLogController release];
            }
            else {
                // book was opened, hide the cover
                
                // Now we just hide the animated view since
                // animation.removedOnCompletion is not working
                // in animation groups. Hiding the view prevents it
                // from returning to the original state and showing.
                self.iv_bookCover.hidden = YES;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //let's refresh the feed
    [self.feedManager refreshFeedOnFinish:nil];
    
    // set number of contributors label
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    //int numContributors = [settings.num_users intValue];
    NSNumber* numContributors = settings.num_users;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    NSString* numContributorsCommaString = [numberFormatter stringForObjectValue:numContributors];
    [numberFormatter release];
    self.lbl_numContributors.text = [NSString stringWithFormat:@"%@ contributors", numContributorsCommaString];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // unhide navigation bar and toolbar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    // unhide the book cover
    [self.iv_bookCover setHidden:NO];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // hide navigation bar and toolbar
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.toolbar.hidden = YES;
    
    /*if ([self.authenticationManager isUserAuthenticated]) {
        [self.loginButton setTitle:@"Logoff" forState:UIControlStateNormal];
        [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.loginButton addTarget:self action:@selector(onLogoffButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.loginButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
        [self.loginButton addTarget:self action:@selector(onLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }*/
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self openBook];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*#pragma mark - System Event Handlers 
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
}*/

#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if (buttonIndex == 1 && alertView.delegate == self) {
        if (![self.authenticationManager isUserAuthenticated]) {
            // user is not logged in
            [self authenticate:YES withTwitter:NO onFinishSelector:alertView.onFinishSelector onTargetObject:self withObject:nil];
        }
    }
}


#pragma mark UI Event Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    
    // Set up navigation bar back button
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Title Page"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    BookViewControllerBase* bookController = [BookViewControllerBase createInstance];
    
    //TODO: calculate the page ID which the view controller should open to
    //NSNumber* pageID = [NSNumber numberWithInt:0];
    //pageController.pageID = pageID;
    
    [self.navigationController pushViewController:bookController animated:YES];
    [bookController release];
    
    
    
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
    
    [self closeBook];
    
    //ProductionLogViewController* productionLogController = [[ProductionLogViewController alloc]initWithNibName:@"ProductionLogViewController" bundle:nil];
    
    /*// Modal naviation
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:productionLogController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    navigationController.toolbarHidden = NO;
    
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];*/
    
    // Set up navigation bar back button
    //self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Book"
    //                                                                          style:UIBarButtonItemStyleBordered
    //                                                                         target:nil
    //                                                                         action:nil] autorelease];
    //[self.navigationController pushViewController:productionLogController animated:YES];
    //[productionLogController release];
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    //called when the writer's log button is pressed
    if (![self.authenticationManager isUserAuthenticated]) {
        UICustomAlertView *alert = [[UICustomAlertView alloc]
                                    initWithTitle:@"Login Required"
                                    message:@"Hello! You must punch-in on the production floor to access your profile.\n\nPlease login, or join us as a new contributor via Facebook."
                                    delegate:self
                                    onFinishSelector:@selector(onWritersLogButtonClicked:)
                                    onTargetObject:self
                                    withObject:nil
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Login", nil];
        [alert show];
        [alert release];
    }
    else {
        NotificationsViewController* notificationsViewController = [NotificationsViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
}


+ (HomeViewController*)createInstance {
    HomeViewController* homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    [homeViewController autorelease];
    return homeViewController;
}

@end
