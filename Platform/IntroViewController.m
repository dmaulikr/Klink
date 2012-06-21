//
//  IntroViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController
@synthesize btn_read    = m_btn_read;
@synthesize btn_write   = m_btn_write;

#pragma mark - Delegate Definitions
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<IntroViewControllerDelegate>)del
{
    m_delegate = del;
}


#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIButton Handlers
- (IBAction) onReadButtonPressed:(id)sender {
    
}

- (IBAction) onWriteButtonPressed:(id)sender {
    
}

#pragma mark - Static Initializers
+ (IntroViewController*)createInstance {
    IntroViewController* retVal = [[IntroViewController alloc]initWithNibName:@"IntroViewController" bundle:nil];
    [retVal autorelease];
    return retVal;
}

@end
