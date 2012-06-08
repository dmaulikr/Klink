//
//  AchievementsViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "AchievementsViewController.h"

@interface AchievementsViewController ()

@end

@implementation AchievementsViewController
@synthesize sv_scrollView = m_sv_scrollView;

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
    
    // Set up the scroll view
    self.sv_scrollView.contentSize = CGSizeMake(320, 730);
    self.sv_scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bookshelf.png"]];
    
    // Apply the bookshelf nav bar background
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"%f",version);
    UIImage *backgroundImage = [UIImage imageNamed:@"bookshelf_top.png"];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [self.navigationController.navigationBar.layer setContents:(id)backgroundImage.CGImage];
    }
    
    // Add custom styled Done button to nav bar
    UIButton *btn_rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_rightButton addTarget:self action:@selector(onDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];  
    btn_rightButton.frame = CGRectMake(0, 0, 52, 30);
    btn_rightButton.contentMode = UIViewContentModeCenter;
    
    btn_rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    btn_rightButton.titleLabel.textColor = [UIColor whiteColor];
    btn_rightButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    btn_rightButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    [btn_rightButton setTitle:@"Done" forState:UIControlStateNormal];
    
    UIImage* buttonImage = [[UIImage imageNamed:@"bookshelf_button.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    [btn_rightButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_rightButton] autorelease];
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [@"Mallard & Co." sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"Mallard & Co.";
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor brownColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor whiteColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove the bookshelf nav bar background
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
//    [self.navigationController.navigationBar setTranslucent:NO];
//    [self.navigationController.navigationBar setTintColor:nil];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    NSLog(@"%f",version);
//    if (version >= 5.0) {
//        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    }
//    else
//    {
//        [self.navigationController.navigationBar.layer setContents:nil];
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.sv_scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializers
+ (AchievementsViewController*)createInstance {
    AchievementsViewController* instance = [[[AchievementsViewController alloc]initWithNibName:@"AchievementsViewController" bundle:nil] autorelease];
    return instance;
}

@end
