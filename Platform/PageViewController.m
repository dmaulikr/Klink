//
//  PageViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PageViewController.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "DateTimeHelper.h"
#import "UIImageView+UIImageViewCategory.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"
#define kPHOTOFRAMETHICKNESS 30

@implementation PageViewController
@synthesize iv_openBookPageImage = m_iv_openBookPageImage;
@synthesize pageID = m_pageID;
@synthesize topVotedPhotoID = m_topVotedPhotoID;
@synthesize pageNumber = m_pageNumber;
@synthesize lbl_title = m_lbl_title;
@synthesize iv_photo = m_iv_photo;
@synthesize iv_photoFrame = m_iv_photoFrame;
@synthesize lbl_caption = m_lbl_caption;
@synthesize lbl_photoby = m_lbl_photoby;
@synthesize lbl_captionby = m_lbl_captionby;
@synthesize lbl_publishDate = m_lbl_publishDate;
@synthesize lbl_pageNumber = m_lbl_pageNumber;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;


#pragma mark - Initializers
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


#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (!m_controlsHidden) {
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO] ;
	}
}

- (void)setControlsHidden:(BOOL)hidden {
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	
	/*// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;*/
    
    // Navigation and tool bars
	[self.parentViewController.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [self.parentViewController.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
	[UIView commitAnimations];
	
    // reset the controls hidden flag
    m_controlsHidden = hidden;
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay:5];
	
}

- (void)hideControls { 
    [self setControlsHidden:YES]; 
}

- (void)showControls { 
    [self cancelControlHiding];
    [self setControlsHidden:NO];
}

- (void)toggleControls {
    [self setControlsHidden:!m_controlsHidden]; 
}

#pragma mark - Photo Frame Helper
- (void) displayPhotoFrameOnImage:(UIImage*)image {
    // get the frame for the new scaled image in the Photo ImageView
    CGRect scaledImage = [self.iv_photo frameForImage:image inImageViewAspectFit:self.iv_photo];
    
    // create insets to cap the photo frame according to the size of the scaled image
    UIEdgeInsets photoFrameInsets = UIEdgeInsetsMake(scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS);
    
    // apply the cap insets to the photo frame image
    UIImage* img_photoFrame = [UIImage imageNamed:@"picture_frame.png"];
    if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
        self.iv_photoFrame.image = [img_photoFrame resizableImageWithCapInsets:photoFrameInsets];
        
        // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
        self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
    }
    else {
        self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:(int)photoFrameInsets.left topCapHeight:(int)photoFrameInsets.top];
        //self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:(scaledImage.size.width/2) topCapHeight:scaledImage.size.height/2];
        
        // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
        //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.origin.y, (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.size.height);
        self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS/2), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
    }
    
    // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
    //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.origin.y, (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.size.height);
    //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Create gesture recognizer for the photo image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_openBookPageImage addGestureRecognizer:oneFingerTap];
    
    [self.lbl_title setFont:[UIFont fontWithName:@"TravelingTypewriter" size:24]];
    [self.lbl_caption setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
    [self.lbl_captionby setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_photoby setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_publishDate setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_pageNumber setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (page != nil) {
        Photo* photo = [page photoWithHighestVotes];
        self.topVotedPhotoID = photo.objectid;
        
        Caption* caption = [page captionWithHighestVotes];
        
        NSDate* datePublished = [DateTimeHelper parseWebServiceDateDouble:photo.datecreated];
        
        self.lbl_title.text = page.displayname;
        self.lbl_caption.text = [NSString stringWithFormat:@"\"%@\"", caption.caption1];
        self.lbl_captionby.text = [NSString stringWithFormat:@"- written by %@", photo.creatorname];
        self.lbl_photoby.text = [NSString stringWithFormat:@"- illustrated by %@", photo.creatorname];
        self.lbl_publishDate.text = [NSString stringWithFormat:@"published: %@", [DateTimeHelper formatMediumDate:datePublished]];
        self.lbl_pageNumber.text = [NSString stringWithFormat:@"- %@ -", [self.pageNumber stringValue]];
        
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:page.objectid forKey:kPAGEID];
        
        //add the photo id to the context
        [userInfo setValue:photo.objectid forKey:kPHOTOID];
        
        if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            
            if (image != nil) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_photo.image = image;
                
                [self displayPhotoFrameOnImage:image];
                
                /*self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_photo.image = image;
                
                // get the frame for the new scaled image in the Photo ImageView
                CGRect scaledImage = [self.iv_photo frameForImage:image inImageViewAspectFit:self.iv_photo];
                
                // create insets to cap the photo frame according to the size of the scaled image
                UIEdgeInsets photoFrameInsets = UIEdgeInsetsMake(scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS);
                
                // apply the cap insets to the photo frame image
                UIImage* img_photoFrame = [UIImage imageNamed:@"picture_frame.png"];
                if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
                    self.iv_photoFrame.image = [img_photoFrame resizableImageWithCapInsets:photoFrameInsets];
                    
                    // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
                    self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
                }
                else {
                    self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:(int)photoFrameInsets.left topCapHeight:(int)photoFrameInsets.top];
                    //self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:(scaledImage.size.width/2) topCapHeight:scaledImage.size.height/2];
                    
                    // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
                    //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.origin.y, (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.size.height);
                    self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS/2), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
                }
                
                // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
                //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.origin.y, (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.size.height);
                //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));*/
            }
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
        }
        
        
        /*if (photo.thumbnailurl != nil && 
         ![photo.thumbnailurl isEqualToString:@""]) 
         {
         Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
         UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
         [callback release];
         
         if (image != nil) {
         self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
         self.iv_photo.image = image;
         
         // get the frame for the new scaled image in the Photo ImageView
         CGRect scaledImage = [self.iv_photo frameForImage:image inImageViewAspectFit:self.iv_photo];
         
         // create insets to cap the photo frame according to the size of the scaled image
         UIEdgeInsets photoFrameInsets = UIEdgeInsetsMake(scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS);
         
         // apply the cap insets to the photo frame image
         UIImage* img_photoFrame = [UIImage imageNamed:@"picture_frame.png"];
         if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
         self.iv_photoFrame.image = [img_photoFrame resizableImageWithCapInsets:photoFrameInsets];
         } else {
         self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:photoFrameInsets.left topCapHeight:photoFrameInsets.top];
         }
         
         // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
         //self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.origin.y, (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), self.iv_photoFrame.frame.size.height);
         self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
         }
         }
         else {
         self.iv_photo.contentMode = UIViewContentModeCenter;
         self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
         }*/
        [self.view setNeedsDisplay];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self hideControlsAfterDelay:5];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    
}


#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"PageViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([draftID isEqualToNumber:self.pageID] &&
            [photoID isEqualToNumber:self.topVotedPhotoID]) {
            
            //we only draw the image if this view hasnt been repurposed for another page
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            
            [self displayPhotoFrameOnImage:response.image];
            //self.iv_photoFrame.frame = CGRectMake(0, self.iv_photoFrame.frame.origin.y, response.image.size.width + 58, self.iv_photoFrame.frame.size.height);
            [self.view setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
}


#pragma mark - Static Initializers
+ (PageViewController*) createInstanceWithPageID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber {
    PageViewController* instance = [[PageViewController alloc]initWithNibName:@"PageViewController" bundle:nil];
    instance.pageID = pageID;
    instance.pageNumber = pageNumber;
    [instance autorelease];
    return instance;
}

@end
