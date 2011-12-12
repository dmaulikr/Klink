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

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"

@implementation PageViewController
@synthesize iv_openBookPageImage = m_iv_openBookPageImage;
@synthesize pageID = m_pageID;
@synthesize topVotedPhotoID = m_topVotedPhotoID;
@synthesize pageNumber = m_pageNumber;
@synthesize lbl_title = m_lbl_title;
@synthesize iv_photo = m_iv_photo;
@synthesize lbl_caption = m_lbl_caption;
@synthesize lbl_photoby = m_lbl_photoby;
@synthesize lbl_captionby = m_lbl_captionby;
@synthesize lbl_publishDate = m_lbl_publishDate;
@synthesize lbl_pageNumber = m_lbl_pageNumber;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;


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
	
	// Navigation and tool bars
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [self.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
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
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (page != nil) {
        Photo* photo = [page photoWithHighestVotes];
        self.topVotedPhotoID = photo.objectid;
        
        Caption* caption = [page captionWithHighestVotes];
        
        self.lbl_caption.text = caption.caption1;
        self.lbl_title.text = page.displayname;
        self.lbl_captionby.text = [NSString stringWithFormat:@"- written by %@", photo.creatorname];
        self.lbl_photoby.text = [NSString stringWithFormat:@"- illustrated by %@", photo.creatorname];
        self.lbl_pageNumber.text = [NSString stringWithFormat:@"- %@ -", [self.pageNumber stringValue]];
        
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:page.objectid forKey:kPAGEID];
        
        //add the photo id to the context
        [userInfo setValue:photo.objectid forKey:kPHOTOID];
        
        if (photo.thumbnailurl != nil && 
            ![photo.thumbnailurl isEqualToString:@""]) 
        {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            
            if (image != nil) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_photo.image = image;
            }
        }
        else {
            self.iv_photo.contentMode = UIViewContentModeCenter;
            self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
        }
        [self.view setNeedsDisplay];
        
    }
    
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
