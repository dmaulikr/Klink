//
//  UIProductionLogTableViewCell.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/17/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProductionLogTableViewCell.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "CallbackResult.h"
#import "Types.h"
#import "Macros.h"

#define kPAGEID @"pageid"

@implementation UIProductionLogTableViewCell
@synthesize pageID = m_pageID;
@synthesize productionLogTableViewCell = m_productionLogTableViewCell;
@synthesize iv_photo = m_iv_photo;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize lbl_deadline = m_lbl_deadline;
@synthesize lbl_numPhotos = m_lbl_numPhotos;
@synthesize lbl_numCaptions = m_lbl_numCaptions;


#pragma mark - Instance Methods

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        self.lbl_draftTitle.text = draft.displayname;
        self.lbl_numPhotos.text = [draft.numberofphotos stringValue];
        self.lbl_numCaptions.text = [draft.numberofcaptions stringValue];
        self.iv_photo.image = nil;
        
        Photo* topPhoto = [draft photoWithHighestVotes];
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:draft.objectid forKey:kPAGEID];
        
        if (topPhoto.thumbnailurl != nil && ![topPhoto.thumbnailurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:topPhoto.thumbnailurl withUserInfo:nil atCallback:callback];
            
            if (image != nil) {
                self.iv_photo.image = image;
            }
        }
    }
    [self setNeedsDisplay];
}

- (void) renderDraftWithID:(NSNumber*)pageID {
    self.pageID = pageID;
    [self render];
}


#pragma mark - Initialization
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIProductionLogTableViewCell" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIProductionLogTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.productionLogTableViewCell];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UIProductionLogTableViewCell.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([draftID isEqualToNumber:self.pageID]) {
            //we only draw the image if this view hasnt been repurposed for another draft
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_photo performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            
            [self setNeedsDisplay];
        }
    }
    else {
        self.iv_photo.backgroundColor = [UIColor blackColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
    
}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"productionlogcell";
}


@end
