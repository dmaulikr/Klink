//
//  UIDraftTableViewCell.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIDraftTableViewCell.h"
#import "User.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "Types.h"
#import "Attributes.h"
#import "FeedManager.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "UIImageView+UIImageViewCategory.h"
#import "DateTimeHelper.h"
#import "AuthenticationManager.h"
#import "PageState.h"

#define kPHOTOID                    @"photoid"
#define kCAPTIONID                  @"captionid"
#define kDRAFTTABLEVIEWCELL_TOP     @"drafttableviewcell_top"
#define kDRAFTTABLEVIEWCELL_LEFT    @"drafttableviewcell_left"
#define kDRAFTTABLEVIEWCELL_RIGHT   @"drafttableviewcell_right"
#define kPHOTOFRAMETHICKNESS        30

@implementation UIDraftTableViewCell
@synthesize photoID                 = m_photoID;
@synthesize captionID               = m_captionID;
@synthesize draftTableViewCell      = m_draftTableViewCell;
@synthesize cellType                = m_cellType;
@synthesize iv_photo                = m_iv_photo;
@synthesize iv_photoFrame           = m_iv_photoFrame;
@synthesize lbl_downloading         = m_lbl_downloading;
@synthesize lbl_caption             = m_lbl_caption;
@synthesize lbl_photoby             = m_lbl_photoby;
@synthesize lbl_captionby           = m_lbl_captionby;
@synthesize lbl_numVotes            = m_lbl_numVotes;
@synthesize iv_unreadCaptionBadge   = m_iv_unreadCaptionBadge;
@synthesize btn_writtenBy           = m_btn_writtenBy;
@synthesize btn_illustratedBy       = m_btn_illustratedBy;
@synthesize btn_vote                = m_btn_vote;
@synthesize btn_caption             = m_btn_caption;

#pragma mark - Property Definitions
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<UIDraftTableViewCellDelegate>)del
{
    m_delegate = del;
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

#pragma mark - Instance Methods
- (void) disableVoteButton {
    self.btn_vote.enabled = NO;
}

- (void) enableVoteButton {
    self.btn_vote.enabled = YES;
}

- (void) disableCaptionButton {
    self.btn_caption.enabled = NO;
}

- (void) enableCaptionButton {
    self.btn_caption.enabled = YES;
}

- (void) enableDisableButtons {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.captionID];
    
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:caption.pageid];
    
    NSDate* deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    User* loggedInUser = (User *)[resourceContext resourceWithType:USER withID:loggedInUserID];
    
    
    if ([caption.hasvoted boolValue] == YES) {
        [self.btn_vote setImage:[UIImage imageNamed:@"icon-thumbUp-highlighted.png"] forState:UIControlStateDisabled];
    }
    else if (loggedInUser.objectid && [loggedInUser.objectid isEqualToNumber:caption.creatorid]) {
        [self.btn_vote setImage:[UIImage imageNamed:@"icon-thumbUp.png"] forState:UIControlStateDisabled];
    }
    else {
        [self.btn_vote setImage:[UIImage imageNamed:@"icon-thumbUp.png"] forState:UIControlStateDisabled];
    }
    
    
    if ([draft.state intValue] == kCLOSED || [draft.state intValue] == kPUBLISHED || [deadline compare:[NSDate date]] == NSOrderedAscending) {
        // if this draft has expired, we need to disable the the vote buttons
        [self disableVoteButton];
        [self disableCaptionButton];
    }
    else if (loggedInUser.objectid && [loggedInUser.objectid isEqualToNumber:caption.creatorid]) {
        // if this caption belongs to the currently logged in user, we then disable the voting button
        [self disableVoteButton];
        [self enableCaptionButton];
    }
    else if ([caption.hasvoted boolValue] == YES) {
        [self disableVoteButton];
        [self enableCaptionButton];
    }
    else {
        [self enableVoteButton];
        [self enableCaptionButton];
    }
}

- (void)render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    // reset labels to defualt values
    self.lbl_numVotes.text = @"0";
    self.lbl_caption.textColor = [UIColor darkGrayColor];
    self.lbl_caption.text = @"This photo has no captions! Go ahead, add one...";
    
    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.captionID];
    
    self.photoID = caption.photoid;
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    
    if (caption != nil) {
        // Update unread flag
        if ([caption.hasseen boolValue] == YES) {
            [self.iv_unreadCaptionBadge setHidden:YES];
        }
        else {
            // show the unread badge 
            [self.iv_unreadCaptionBadge setHidden:NO];
        }
        
        if (caption.caption1 == nil || [caption.caption1 isEqualToString:@""] || [caption.caption1 isEqualToString:@" "]) {
            //[self.lbl_caption setHidden:YES];
            [self.lbl_captionby setHidden:YES];
            [self.btn_writtenBy setHidden:YES];
        }
        else {
            self.lbl_caption.textColor = [UIColor blackColor];
            self.lbl_caption.text = [NSString stringWithFormat:@"\"%@\"", caption.caption1];
            self.lbl_captionby.text = [NSString stringWithFormat:@"- written by "];
            [self.btn_writtenBy setTitle:[NSString stringWithFormat:@"%@",caption.creatorname] forState:UIControlStateNormal];
            [self.btn_writtenBy renderWithObjectID:caption.creatorid withName:caption.creatorname];
        }
        
        self.lbl_numVotes.text = [caption.numberofvotes stringValue];
        [self.btn_vote setTitle:[caption.numberofvotes stringValue] forState:UIControlStateNormal];
        
        [self enableDisableButtons];
        
    }
    else {
        //[self.lbl_caption setHidden:YES];
        [self.lbl_captionby setHidden:YES];
        [self.btn_writtenBy setHidden:YES];
    }
    
    //self.lbl_captionby.text = [NSString stringWithFormat:@"- written by"];
    //[self.btn_writtenBy setTitle:[NSString stringWithFormat:@"%@",caption.creatorname] forState:UIControlStateNormal];
    //[self.btn_writtenBy renderWithObjectID:caption.creatorid withName:caption.creatorname];
    
    if (photo != nil) {        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photo.objectid forKey:kPHOTOID];
        
        
        if (self.cellType == kDRAFTTABLEVIEWCELL_TOP) {
            if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
                [callback release];
                if (image != nil) {
                    self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                    self.iv_photo.image = image;
                    
                    [self.lbl_downloading setHidden:YES];
                    
                    [self displayPhotoFrameOnImage:image];
                    
                }
            }
            else {
                self.iv_photo.contentMode = UIViewContentModeCenter;
                self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
                [self.lbl_downloading setHidden:YES];
            }
        }
        else {
            if (photo.thumbnailurl != nil && ![photo.thumbnailurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:nil atCallback:callback];
                [callback release];
                if (image != nil) {
                    self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                    self.iv_photo.image = image;
                }
            }
            else {
                self.iv_photo.contentMode = UIViewContentModeCenter;
                self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
                [self.lbl_photoby setHidden:YES];
            }
        }
        
        self.lbl_photoby.text = [NSString stringWithFormat:@"- illustrated by"];
        [self.btn_illustratedBy renderWithObjectID:photo.creatorid withName:photo.creatorname];
        [self.btn_illustratedBy setTitle:[NSString stringWithFormat:@"%@",photo.creatorname] forState:UIControlStateNormal];
    }
    else {
        [self.lbl_downloading setHidden:NO];
        [self.lbl_downloading setText:@"This draft is unillustrated! Go ahead, add one..."];
        [self.lbl_photoby setHidden:YES];
        [self.btn_illustratedBy setHidden:YES];
    }
    
    [self setNeedsDisplay];
}

- (void) renderWithCaptionID:(NSNumber*)captiondid
{   
    self.captionID = captiondid;
    
    self.btn_vote.enabled = YES;
    
    [self render];
}

- (void)renderWithPhotoID:(NSNumber*)photoID {
    self.photoID = photoID;
    
    self.btn_vote.enabled = YES;
    
    [self render];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
         
        NSArray* topLevelObjs = nil;
        
        if (reuseIdentifier == kDRAFTTABLEVIEWCELL_TOP) {
            topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIDraftTableViewCellTop" owner:self options:nil];
        }
        else if (reuseIdentifier == kDRAFTTABLEVIEWCELL_LEFT) {
            topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIDraftTableViewCellLeft" owner:self options:nil];
        }
        else if (reuseIdentifier == kDRAFTTABLEVIEWCELL_RIGHT) {
            topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIDraftTableViewCellRight" owner:self options:nil];
        }
        
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIDraftTableViewCell nib file for %@.\n", reuseIdentifier);
        }
        
        [self.contentView addSubview:self.draftTableViewCell];
        
        self.cellType = reuseIdentifier;
        
        [self.contentView addSubview:self.btn_writtenBy];
        [self.contentView addSubview:self.btn_illustratedBy];
        [self.contentView addSubview:self.btn_vote];
        [self.contentView addSubview:self.btn_caption];
        
        UIImage* buttonImageNormal = [[UIImage imageNamed:@"button_roundrect_brown.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
        UIImage* buttonImageHighlighted = [[UIImage imageNamed:@"button_roundrect_brown_highlighted.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
        [self.btn_vote setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [self.btn_vote setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        [self.btn_vote setBackgroundImage:buttonImageHighlighted forState:UIControlStateSelected];
        [self.btn_vote setBackgroundImage:buttonImageHighlighted forState:UIControlStateDisabled];
        [self.btn_caption setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [self.btn_caption setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        [self.btn_caption setBackgroundImage:buttonImageHighlighted forState:UIControlStateSelected];
        [self.btn_caption setBackgroundImage:buttonImageHighlighted forState:UIControlStateDisabled];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)dealloc
{
    self.photoID = nil;
    self.captionID = nil;
    self.draftTableViewCell = nil;
    self.iv_photo = nil;
    self.iv_photoFrame = nil;
    self.lbl_downloading = nil;
    self.lbl_caption = nil;
    self.lbl_photoby = nil;
    self.lbl_captionby = nil;
    self.lbl_numVotes = nil;
    self.iv_unreadCaptionBadge = nil;
    self.btn_illustratedBy = nil;
    self.btn_writtenBy = nil;
    self.btn_vote = nil;
    self.btn_caption = nil;
    
    [super dealloc];

}

#pragma mark - UIButton Handlers
- (IBAction) onCaptionButtonPressed:(id)sender {
    [self.delegate onCaptionButtonPressedForPhotoWithID:self.photoID];
}

- (IBAction) onVoteButtonPressed:(id)sender {
    [self.btn_vote setSelected:YES];
    
    [self.delegate onVoteButtonPressedForCaptionWithID:self.captionID];
}

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIDraftTableViewCell.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([photoID isEqualToNumber:self.photoID]) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            [self.lbl_downloading setHidden:YES];
            
            if (self.cellType == kDRAFTTABLEVIEWCELL_TOP) {
                [self displayPhotoFrameOnImage:response.image];
            }
            
            [self setNeedsDisplay];
        }
    }
    else {
        //self.iv_photo.backgroundColor = [UIColor redColor];
        // show the photo placeholder icon
        [self.iv_photo setContentMode:UIViewContentModeCenter];
        self.iv_photo.image = [UIImage imageNamed:@"icon-pics2-large.png"];
        [self.lbl_downloading setHidden:YES];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

}

#pragma mark - Statics
+ (NSString*) cellIdentifierTop {
    return kDRAFTTABLEVIEWCELL_TOP;
}

+ (NSString*) cellIdentifierLeft {
    return kDRAFTTABLEVIEWCELL_LEFT;
}

+ (NSString*) cellIdentifierRight {
    return kDRAFTTABLEVIEWCELL_RIGHT;
}


@end
