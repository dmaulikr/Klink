//
//  BookPageViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookPageViewController.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "DateTimeHelper.h"
#import "UIImageView+UIImageViewCategory.h"
#import "ProfileViewController.h"
#import "UIResourceLinkButton.h"
#import "FullScreenPhotoViewController.h"
#import "BookViewControllerLeaves.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"
#define kPHOTOFRAMETHICKNESS 30

@implementation BookPageViewController
@synthesize pageID              = m_pageID;
@synthesize topVotedPhotoID     = m_topVotedPhotoID;
@synthesize topVotedCaptionID   = m_topVotedCaptionID;
@synthesize pageNumber          = m_pageNumber;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;
@synthesize iv_openBookPageImage = m_iv_openBookPageImage;
@synthesize lbl_title           = m_lbl_title;
@synthesize iv_photo            = m_iv_photo;
@synthesize iv_photoFrame       = m_iv_photoFrame;
@synthesize lbl_caption         = m_lbl_caption;
@synthesize lbl_photoby         = m_lbl_photoby;
@synthesize lbl_captionby       = m_lbl_captionby;
@synthesize lbl_publishDate     = m_lbl_publishDate;
@synthesize lbl_pageNumber      = m_lbl_pageNumber;

@synthesize btn_writtenBy       = m_btn_writtenBy;
@synthesize btn_illustratedBy   = m_btn_illustratedBy;
@synthesize btn_homeButton      = m_btn_homeButton;
@synthesize btn_facebookButton = m_btn_facebookButton;
@synthesize btn_twitterButton = m_btn_twitterButton;

#pragma mark - Property Definitions
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<BookPageViewControllerDelegate>)del
{
    m_delegate = del;
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
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)setControlsHidden:(BOOL)hidden {
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	
    [self.btn_homeButton setAlpha:hidden ? 0 : 1];
    [self.btn_facebookButton setAlpha:hidden ? 0 : 1];
    [self.btn_twitterButton setAlpha:hidden ? 0 : 1];
    
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


#pragma mark - Photo Frame Helper
- (void) displayPhotoFrameOnImage:(UIImage*)image {
    // get the frame for the new scaled image in the Photo ImageView
    CGRect scaledImage = [self.iv_photo frameForImage:image inImageViewAspectFit:self.iv_photo];
    
    //CGFloat scaleFactor = scaledImage.size.width/self.iv_photo.frame.size.width;
    
    // create insets to cap the photo frame according to the size of the scaled image
    UIEdgeInsets photoFrameInsets = UIEdgeInsetsMake(scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.height/2 + kPHOTOFRAMETHICKNESS, scaledImage.size.width/2 + kPHOTOFRAMETHICKNESS);
    
    // apply the cap insets to the photo frame image
    UIImage* img_photoFrame = [UIImage imageNamed:@"picture_frame.png"];
    if ([UIImage instancesRespondToSelector:@selector(resizableImageWithCapInsets:)]) {
        // iOS5+ method for scaling the photo frame
        
        self.iv_photoFrame.image = [img_photoFrame resizableImageWithCapInsets:photoFrameInsets];
        
        // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
        self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 2), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 2));
    }
    else {
        // pre-iOS5 method for scaling the photo frame
        self.iv_photoFrame.image = [img_photoFrame stretchableImageWithLeftCapWidth:(int)photoFrameInsets.left topCapHeight:(int)photoFrameInsets.top];
        
        // resize the photo frame to wrap the scaled image while maintining the cap insets, this preserves the border thickness and shadows of the photo frame
        if (scaledImage.size.height > scaledImage.size.width) {
            self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS/2), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 4), (scaledImage.size.width + kPHOTOFRAMETHICKNESS), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 7));
        }
        else {
            self.iv_photoFrame.frame = CGRectMake((self.iv_photo.frame.origin.x + scaledImage.origin.x - kPHOTOFRAMETHICKNESS + 4), (self.iv_photo.frame.origin.y + scaledImage.origin.y - kPHOTOFRAMETHICKNESS + 4), (scaledImage.size.width + 2*kPHOTOFRAMETHICKNESS - 7), (scaledImage.size.height + 2*kPHOTOFRAMETHICKNESS - 6));
        }
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (page != nil) {
        Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:page.finishedphotoid];
        self.topVotedPhotoID = photo.objectid;
        
        Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:page.finishedcaptionid];
        self.topVotedCaptionID = caption.objectid;
        
        NSDate* datePublished = [DateTimeHelper parseWebServiceDateDouble:photo.datecreated];
        
        // page title
        self.lbl_title.text = page.displayname;
        
        // page caption
        if (caption != nil) {
            self.lbl_caption.text = [NSString stringWithFormat:@"\"%@\"", caption.caption1];
            self.lbl_captionby.text = [NSString stringWithFormat:@"- written by "];
            [self.btn_writtenBy renderWithObjectID:caption.creatorid withName:caption.creatorname];
        }
        else {
            [self.lbl_caption setHidden:YES];
            [self.lbl_captionby setHidden:YES];
            [self.btn_writtenBy setHidden:YES];
        }
        
        // photo
        self.lbl_photoby.text = [NSString stringWithFormat:@"- illustrated by "];
        [self.btn_illustratedBy renderWithObjectID:photo.creatorid withName:photo.creatorname];
        
        self.lbl_publishDate.text = [NSString stringWithFormat:@"published: %@", [DateTimeHelper formatMediumDate:datePublished]];
        self.lbl_pageNumber.text = [NSString stringWithFormat:@"- %@ -", [self.pageNumber stringValue]];
        
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:page.objectid forKey:kPAGEID];
        
        //add the photo id to the context
        [userInfo setValue:photo.objectid forKey:kPHOTOID];
        
        if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            callback.fireOnMainThread = YES;
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            
            if (image != nil) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_photo.image = image;
                
                [self displayPhotoFrameOnImage:image];
            }
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
        }
        
        [self.view setNeedsDisplay];
    }
    
    // Create gesture recognizer for the photo image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_openBookPageImage addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the photo
    [self.iv_openBookPageImage setUserInteractionEnabled:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.btn_illustratedBy = nil;
    self.btn_writtenBy = nil;
    self.lbl_title = nil;
    self.lbl_publishDate = nil;
    self.lbl_photoby = nil;
    self.lbl_caption = nil;
    self.lbl_captionby = nil;
    self.lbl_pageNumber = nil;
    self.iv_openBookPageImage = nil;
    self.iv_photo = nil;
    self.iv_photoFrame = nil;
    self.btn_homeButton = nil;
    self.btn_facebookButton = nil;
    self.btn_twitterButton = nil;
    
    if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		self.controlVisibilityTimer = nil;
	}
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    //Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // Unhide the buttons
    [self.btn_homeButton setHidden:NO];
    [self.btn_facebookButton setHidden:NO];
    [self.btn_twitterButton setHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self hideControlsAfterDelay:2.5];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    
}

#pragma mark - Button Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    [self.delegate onHomeButtonPressed:sender];
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    [self.delegate onFacebookButtonPressed:sender];
}

- (IBAction) onTwitterButtonPressed:(id)sender {
    [self.delegate onTwitterButtonPressed:sender];
}

#pragma mark Username button handler
- (IBAction) onLinkButtonClicked:(id)sender {
    [self.delegate onLinkButtonClicked:sender];
}

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"BookPageViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([draftID isEqualToNumber:self.pageID] &&
            [photoID isEqualToNumber:self.topVotedPhotoID]) {
            
            //we only draw the image if this view hasnt been repurposed for another page
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            
            [self displayPhotoFrameOnImage:response.image];
            [self.view setNeedsDisplay];
            
            // Raise event to notify BookViewControllerLeaves that a photo has been downloaded
            EventManager* eventManager = [EventManager instance];
            [eventManager raisePageViewPhotoDownloadedEvent:userInfo];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

    // Raise event to notify BookViewControllerLeaves that a photo has been downloaded
    EventManager* eventManager = [EventManager instance];
    [eventManager raisePageViewPhotoDownloadedEvent:userInfo];
    
}


#pragma mark - Static Initializers
+ (BookPageViewController*) createInstanceWithPageID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber {
    BookPageViewController* instance = [[BookPageViewController alloc]initWithNibName:@"BookPageViewController" bundle:nil];
    instance.pageID = pageID;
    instance.pageNumber = pageNumber;
    [instance autorelease];
    return instance;
}

@end
