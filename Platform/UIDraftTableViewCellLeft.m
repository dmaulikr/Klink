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


#pragma mark - Instance Methods
- (void)render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    Caption* topCaption = [photo captionWithHighestVotes];
    self.captionID = topCaption.objectid;
    
    if (photo != nil || topCaption!= nil) {
        self.lbl_caption.text = topCaption.caption1;
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
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIDraftTableViewCellLeft" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIDraftTableViewCellLeft file.\n");
        }
        
        [self.contentView addSubview:self.draftTableViewCellLeft];
        
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
