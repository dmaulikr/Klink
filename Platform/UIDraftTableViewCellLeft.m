//
//  UIDraftTableViewCellLeft.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIDraftTableViewCellLeft.h"
#import "Photo.h"
#import "Caption.h"
#import "Types.h"
#import "Attributes.h"
#import "FeedManager.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"

#define kPHOTOID                    @"photoid"
#define kCAPTIONID                  @"captionid"
#define kDRAFTTABLEVIEWCELL_TOP     @"drafttableviewcell_top"
#define kDRAFTTABLEVIEWCELL_LEFT    @"drafttableviewcell_left"
#define kDRAFTTABLEVIEWCELL_RIGHT   @"drafttableviewcell_right"

@implementation UIDraftTableViewCellLeft
@synthesize photoID = m_photoID;
@synthesize captionID = m_captionID;
@synthesize draftTableViewCell = m_draftTableViewCell;
@synthesize iv_photo = m_iv_photo;
@synthesize lbl_caption = m_lbl_caption;
@synthesize lbl_photoby = m_lbl_photoby;
@synthesize lbl_captionby = m_lbl_captionby;
@synthesize lbl_numVotes = m_lbl_numVotes;
@synthesize lbl_numCaptions = m_lbl_numCaptions;


#pragma mark - Instance Methods
- (void)render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    if (photo != nil) {        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photo.objectid forKey:kPHOTOID];
        
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
            self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
        }
    }
    
    // reset labels to defualt values
    self.lbl_numVotes.text = @"0";
    self.lbl_numCaptions.text = @"0";
    self.lbl_caption.textColor = [UIColor darkGrayColor];
    self.lbl_caption.text = @"This photo has no captions! Go ahead, add one...";
    
    Caption* topCaption = [photo captionWithHighestVotes];
    if (topCaption != nil) {
        self.captionID = topCaption.objectid;
        self.lbl_caption.textColor = [UIColor blackColor];
        self.lbl_caption.text = [NSString stringWithFormat:@"\"%@\"", topCaption.caption1];
        self.lbl_numVotes.text = [photo.numberofvotes stringValue];
        self.lbl_numCaptions.text = [photo.numberofcaptions stringValue];
    }
    
    self.lbl_captionby.text = [NSString stringWithFormat:@"- written by %@", photo.creatorname];
    self.lbl_photoby.text = [NSString stringWithFormat:@"- illustrated by %@", photo.creatorname];
    
    [self setNeedsDisplay];
}

- (void)renderWithPhotoID:(NSNumber*)photoID {
    self.photoID = photoID;
    
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
        
        [self.lbl_caption setFont:[UIFont fontWithName:@"TravelingTypewriter" size:15]];
        [self.lbl_captionby setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
        [self.lbl_photoby setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
        [self.lbl_numVotes setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
        [self.lbl_numCaptions setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
        
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
    self.lbl_caption = nil;
    self.lbl_numVotes = nil;
    self.lbl_numCaptions = nil;
    [super dealloc];

   // [self.photoID release];
   // [self.captionID release];
   // [self.draftTableViewCellLeft release];
   // [self.iv_photo release];
  //  [self.lbl_caption release];
   // [self.lbl_numVotes release];
   // [self.lbl_numCaptions release];

}

                                                                                             
#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIDraftTableViewCellLeft.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([photoID isEqualToNumber:self.photoID]) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            [self setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor redColor];
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
