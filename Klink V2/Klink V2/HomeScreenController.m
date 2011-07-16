//
//  HomeScreenController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "HomeScreenController.h"
#import "ThemeBrowserController.h"
#import "ThemeBrowserViewController2.h"
#import "InfinitePageViewer.h"
@implementation HomeScreenController
@synthesize managedObjectContext;
@synthesize button1;
@synthesize button2;
@synthesize button3;
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

#pragma mark - Event Handlers
- (IBAction)onButtonClicked:(id)sender {
    
    if (sender == button1) {
        ThemeBrowserController* themeBrowserController = [[ThemeBrowserController alloc]initWithNibName:@"ThemeBrowserController" bundle:nil];
        
        themeBrowserController.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:themeBrowserController animated:YES];
        [themeBrowserController release];
    }
    else if (sender == button2) {
        ThemeBrowserViewController2* themeBrowserController2 = [[ThemeBrowserViewController2 alloc]initWithNibName:@"ThemeBrowserViewController2" bundle:nil];
        
        themeBrowserController2.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:themeBrowserController2 animated:YES];
        [themeBrowserController2 release];
    }
    else if (sender == button3) {
        InfinitePagingViewController* c = [[InfinitePagingViewController alloc]initWithNibName:@"InfinitePagingViewController" bundle:nil];
        [self.navigationController pushViewController:c animated:YES];
    }
}

@end
