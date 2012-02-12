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
@synthesize baseURL     = m_baseURL;

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

#pragma mark - Back button handler
// The following enables the nav bar back button to work like a web browser back button
- (void)updateBackButton {
    if ([self.wv_webView canGoBack]) {
        if (!self.navigationItem.leftBarButtonItem) {
            [self.navigationItem setHidesBackButton:YES animated:YES];
            UIBarButtonItem *backItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backWasClicked:)] autorelease];
            [self.navigationItem setLeftBarButtonItem:backItem animated:YES];
        }
    }
    else {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (void)backWasClicked:(id)sender {
    if ([self.wv_webView canGoBack]) {
        [self.wv_webView goBack];
    }
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	//Capture user link-click.
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[self.wv_webView setScalesPageToFit:YES];
        
        NSURL *URL = [request URL];	
		NSLog(@"url is: %@s ", URL);
	}	
	return YES;   
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateBackButton];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateBackButton];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Setup Deflauts
    // If no title specified set Navigation bar to default
    if (self.navBarTitle == nil) {
        self.navBarTitle = @"Bahndr";
    }
    
    // If no baseURL specified set default to the app bundle
    if (self.baseURL == nil) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        self.baseURL = [NSURL fileURLWithPath:path];
        
        // Load the default style to the HTML doc by adding the Message.css file from the app bundle
        self.htmlString = [NSString stringWithFormat:@"<head> <link rel='stylesheet' type='text/css' href='Message.css' /> </head> %@", self.htmlString];
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
    
    // load the HTML doc
    //NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:self.baseURL];
    //[requestObj setHTTPBody:[self.htmlString dataUsingEncoding:NSUTF8StringEncoding]];
    //[self.wv_webView loadRequest:requestObj];
    [self.wv_webView loadHTMLString:self.htmlString baseURL:self.baseURL];
    
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

+ (WebViewController*)createInstanceWithTitle:(NSString*)title withHTMLString:(NSString*)htmlString withBaseURL:(NSURL*)baseURL {
    WebViewController* instance = [[[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil] autorelease];
    instance.navBarTitle = title;
    instance.htmlString = htmlString;
    instance.baseURL = baseURL;
    return instance;
}

@end
