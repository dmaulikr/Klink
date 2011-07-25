//
//  ProfileViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/18/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "ImageManager.h"

@implementation ProfileViewController
@synthesize img_ProfilePicture;
@synthesize pb_ProfileBar;
@synthesize btn_Captions;
@synthesize btn_Pictures;
@synthesize user;

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
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad
{
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

#pragma mark - Button handlers
- (IBAction)btn_Captions_Clicked:(id)sender {
    
}

-(IBAction)btn_Pictures_Clicked:(id)sender {
    
}

@end
