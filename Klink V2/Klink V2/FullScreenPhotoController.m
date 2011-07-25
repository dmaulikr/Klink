//
//  FullScreenPhotoController.m
//  Klink V2
//
//  Created by Jordan Gurrieri on 7/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FullScreenPhotoController.h"
#import "ImageManager.h"
#import "DataLayer.h"

@interface FullScreenPhotoController () 
@property (nonatomic, retain) NSTimer *fadeTimer;
- (void) fadeBarController;
- (void) fadeBarAway:(NSTimer *)timer;
- (void) fadeBarIn;
@end

@implementation FullScreenPhotoController
@synthesize imageView;
@synthesize submittedByLabel;
@synthesize captionLabel;
@synthesize photo;
@synthesize theme;
@synthesize caption;
@synthesize user;
@synthesize fadeTimer;

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
    [imageView release];
    [fadeTimer release];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self fadeBarController];
    if (self.fadeTimer != nil)
    {			
        [self.fadeTimer invalidate];
    }
    self.fadeTimer  = [NSTimer
                       scheduledTimerWithTimeInterval:kNavigationBarFadeDelay target:self
                       selector:@selector(fadeBarAway:) userInfo:nil repeats:NO];
    
    if (self.theme == nil) {
        //no theme set for this view to display, retrieve the latest theme from the DB
        self.theme = [DataLayer getNewestTheme];
    }
    
    
    ImageManager* imageManager = [ImageManager getInstance];
    //NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
    //[userInfo setObject:imageView forKey:an_IMAGEVIEW];        
    
    UIImage* image = [imageManager downloadImage:theme.homeimageurl withUserInfo:nil atCallback:self];   
    
    if (image != nil) {
        imageView.image = image;
    }
    else {
        imageView.backgroundColor =[UIColor blackColor];
    }
    
    //captionLabel.text = captionLabel.text;
        
}

-(void) viewWillUnload:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidUnload
{    
    self.imageView = nil;
    [self.fadeTimer invalidate];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Fade In/Out code
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) event {
    [super touchesEnded:touches withEvent:event];
    [self fadeBarController];
}

- (void)fadeBarController {
    if (self.fadeTimer != nil)
    {			
        [self.fadeTimer invalidate];
    }
    
    if (self.navigationController.navigationBar.alpha == 0.0)
    {
        [self fadeBarIn];
        self.fadeTimer  = [NSTimer
                           scheduledTimerWithTimeInterval:kNavigationBarFadeDelay target:self
                           selector:@selector(fadeBarAway:) userInfo:nil repeats:NO];
    } else {
        self.fadeTimer  = [NSTimer
                           scheduledTimerWithTimeInterval:0 target:self
                           selector:@selector(fadeBarAway:) userInfo:nil repeats:NO];
    }
}

- (void)fadeBarAway:(NSTimer*)timer {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    self.navigationController.navigationBar.alpha = 0.0;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView commitAnimations];
}

- (void)fadeBarIn {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    self.navigationController.navigationBar.alpha = 1.0;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView commitAnimations];
}


@end
