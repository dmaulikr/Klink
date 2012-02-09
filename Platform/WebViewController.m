//
//  WebViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 2/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize wv_webView  = m_wv_webView;
@synthesize navBarTitle = m_navBarTitle;
@synthesize htmlString  = m_htmlString;

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
    
    // If no title specified set Navigation bar to default
    if (self.navBarTitle == nil) {
        self.navBarTitle = @"Bahndr";
    }
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [self.navBarTitle sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = self.navBarTitle;
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
    [self.wv_webView loadHTMLString:self.htmlString baseURL:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.wv_webView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Hide toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Static Initializers
+ (WebViewController*)createInstance {
    WebViewController* instance = [[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil] autorelease];
    return instance;
}

+ (WebViewController*)createInstanceWithTitle:(NSString*)title {
    WebViewController* instance = [[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil] autorelease];
    instance.navBarTitle = title;
    return instance;
}

+ (WebViewController*)createInstanceWithHTMLString:(NSString*)htmlString withTitle:(NSString*)title {
    WebViewController* instance = [[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil] autorelease];
    instance.htmlString = htmlString;
    instance.navBarTitle = title;
    return instance;
}

@end
