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
#import "FullScreenPhotoViewController.h"

#define kCELLNIBNAME    @"UIDraftTableViewCellLeft"
#define kPHOTOID        @"photoid"
#define kCAPTIONID      @"captionid"

@implementation UIDraftTableViewCellLeft
@synthesize photoID = m_photoID;
@synthesize captionID = m_captionID;
@synthesize draftTableViewCellLeft = m_draftTableViewCellLeft;
@synthesize img_photo = m_img_photo;
@synthesize lbl_caption = m_lbl_caption;
@synthesize lbl_numVotes = m_lbl_numVotes;
@synthesize lbl_numCaptions = m_lbl_numCaptions;


#pragma mark - Frames
- (CGRect) frameForImageView {
    return CGRectMake(20, 18, 120, 78);
}

- (CGRect) frameForCaptionLabel {
    return CGRectMake(148, 18, 152, 48);
}

- (CGRect) frameForNumVotesLabel {
    return CGRectMake(150, 75, 44, 21);
}

- (CGRect) frameForNumCaptionsLabel {
    return CGRectMake(228, 75, 44, 21);
}

#pragma mark - Instance Methods
- (void)render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:self.captionID];
    
    if (photo != nil || caption!= nil) {
        self.lbl_caption.text = caption.caption1;
        self.lbl_numVotes.text = [photo.numberofvotes stringValue];
        self.lbl_numCaptions.text = [photo.numberofcaptions stringValue];
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photo.objectid forKey:kPHOTOID];
        
        if (photo.thumbnailurl != nil && ![photo.thumbnailurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:nil atCallback:callback];
            
            if (image != nil) {
                self.img_photo.image = image;
            }
        }
        
        
    }
    [self setNeedsDisplay];
}

- (void)renderWithPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID {
    self.photoID = photoID;
    self.captionID = captionID;
    [self render];
}

/*- (id)initWithPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.photoID = photoID;
        self.captionID = captionID;
        
        CGRect frameForImageView = [self frameForImageView];
        self.img_photo = [[UIImageView alloc]initWithFrame:frameForImageView];
        
        CGRect frameForCaptionLabel = [self frameForCaptionLabel];
        self.lbl_caption = [[UILabel alloc]initWithFrame:frameForCaptionLabel];
        
        CGRect frameForNumVotesLabel = [self frameForNumVotesLabel];
        self.lbl_numVotes = [[UILabel alloc]initWithFrame:frameForNumVotesLabel];
        
        CGRect frameForNumCaptionsLabel = [self frameForNumCaptionsLabel];
        self.lbl_numCaptions = [[UILabel alloc]initWithFrame:frameForNumCaptionsLabel];
        
        [self.contentView addSubview:self.img_photo];
        [self.contentView addSubview:self.lbl_caption];
        [self.contentView addSubview:self.lbl_numVotes];
        [self.contentView addSubview:self.lbl_numCaptions];
        
    }
    return self;
}*/

- (UIDraftTableViewCellLeft*)loadCell
{    
    self = [super init];
    /*NSArray*	topLevelObjects =*/ [[NSBundle mainBundle] loadNibNamed:kCELLNIBNAME owner:self options:nil];
    
	// tableView cell is already autoreleased
	// return the tableViewCell Outlet, which was set when the nib was loaded
    
    //UIDraftTableViewCellLeft* draftTableViewCellLeft;
    self.draftTableViewCellLeft = (UITableViewCell *)[self.contentView viewWithTag:0];
    
    //UIImageView* img_photo;
    self.img_photo = (UIImageView *)[self.contentView viewWithTag:1];
    
    //UILabel* lbl_caption;
    self.lbl_caption = (UILabel *)[self.contentView viewWithTag:2];
    
    //UILabel* lbl_numVotes;
    self.lbl_numVotes = (UILabel *)[self.contentView viewWithTag:3];
    
    //UILabel* lbl_numCaptions;
    self.lbl_numCaptions = (UILabel *)[self.contentView viewWithTag:4];
    
    [self setNeedsDisplay];
    
	return self;
}

- (id)initWithPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [[NSBundle mainBundle] loadNibNamed:kCELLNIBNAME owner:self options:nil];
        
    if (self) {
        // Initialization code
        
        self.photoID = photoID;
        self.captionID = captionID;
        
        CGRect frameForImageView = [self frameForImageView];
        self.img_photo = [[UIImageView alloc]initWithFrame:frameForImageView];
        
        CGRect frameForCaptionLabel = [self frameForCaptionLabel];
        self.lbl_caption = [[UILabel alloc]initWithFrame:frameForCaptionLabel];
        
        CGRect frameForNumVotesLabel = [self frameForNumVotesLabel];
        self.lbl_numVotes = [[UILabel alloc]initWithFrame:frameForNumVotesLabel];
        
        CGRect frameForNumCaptionsLabel = [self frameForNumCaptionsLabel];
        self.lbl_numCaptions = [[UILabel alloc]initWithFrame:frameForNumCaptionsLabel];
        
        [self.contentView addSubview:self.img_photo];
        [self.contentView addSubview:self.lbl_caption];
        [self.contentView addSubview:self.lbl_numVotes];
        [self.contentView addSubview:self.lbl_numCaptions];
        
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
    [super dealloc];
    [self.photoID release];
    [self.captionID release];
    [self.img_photo release];
    [self.lbl_caption release];
    [self.lbl_numVotes release];
    [self.lbl_numCaptions release];
}
                                                                                             
#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIDraftTableViewCellLeft.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* nid = [userInfo valueForKey:kPHOTOID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([nid isEqualToNumber:self.photoID]) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.img_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            
            [self setNeedsDisplay];
        }
    }
    else {
        self.img_photo.backgroundColor = [UIColor blackColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"drafttablecell_left";
}


@end
