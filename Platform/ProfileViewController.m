//
//  ProfileViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
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
    
    // Navigation Bar Buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButtonPressed:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    
    // Set the navigationbar title
    self.navigationItem.title = @"Writers's Log";
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializers
+ (ProfileViewController*)createInstance {
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    return instance;
}

@end
