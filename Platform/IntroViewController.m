//
//  IntroViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "IntroViewController.h"
#import <QuartzCore/QuartzCore.h>

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
        
        // Add rounded corners to custom buttons
        self.btn_read.layer.cornerRadius = 8;
        self.btn_write.layer.cornerRadius = 8;
        
        // Add border to custom buttons
        [self.btn_read.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [self.btn_read.layer setBorderWidth: 1.0];
        [self.btn_write.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [self.btn_write.layer setBorderWidth: 1.0];
        
        // Add mask on custom buttons
        [self.btn_read.layer setMasksToBounds:YES];
        [self.btn_write.layer setMasksToBounds:YES];
        
        // Set text shadow of custom buttons
//        [self.btn_read.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
//        [self.btn_write.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        // Set highlight state background color of custom buttons
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *lightGreyImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.btn_read setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
        [self.btn_write setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
        [self.btn_read setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [self.btn_write setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.btn_read = nil;
    self.btn_write = nil;
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
    [self.delegate introReadButtonPressed];
}

- (IBAction) onWriteButtonPressed:(id)sender {
    [self.delegate introWriteButtonPressed];
}

#pragma mark - Static Initializers
+ (IntroViewController*)createInstance {
    IntroViewController* retVal = [[IntroViewController alloc]initWithNibName:@"IntroViewController" bundle:nil];
    [retVal autorelease];
    return retVal;
}

@end
