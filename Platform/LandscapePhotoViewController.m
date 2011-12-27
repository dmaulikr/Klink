//
//  LandscapePhotoViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/7/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "LandscapePhotoViewController.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ResourceContext.h"

#define kPHOTOID @"photoid"

@implementation LandscapePhotoViewController
@synthesize iv_landscapePhoto = m_iv_landscapePhoto;
@synthesize photoID = m_photoID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.wantsFullScreenLayout = YES;
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
    
    // Setup notification for device orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate)
                                                 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
}

- (void) dealloc {
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // hide status bar and navigation bar
    if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	}
    self.navigationController.navigationBar.hidden = YES;
    
    // Show photo
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Photo* currentPhoto = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:currentPhoto.objectid forKey:kPHOTOID];
    
    if (currentPhoto.imageurl != nil && ![currentPhoto.imageurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:currentPhoto.imageurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            self.iv_landscapePhoto.image = image;
        }
    }
    
    [self.view setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show status bar and navigation bar
    if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	}
    self.navigationController.navigationBar.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES; //(interfaceOrientation == UIInterfaceOrientationLandPortrait);
}

- (void) didRotate {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializers
+ (LandscapePhotoViewController*)createInstanceWithPhotoID:(NSNumber*)photoID {
    LandscapePhotoViewController* instance = [[LandscapePhotoViewController alloc]initWithNibName:@"LandscapePhotoViewController" bundle:nil];
    instance.photoID = photoID;
    [instance autorelease];
    return instance;
}

@end
