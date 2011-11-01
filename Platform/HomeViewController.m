//
//  HomeViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "PageViewController.h"


@implementation HomeViewController
@synthesize contributeButton    = m_contributeButton;
@synthesize readButton          = m_readButton;

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

#pragma mark UI Event Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    PageViewController* pageController = [[PageViewController alloc]initWithNibName:@"PageViewController" bundle:nil];
    
    //TODO: calculate the page ID which the view controller should open to
    NSNumber* pageID = [NSNumber numberWithInt:0];
    pageController.pageID = pageID;
    
    [self.navigationController pushViewController:pageController animated:YES];
    [pageController release];
    
}

- (IBAction) onContributeButtonClicked:(id)sender {
    
}

@end
