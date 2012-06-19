//
//  ContributeViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ContributeViewController.h"
#import "Macros.h"
#import "UICameraActionSheet.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "Types.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "ProductionLogViewController.h"
#import "DraftViewController.h"
#import "FullScreenPhotoViewController.h"
#import "DateTimeHelper.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "PlatformAppDelegate.h"
#import "UIProgressHUDView.h"
#import "UIImageView+UIImageViewCategory.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "RequestSummaryViewController.h"
#import "UITutorialView.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"
#define kPHOTOFRAMETHICKNESS    30


@implementation ContributeViewController
@synthesize delegate = m_delegate;
@synthesize objectIDsBeingCreated = m_objectIDsBeingCreated;
@synthesize objectTypesBeingCreated = m_objectTypesBeingCreated;
@synthesize cameraActionSheet     = m_cameraActionSheet;
@synthesize scrollView = m_scrollview;
@synthesize activeTextView = m_activeTextView;
@synthesize activeTextField = m_activeTextField;
@synthesize oidArrayLock = m_oidArrayLock;
@synthesize configurationType = m_configurationType;
@synthesize pageID = m_pageID;
@synthesize photoID = m_photoID;
@synthesize secondsToWaitBeforeExecutingValidationEnumeration = m_secondsToWaitBeforeExecutingValidationEnumeration;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize draftTitle = m_draftTitle;
@synthesize tf_newDraftTitle = m_tf_newDraftTitle;
@synthesize lbl_titleRequired = m_lbl_titleRequired;

@synthesize btn_cameraButton = m_btn_cameraButton;
@synthesize iv_photo = m_iv_photo;
@synthesize iv_photoFrame = m_iv_photoFrame;
@synthesize img_photo = m_img_photo;
@synthesize img_thumbnail = m_img_thumbnail;
@synthesize lbl_photoOptional = m_lbl_photoOptional;
@synthesize lbl_photoRequired = m_lbl_photoRequired;

@synthesize tv_caption = m_tv_caption;
@synthesize caption = m_caption;
@synthesize lbl_captionOptional = m_lbl_captionOptional;
@synthesize lbl_captionRequired = m_lbl_captionRequired;

@synthesize lbl_deadline = m_lbl_deadline;
@synthesize deadline = m_deadline;

@synthesize requests = m_requests;
@synthesize idEnumerator = m_idEnumerator;
@synthesize nPageObjectID     = m_newPageObjectID;
@synthesize nPhotoObjectID    = m_newPhotoObjectID;
@synthesize nCaptionObjectID  = m_newCaptionObjectID;
@synthesize isDone                      = m_isDone;

#pragma mark - Deadline Date Timers
- (void) updateDeadlineDate:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    NSTimeInterval draftExpirySetting = [settings.page_draftexpiry_seconds doubleValue];
    NSDate* deadlineDate = [now dateByAddingTimeInterval:draftExpirySetting];
    self.lbl_deadline.text = [NSString stringWithFormat:@"draft deadline: %@", [DateTimeHelper formatMediumDateWithTime:deadlineDate includeSeconds:NO]];
}

- (void) timeRemaining:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    NSTimeInterval remaining = [self.deadline timeIntervalSinceDate:now];
    self.lbl_deadline.text = [NSString stringWithFormat:@"draft deadline: %@", [DateTimeHelper formatTimeInterval:remaining]];
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

#pragma mark - Initializers
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.requests = nil;
        self.objectIDsBeingCreated = nil;
        self.objectTypesBeingCreated = nil;
        
        NSLock* lock = [[NSLock alloc]init];
        self.oidArrayLock = lock;
                self.isDone = NO;
        [lock release];
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    
    [self.tv_caption removeObserver:self forKeyPath:@"contentSize"];
    
    self.scrollView = nil;
    self.activeTextView=nil;
    self.activeTextField=nil;
        
    self.configurationType=nil;
        
    self.lbl_draftTitle =nil;
    self.draftTitle =nil;
    self.tf_newDraftTitle=nil;
    self.lbl_titleRequired=nil;
        
    self.btn_cameraButton =nil;
    self.iv_photo=nil;
    self.img_photo=nil;
    self.lbl_photoOptional=nil;
    self.lbl_photoRequired=nil;
        
    self.tv_caption =nil;
    self.lbl_captionOptional=nil;
    self.lbl_captionRequired=nil;
    
    self.requests = nil;
       
    self.lbl_deadline = nil;
    [super dealloc];
    

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) setNavigationBarTitle:(NSString*)title {
    // Set Navigation bar title style with typewtirer font
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    titleLabel.text = title;
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

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self registerForKeyboardNotifications];
    
    // Keeps the text of the caption textview aligned to the vertical center of the textview frame
    [self.tv_caption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rb = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(onSubmitButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rb;
    [rb release];
    
    UIBarButtonItem* lb = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem  = lb;
    [lb release];
    
    // disable Submit button until user has completed all required fields
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    
    self.nCaptionObjectID = nil;
    self.nPhotoObjectID = nil;
    self.nPageObjectID = nil;
    
    
//    ResourceContext* resourceContext = [ResourceContext instance];
//    
//    // Set up the view for the appropriate configuration type
//    if (self.configurationType == PAGE) {
//        // New Draft
//        //self.navigationItem.title = @"New Draft";
//        [self setNavigationBarTitle:@"New Draft"];
//        self.lbl_draftTitle.hidden = YES;
//        self.tf_newDraftTitle.hidden = NO;
//        self.tf_newDraftTitle.enabled = YES;
//        self.lbl_titleRequired.hidden = NO;
//        
//        // Photo is optional because user is creating a new draft
//        self.btn_cameraButton.hidden = NO;
//        self.btn_cameraButton.enabled = YES;
//        self.lbl_photoOptional.hidden = NO;
//        self.lbl_photoRequired.hidden = YES;
//        
//        // Caption is optional because user is creating a new draft
//        self.lbl_captionOptional.hidden = NO;
//        self.lbl_captionRequired.hidden = YES;
//        
//        self.tf_newDraftTitle.text = self.draftTitle;
//    }
//    else if (self.configurationType == PHOTO) {
//        // New Photo
//        //self.navigationItem.title = @"New Photo";
//        [self setNavigationBarTitle:@"New Photo"];
//        self.btn_cameraButton.hidden = NO;
//        self.btn_cameraButton.enabled = YES;
//        self.lbl_photoOptional.hidden = YES;
//        self.lbl_photoRequired.hidden = NO;
//        
//        // Show existing draft title since user is adding a photo
//        Page* currentPage = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
//        self.draftTitle = currentPage.displayname;
//        self.lbl_draftTitle.text = self.draftTitle;
//        self.lbl_draftTitle.hidden = NO;
//        self.tf_newDraftTitle.hidden = YES;
//        self.tf_newDraftTitle.enabled = NO;
//        self.lbl_titleRequired.hidden = YES;
//        
//        // Caption is optional because user is adding a new photo
//        self.lbl_captionOptional.hidden = NO;
//        self.lbl_captionRequired.hidden = YES;
//        
//        if (!self.img_photo) {
//            // ContributeViewController was just lanuched from user pressing the camera button from the draft view, immidiately launch cameraActionSheet
//            [self onCameraButtonPressed:nil];
//        }
//    }
//    else if (self.configurationType == CAPTION) {
//        // New Caption
//        //self.navigationItem.title = @"New Caption";
//        [self setNavigationBarTitle:@"New Caption"];
//        self.lbl_captionOptional.hidden = YES;
//        self.lbl_captionRequired.hidden = NO;
//        
//        // Show existing draft title since user is adding a caption
//        Page* currentPage = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
//        self.draftTitle = currentPage.displayname;
//        self.lbl_draftTitle.text = self.draftTitle;
//        self.lbl_draftTitle.hidden = NO;
//        self.tf_newDraftTitle.hidden = YES;
//        self.tf_newDraftTitle.enabled = NO;
//        self.lbl_titleRequired.hidden = YES;
//        
//        // Show existing photo but disabled cameraButton since user is adding a caption
//        Photo* currentPhoto = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
//        
//        ImageManager* imageManager = [ImageManager instance];
//        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:currentPhoto.objectid forKey:kPHOTOID];
//        
//        if (currentPhoto.imageurl != nil && ![currentPhoto.imageurl isEqualToString:@""]) {
//            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
//            callback.fireOnMainThread = YES;
//            UIImage* image = [imageManager downloadImage:currentPhoto.imageurl withUserInfo:nil atCallback:callback];
//            [callback release];
//            if (image != nil) {
//                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
//                self.img_photo = image;
//                self.iv_photo.image = self.img_photo;
//                
//                [self displayPhotoFrameOnImage:image];
//            }
//        }
//        
//        //self.iv_photo.image = self.img_photo;
//        self.btn_cameraButton.hidden = YES;
//        self.btn_cameraButton.enabled = NO;
//        self.lbl_photoOptional.hidden = YES;
//        self.lbl_photoRequired.hidden = YES;
//        
//        [self.view setNeedsDisplay];
//        
//        // show keyboard ready for text entry
//        [self.tv_caption becomeFirstResponder];
//        
//    }
//    else {
//        // error state - Configuration type not specified
//        //LOG_CONTRIBUTEVIEWCONTROLLER(1,@"%@Could not determine configuration type",activityName);
//    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.scrollView = nil;
    self.activeTextView = nil;
    self.activeTextField = nil;
    
    self.lbl_draftTitle = nil;
    self.tf_newDraftTitle = nil;
    self.lbl_titleRequired = nil;
    
    self.btn_cameraButton = nil;
    self.iv_photo = nil;
    self.iv_photoFrame = nil;
    self.img_photo = nil;
    self.img_thumbnail = nil;
    self.lbl_photoOptional = nil;
    self.lbl_photoRequired = nil;
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [self.tv_caption removeObserver:self forKeyPath:@"contentSize"];
    self.tv_caption = nil;
    self.lbl_captionOptional = nil;
    self.lbl_captionRequired = nil;
    
    self.lbl_deadline = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // NSString* activityName = @"ContributeViewController.viewWillAppear:";
    
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
    
    // Set deadline date
    self.lbl_deadline.text = @"";
    
    // Set deadline
    if (self.configurationType == PAGE) {
        // Show a date 24 hours from now
        NSTimer* deadlineTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                                  target:self
                                                                selector:@selector(updateDeadlineDate:)
                                                                userInfo:nil
                                                                 repeats:YES];
        [self updateDeadlineDate:deadlineTimer];
    }
    else {
        // Existing draft, show time remaining
        ResourceContext* resourceContext = [ResourceContext instance];
        
        Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        NSTimer* deadlineTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                                  target:self
                                                                selector:@selector(timeRemaining:)
                                                                userInfo:nil
                                                                 repeats:YES];
        [self timeRemaining:deadlineTimer];
    }
    
    //we check to see if the user has been to this viewcontroller before
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDCONTRIBUTEVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Bahndr Drafts" message:ui_WELCOME_CONTRIBUTE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    // Set up the view for the appropriate configuration type
    if (self.configurationType == PAGE) {
        // New Draft
        //self.navigationItem.title = @"New Draft";
        [self setNavigationBarTitle:@"New Draft"];
        self.lbl_draftTitle.hidden = YES;
        self.tf_newDraftTitle.hidden = NO;
        self.tf_newDraftTitle.enabled = YES;
        self.lbl_titleRequired.hidden = NO;
        
        // Photo is optional because user is creating a new draft
        self.btn_cameraButton.hidden = NO;
        self.btn_cameraButton.enabled = YES;
        self.lbl_photoOptional.hidden = NO;
        self.lbl_photoRequired.hidden = YES;

        // Caption is optional because user is creating a new draft
        self.lbl_captionOptional.hidden = NO;
        self.lbl_captionRequired.hidden = YES;
        
        self.tf_newDraftTitle.text = self.draftTitle;
    }
    else if (self.configurationType == PHOTO) {
        // New Photo
        //self.navigationItem.title = @"New Photo";
        [self setNavigationBarTitle:@"New Photo"];
        self.btn_cameraButton.hidden = NO;
        self.btn_cameraButton.enabled = YES;
        self.lbl_photoOptional.hidden = YES;
        self.lbl_photoRequired.hidden = NO;
        
        // Show existing draft title since user is adding a photo
        Page* currentPage = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        self.draftTitle = currentPage.displayname;
        self.lbl_draftTitle.text = self.draftTitle;
        self.lbl_draftTitle.hidden = NO;
        self.tf_newDraftTitle.hidden = YES;
        self.tf_newDraftTitle.enabled = NO;
        self.lbl_titleRequired.hidden = YES;
        
        // Caption is optional because user is adding a new photo
        self.lbl_captionOptional.hidden = NO;
        self.lbl_captionRequired.hidden = YES;
        
        if (!self.img_photo) {
            // ContributeViewController was just lanuched from user pressing the camera button from the draft view, immidiately launch cameraActionSheet
            [self onCameraButtonPressed:nil];
        }
    }
    else if (self.configurationType == CAPTION) {
        // New Caption
        //self.navigationItem.title = @"New Caption";
        [self setNavigationBarTitle:@"New Caption"];
        self.lbl_captionOptional.hidden = YES;
        self.lbl_captionRequired.hidden = NO;
        
        // Show existing draft title since user is adding a caption
        Page* currentPage = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        self.draftTitle = currentPage.displayname;
        self.lbl_draftTitle.text = self.draftTitle;
        self.lbl_draftTitle.hidden = NO;
        self.tf_newDraftTitle.hidden = YES;
        self.tf_newDraftTitle.enabled = NO;
        self.lbl_titleRequired.hidden = YES;

        // Show existing photo but disabled cameraButton since user is adding a caption
        Photo* currentPhoto = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];

        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:currentPhoto.objectid forKey:kPHOTOID];
        
        if (currentPhoto.imageurl != nil && ![currentPhoto.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            callback.fireOnMainThread = YES;
            UIImage* image = [imageManager downloadImage:currentPhoto.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            if (image != nil) {
                self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                self.img_photo = image;
                self.iv_photo.image = self.img_photo;
                
                [self displayPhotoFrameOnImage:image];
            }
        }
        
        //self.iv_photo.image = self.img_photo;
        self.btn_cameraButton.hidden = YES;
        self.btn_cameraButton.enabled = NO;
        self.lbl_photoOptional.hidden = YES;
        self.lbl_photoRequired.hidden = YES;
        
        [self.view setNeedsDisplay];
        
        // show keyboard ready for text entry
        [self.tv_caption becomeFirstResponder];

    }
    else {
        // error state - Configuration type not specified
        //LOG_CONTRIBUTEVIEWCONTROLLER(1,@"%@Could not determine configuration type",activityName);
    }

}

- (void) viewDidAppear:(BOOL)animated 
{
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDCONTRIBUTEVC]==NO) {
        [userDefaults setBool:YES forKey:setting_HASVIEWEDCONTRIBUTEVC];
        [userDefaults synchronize];
    }
    
    //we check to see if the view controller has been marked 'done', which
    //means it is now only being shown as a result of the request summary civew controller dismissing
    if (self.isDone == YES) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // show toolbar
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Submit button helper
- (BOOL) okToSubmit {
    
    if (self.configurationType == PAGE && self.draftTitle) {    
        
        if (self.caption && !self.img_photo) {
            // user is creating a new draft and has added a caption but photo is empty
            return NO;
        }
        else {
            return YES;
        }
    }
    else if (self.configurationType == PHOTO && self.img_photo) {
        return YES;
    }
    else if (self.configurationType == CAPTION && self.caption) {
        return YES;
    }
    else {
        return NO;
    }
    
}

#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // caption textview editing has begun
    
    // disable Submit until text entry complete
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.activeTextView = textView;
    
    // Prevent interaction with the cameraButton on the photo
    self.btn_cameraButton.hidden = YES;
    self.btn_cameraButton.enabled = NO;
    
    // Clear the default text of the caption textview upon startin to edit
    if ([self.activeTextView.text isEqualToString:@"caption"]) {
        [self.activeTextView setText:@""];
        self.activeTextView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // caption textview editing has ended
    
    // Add default text back if caption was left empty
    if ([self.activeTextView.text isEqualToString:@""] || [self.activeTextView.text isEqualToString:@"caption"]) {
        self.caption = nil;
        self.activeTextView.textColor = [UIColor lightGrayColor];
        [self.activeTextView setText:@"caption"];
        
        // if user is creating a new draft and has left the caption textview blank then a photo is no required
        if (self.configurationType == PAGE) {
            self.lbl_photoOptional.hidden = NO;
            self.lbl_photoRequired.hidden = YES;
        }
    }
    else {
        // caption is acceptable
        
        NSString *trimmedCaption = [self.activeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        self.caption = trimmedCaption;
        
        // if user is creating a new draft and has added a caption then a photo is now also required
        if (self.configurationType == PAGE && !self.img_photo) {
            self.lbl_photoOptional.hidden = YES;
            self.lbl_photoRequired.hidden = NO;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Photo Required"
                                  message:@"Oops! Did we forget to mention that a caption must be attached to a photo. Please add a photo to your new draft, or, delete the caption before submitting."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    
    // Re-enable interaction with the cameraButton on the photo if not in CAPTION configuration
    if (self.configurationType != CAPTION) {
        self.btn_cameraButton.hidden = NO;
        self.btn_cameraButton.enabled = YES;
    }
    
    // enable Submit button if ok
    self.navigationItem.rightBarButtonItem.enabled = [self okToSubmit];
    
    self.activeTextView = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // draft title textfield editing has begun
    
    self.activeTextField = textField;
    
    if ([self.activeTextField.text rangeOfString:@"#"].location == NSNotFound) {
        // add hashtag if not present
        self.activeTextField.text = [NSString stringWithFormat:@"#%@", self.activeTextField.text];
    }
    
    // Prevent interaction with the cameraButton on the photo
    self.btn_cameraButton.hidden = YES;
    self.btn_cameraButton.enabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // draft title textfield editing has ended
    
    // Re-enable interaction with the cameraButton on the photo if not in CAPTION configuration
    if (self.configurationType != CAPTION) {
        self.btn_cameraButton.hidden = NO;
        self.btn_cameraButton.enabled = YES;
    }
    
    if ([self.activeTextField.text isEqualToString:@""] || [self.activeTextField.text isEqualToString:@"#"] || [self.activeTextField.text isEqualToString:@"#title"]) {
        // Add default text back if title was left empty
        self.draftTitle = nil;
        [self.activeTextField setText:@""];
        [self.activeTextField setPlaceholder:@"#title"];
    }
    else {
        // title is acceptable
        if ([self.activeTextField.text rangeOfString:@"#"].location == NSNotFound) {
            // add hashtag if not present
            self.draftTitle = [NSString stringWithFormat:@"#%@", self.activeTextField.text];
        }
        else {
            self.draftTitle = self.activeTextField.text;
        }
        self.activeTextField.text = self.draftTitle;
    }
    
    // enable Submit button if ok
    self.navigationItem.rightBarButtonItem.enabled = [self okToSubmit];
    
    self.activeTextField = nil;
}

// Used to prevent spaces and more than one hashtag in the draft title string
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    
    if([text isEqualToString:@" "]) {
        // no spaces allowed
        return NO;
    }
    else if ([text isEqualToString:@"#"]) {
        // no hashtags other than at the front allowed
        return NO;
    }
    
    return YES;
}

// Handles keyboard Return button pressed while editing the caption textview to dismiss the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        /*if (self.configurationType == CAPTION) {
            
            if ([self.activeTextView.text isEqualToString:@""] || [self.activeTextView.text isEqualToString:@"caption"]) {
                // enable Submit button if ok
                self.navigationItem.rightBarButtonItem.enabled = [self okToSubmit];
                [self textViewDidEndEditing:textView];
            }
            else {
                // caption is acceptable
                
                NSString *trimmedCaption = [self.activeTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                self.caption = trimmedCaption;
                
                [self onSubmitButtonPressed:textView];
            }
        }*/
        return NO;
    }
    
    return YES;
}

// Handles keyboard Return button pressed while editing the draft title textfield to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

// Keeps the text of the caption textview aligned to the vertical center of the textview frame
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView* textview = object;
    //Center vertical alignment
    CGFloat topCorrect = ([textview bounds].size.height - [textview contentSize].height * [textview zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    textview.contentInset = UIEdgeInsetsMake(topCorrect, 0, 0, 0);
}

#pragma mark - Keyboard Handlers
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextView.frame.origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextView.frame.origin.y+(self.activeTextView.frame.size.height*1.25)-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView beginAnimations:@"keyboardWillBeHiddenAnimation" context:nil];
    [UIView setAnimationDuration:0.35];
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

// Hides Keyboard when user touches screen outside of editable text view or field
- (IBAction)backgroundClick:(id)sender
{
    [self.activeTextView resignFirstResponder];
    [self.activeTextField resignFirstResponder];
}

#pragma mark - Button Handlers
- (IBAction)onInfoButtonPressed:(id)sender {
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewContribute"];
    [self.view addSubview:infoView];
    [infoView release];
}

#pragma mark Photo "Camera" button handler
- (IBAction)onCameraButtonPressed:(id)sender {    
    self.cameraActionSheet = [UICameraActionSheet createCameraActionSheet];
    self.cameraActionSheet.a_delegate = self;
    [self.cameraActionSheet showInView:self.view];
}


#pragma mark - UICameraActionSheetDelegate members
- (void) displayPicker:(UIImagePickerController*) picker {
    [self presentModalViewController:picker animated:YES];
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image {
    //we handle back end processing of the image from the camera sheet here
    self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
    self.img_photo = image;
    self.img_thumbnail = thumbnailImage;
    //self.iv_photo.image = image;
    [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    [self displayPhotoFrameOnImage:image];
    
    // enable Submit button if ok
    self.navigationItem.rightBarButtonItem.enabled = [self okToSubmit];
    
    [self.view setNeedsDisplay];
}

- (void) onCancel {
    // we deal with cancel operations from the action sheet here
    [self onCancelButtonPressed:nil];
}

- (NSString*)successMessage
{
    NSString* retVal = nil;
    
    if (self.configurationType == PAGE) 
    {
        retVal = [NSString stringWithFormat:@"Created draft \"%@\"!",self.draftTitle];
    }
    else if (self.configurationType == PHOTO)
    {
        retVal = [NSString stringWithFormat:@"Added photo to  \"%@\"",self.draftTitle];
    }
    else {
        retVal = [NSString stringWithFormat:@"Added caption to \"%@\"",self.draftTitle];
    }
    return retVal;
}

- (NSString*)failureMessage
{
    NSString* retVal = nil;
    
    if (self.configurationType == PAGE) 
    {
        retVal = [NSString stringWithFormat:@"Oops, please submit again"];
    }
    else if (self.configurationType == PHOTO) 
    {
        retVal = [NSString stringWithFormat:@"Oops, please submit again"];
    }
    else 
    {
        retVal = [NSString stringWithFormat:@"Oops, please submit again"];
    }
    return retVal;
}


- (NSArray*) progressMessages
{
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    NSString* firstMessage = nil;
    //we add a bunch of canned in progress messages here
    if (self.configurationType == PAGE) {
        firstMessage = [NSString stringWithFormat:@"Creating \"%@\"...",self.draftTitle];
    }
    else if (self.configurationType == PHOTO) {
        firstMessage = [NSString stringWithFormat:@"Adding your photo..."];
    }
    else {
        firstMessage = [NSString stringWithFormat:@"Enscribing your caption..."];
    }
    [retVal addObject:firstMessage];
    [retVal addObject:@"Creating shipping label..."];
    [retVal addObject:@"Balancing hormone levels..."];
    [retVal addObject:@"Checking local traffic conditions..."];
    [retVal addObject:@"Phoning home..."];
    [retVal addObject:@"Unlocking communication syngeries..."];
    [retVal addObject:@"Well this is awkward..."];
    [retVal addObject:@"It usually is much faster..."];
    [retVal addObject:@"Lucky, we might have a problem..."];

    return retVal;
}

#pragma mark - Navigation Bar button handler
- (void) processSubmitButtonPressed
{
    NSString* activityName = @"ContributeViewController.processSubmitButtonPressed:";
    
    //we call the delegate to instruct it that it should begin committing the changes indicated by this view
    self.requests = nil;
    
    //we save this list of requests
    self.requests = [self.delegate submitChangesForController:self];
    
    //at this point we populate our internal list of objectIDs to created
    //based off the requests that were generated by the delegate
    
    NSMutableArray* oids = [[NSMutableArray alloc]init];
    NSMutableArray* otypes = [[NSMutableArray alloc]init];   
    //grab the lock
    [self.oidArrayLock lock];
    for (Request* request in self.requests) 
    {
        if ([request.operationcode intValue] == kCREATE) 
        {
            //we are only tacking overdue objectIDs on the server
            [oids addObject:request.targetresourceid];
            [otypes addObject:request.targetresourcetype];
        }
    }
    
    //at this point we now have the objectIDs of all objects that are going
    //to be created on the cloud
    self.objectIDsBeingCreated = oids;
    self.objectTypesBeingCreated = otypes;
    [oids release];
    [otypes release];
    
    //release the lock
    [self.oidArrayLock unlock];
    LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Committed changes to local store, tracking %d cloud synchronization Requests",activityName,[self.requests count]);
}

- (void)onSubmitButtonPressed:(id)sender {
    //NSString* activityName = @"ContributeViewController.onSubmitButtonPressed:";
    
    //Disable the Submit button
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    //after this point, the platforms should automatically begin syncing the data back to the cloud
    //we now show a progress bar to monitor this background activity
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = delegate.progressView;
    progressView.delegate = self;
 
    
    NSNumber* maxTimeToShowOnProgress = settings.progress_maxsecondstodisplay;
    
    //we then calculate how long until we assume the request failed and perform a recovering enumeration
    self.secondsToWaitBeforeExecutingValidationEnumeration = [NSNumber numberWithInt:15];
    NSNumber* heartbeat = [NSNumber numberWithInt:5];
    self.idEnumerator = nil;
    
    //we need to construc the appropriate success, failure and progress messages for the submission
    NSString* failureMessage = [self failureMessage];
    NSString* successMessage = [self successMessage];
    NSArray* progressMessage = [self progressMessages];
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:maxTimeToShowOnProgress withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    

    //create timer for the execution of the commit tasks
    [self performSelector:@selector(processSubmitButtonPressed) withObject:nil afterDelay:0.5];
}


- (void)onCancelButtonPressed:(id)sender {    
    //[self.delegate onCancelButtonPressed:sender];
    
    if (self.configurationType == PHOTO && !self.img_photo) {
        // User just pressed 'Cancel' button on cameraActionSheet right after they first pressed the camera button from the draft view
        [self dismissModalViewControllerAnimated:YES];
    }
    else if (sender == self.navigationItem.leftBarButtonItem) {
        // User pressed navigation bar 'Cancel' button 
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        // Do nothing, user just pressed 'Cancel' button on cameraActionSheet after having already taken a photo
    }
}

- (BOOL) haveAllObjectIDsBeenCreatedOnCloud 
{
    BOOL retVal = YES;
    
    //we grab the oid lock
    [self.oidArrayLock lock];
    
    for (NSNumber* objectid in self.objectIDsBeingCreated) 
    {
        //we then need to scan the cloud enumerators request list to 
        //see if the object is in present in its returned variables
        bool isObjectInEnumerator = [self.idEnumerator hasReturnedObjectWithID:objectid];
        
        if (!isObjectInEnumerator) 
        {
            //it is not in the enumerator
            retVal = NO;
            break;
        }
    }
    
    //we need to release lock
    [self.oidArrayLock unlock];
    return retVal;
}

#pragma mark - UIProgressHUDViewDelegate
- (BOOL) progressViewShouldFinishOnSuccess:(UIProgressHUDView *)progressView 
{
    //we need to calculate the progress of the overall series of requests
    //if its equal to 1, then we return YES

    return YES;
}

- (void) markCreatedObjectRequestsCompleteInProgressView:(UIProgressHUDView*)progressView 
{
    for (int i = 0; i < [self.objectIDsBeingCreated count]; i++) 
    {
        //we go through each object id and type
        NSNumber* oid = [self.objectIDsBeingCreated objectAtIndex:i];
        NSString* otype = [self.objectTypesBeingCreated objectAtIndex:i];
        
        //now we iterate through the requests looking for the matching partner
        for (Request* request in progressView.requests) {
            if ([request.operationcode intValue] == kCREATE)
            {
                if ([request.targetresourceid isEqualToNumber:oid] &&
                    [request.targetresourcetype isEqualToString:otype])
                {
                    //we found it, merk it successful
                    [request updateRequestStatus:kCOMPLETED];
                }
                
            }
        }
    }

}

- (BOOL) progressViewShouldFinishOnFailure:(UIProgressHUDView *)progressView 
                            didFailOnTimer:(NSTimer *)timer 
{
//    NSString* activityName = @"ContributeViewController.progressViewShouldFinishOnFailure:";
    
//    //we check the enumerator validator to see if it brought it down
//    LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Timer expired event received from progress view",activityName);
//    if ([self haveAllObjectIDsBeenCreatedOnCloud])
//    {
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Detected that all objects pending creation have been created, marking all requests associated with it as being completed",activityName);
//        //we know that all the objects are on the cloud because of our validation call
//        //so we then go through the progress views request field and make them all success
//        [self markCreatedObjectRequestsCompleteInProgressView:progressView];
//        //by this point we have set all The Requests to be completed
//        
//    }
//    else 
//    {
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Objects that are outstanding for creation have not been enumerated, no processing to be done",activityName);
//    }
    
    //we always return yes, as the progress view will figure out if it were sucessful or not
    return YES;
    
}


- (BOOL) progressViewShouldFinishOnFailure:(UIProgressHUDView *)progressView didFailOnRequest:(Request *)request
{
 //   NSString* activityName = @"ContributeViewController.progressViewShouldFinishOnFailureOfRequest:";
    
    //we need to calculate if we want to wait longer
    
    //in the case a request fails, we need to do a similar check as above
//    LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Received message that Request %@ has failed",activityName,request.objectid);
//    
//    if ([self haveAllObjectIDsBeenCreatedOnCloud]) 
//    {
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Detected that all objects pending creation have been creted, marking all requests associated with them completed",activityName);
//         [self markCreatedObjectRequestsCompleteInProgressView:progressView];
//    }
//    
//    if ([self.idEnumerator isLoading])
//    {
//        //there is an outstanding enumeration, so we must wait
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@There is an outstanding validation enumeration, instructing progress view to wait and not close yet",activityName);
//        return NO;
//    }
//    else {
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@There is no outstanding validation enumeration, instructing progress view to close",activityName);
//    }
    
        
    return YES;
}




- (void) enumerateMissingObjectsIDsFromCloud 
{
    NSString* activityName = @"ContributeViewController.enumerateMissingObjectsIDsFromCloud:";
    
    //this method executes the idenumerator to retrieve any missing object ids
    //from the cloud that have not yet been returned
    
    NSMutableArray* objectIDsToEnumerate = [[NSMutableArray alloc]init];
    NSMutableArray* objectTypesToEnumerate = [[NSMutableArray alloc]init];
    
    //now we cycle through each of the ones we are expecting and detect which ones
    //need to be created
    [self.oidArrayLock lock];
    for (int i = 0; i < [self.objectIDsBeingCreated count]; i++) 
    {
        NSNumber* objectid = [self.objectIDsBeingCreated objectAtIndex:i];
        NSString* objectType = [self.objectTypesBeingCreated objectAtIndex:i];
        
        //now we check its existence in the enumerator
        if (![self.idEnumerator hasReturnedObjectWithID:objectid]) 
        {
            //no it hasnt, let us add it to our list
            [objectIDsToEnumerate addObject:objectid];
            [objectTypesToEnumerate addObject:objectType];
        }    
    }
    [self.oidArrayLock unlock];
    
    if ([objectIDsToEnumerate count] > 0) 
    {
        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@ Executing validation enumerator for %d missing object ids",activityName,[objectIDsToEnumerate count]);
        //let us reset the enumerator and execute it
        self.idEnumerator = nil;
        self.idEnumerator = [CloudEnumerator enumeratorForIDs:objectIDsToEnumerate withTypes:objectTypesToEnumerate];
        self.idEnumerator.delegate = self;
        [self.idEnumerator enumerateUntilEnd:nil];
    }
    
    
    //clean up
    [objectIDsToEnumerate release];
    [objectTypesToEnumerate release];
}

- (void) progressViewHeartbeat:(UIProgressHUDView *)progressView 
          timeElapsedInSeconds:(NSNumber *)elapsedTimeInSeconds
{
    //heart beat processing
    //NSString* activityName = @"ContributeViewController.progressViewHeartbeat:";
    
//    LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Received heart beat from progressView at %d seconds",activityName,[elapsedTimeInSeconds floatValue]);
//    //we need a threshold value to test against
//    float thresholdToBeginValidationEnumeration = [self.secondsToWaitBeforeExecutingValidationEnumeration floatValue];
//    
//    
//    //now we need to test if we have passed the validation threshold
//    if ([elapsedTimeInSeconds floatValue] > thresholdToBeginValidationEnumeration) 
//    {
//       //we hae crossed the threshold, but it doesnt mean we should execute the validatoin query
//        if (self.idEnumerator == nil ||
//                (self.idEnumerator != nil && [self.idEnumerator canEnumerate]))
//        {
//            //at this point we know we can execute the enumeration, but the broader question remains wehther we should execute said enumeration
//            if (![self haveAllObjectIDsBeenCreatedOnCloud])
//            {
//                //they have not all been created, so now we launch the enumeration
//                LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Validation enumeration threshold reached, and not all objects have been detected as being created, executing validation enumerator",activityName);
//                [self enumerateMissingObjectsIDsFromCloud];
//            }
//        }
//                                            
//    }
//    else {
//        LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@ Conditions not met for executing a validation enumeration check, skipping process of event.",activityName);
//    }
    
    //on heartbeat we need to make the call if we should verify whether the 
    //objects made it ot the cloud independently
    
    //if the enumerator can accept another request
        //then we look for all of the creates we are making
    
   // LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Received heart beat",activityName);
}

- (void) hudWasHidden {
    
    //called when the progress view is hidden

    [self hideProgressBar];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"ContributeViewController.hudWasHidden";
    [self hideProgressBar];
    
    //we dismiss this controller if the operation succeeded
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    if (progressView.didSucceed) 
    {
        self.nCaptionObjectID     = nil;
        self.nPhotoObjectID       = nil;
        self.nPageObjectID        = nil;
        self.isDone               = YES;
        //instead of closing, we want to launch the RequestSummaryViewController
        RequestSummaryViewController* rvc = [RequestSummaryViewController createForRequests:progressView.requests];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:rvc];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];

        
        
     
        //[self dismissModalViewControllerAnimated:YES];
    }
    else {
        //otherwise we keep the current view open
        //we need to dismiss this view
        //ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        //PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        //UIProgressHUDView* progressView = delegate.progressView;
        
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        //Re-enable the Submit button
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }

}


- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"ContributeViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([photoID isEqualToNumber:self.photoID]) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            self.img_photo = response.image;
            
            [self displayPhotoFrameOnImage:response.image];
            
            [self.view setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor blackColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    NSString* activityName = @"ContributeViewController.onEnumerateComplete:";
    
    //we have returned from our validation enumerator
    LOG_CONTRIBUTEVIEWCONTROLLER(0, @"%@Validation enumerator returned with %d results",activityName,[enumerator.results count]);
}

#pragma mark - Static Initializers
+ (ContributeViewController*) createInstanceForNewDraft {
    ContributeViewController* contributeViewController = [[ContributeViewController alloc]initWithNibName:@"ContributeViewController" bundle:nil];
    contributeViewController.configurationType = PAGE;
    [contributeViewController autorelease];
    return contributeViewController;
}

+ (ContributeViewController*) createInstanceForNewPhotoWithPageID:(NSNumber*)pageID {
    ContributeViewController* contributeViewController = [[ContributeViewController alloc]initWithNibName:@"ContributeViewController" bundle:nil];
    contributeViewController.configurationType = PHOTO;
    contributeViewController.pageID = pageID;
    [contributeViewController autorelease];
    return contributeViewController;
}

+ (ContributeViewController*) createInstanceForNewCaptionWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID {
    ContributeViewController* contributeViewController = [[ContributeViewController alloc]initWithNibName:@"ContributeViewController" bundle:nil];
    contributeViewController.configurationType = CAPTION;
    contributeViewController.pageID = pageID;
    contributeViewController.photoID = photoID;
    [contributeViewController autorelease];
    return contributeViewController;
}

@end
