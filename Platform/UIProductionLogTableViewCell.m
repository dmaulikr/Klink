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
#import "DateTimeHelper.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"

@implementation UIProductionLogTableViewCell
@synthesize pageID = m_pageID;
@synthesize productionLogTableViewCell = m_productionLogTableViewCell;
@synthesize iv_photo = m_iv_photo;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize lbl_deadline = m_lbl_deadline;
@synthesize lbl_numPhotos = m_lbl_numPhotos;
@synthesize lbl_numCaptions = m_lbl_numCaptions;
@synthesize topVotedPhotoID = m_topVotedPhotoID;
@synthesize deadline;

@synthesize eventManager = __eventManager;


#pragma mark - Properties
- (EventManager*) eventManager {
    if (__eventManager != nil) {
        return __eventManager;
    }
    __eventManager = [EventManager instance];
    return __eventManager;
}

#pragma mark - Deadline Date Timer
- (void) timeRemaining:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    NSTimeInterval remaining = [self.deadline timeIntervalSinceDate:now];
    self.lbl_deadline.text = [NSString stringWithFormat:@"deadline: %@", [DateTimeHelper formatTimeInterval:remaining]];
    [self setNeedsDisplay];
}


- (void) renderPhoto:(Photo*)photo {
    
    ImageManager* imageManager = [ImageManager instance];
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.pageID forKey:kPAGEID];
    
    //add the photo id to the context
    [userInfo setValue:photo.objectid forKey:kPHOTOID];
    
    if (photo.thumbnailurl != nil && 
        ![photo.thumbnailurl isEqualToString:@""]) 
    {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:nil atCallback:callback];
        
        if (image != nil) {
            self.iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            self.iv_photo.image = image;
        }
    }
    else {
        self.iv_photo.contentMode = UIViewContentModeCenter;
        self.iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
    }
    [self setNeedsDisplay];
}

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        self.lbl_draftTitle.text =  draft.displayname;
        self.lbl_numPhotos.text = [draft.numberofphotos stringValue];
        self.lbl_numCaptions.text = [draft.numberofcaptions stringValue];
        
        Photo* topPhoto = [draft photoWithHighestVotes];
        self.topVotedPhotoID = topPhoto.objectid;
        [self renderPhoto:topPhoto];
        
        // Set deadline
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timeRemaining:)
                                       userInfo:nil
                                        repeats:YES];
    
    }
    [self setNeedsDisplay];
}

- (void) renderDraftWithID:(NSNumber*)pageID {
    self.pageID = pageID;
    
    //we also need to nil the topVotedPhotoID
    self.topVotedPhotoID = nil;
    self.deadline = nil;
    
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
        self.topVotedPhotoID = nil;
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIProductionLogTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.productionLogTableViewCell];
        
        // resister callbacks for newPhotoVote events incase the topPhoto changes
        Callback* newPhotoVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhotoVote:)];
        
        [self.eventManager registerCallback:newPhotoVoteCallback forSystemEvent:kNEWPHOTOVOTE];
        
        [newPhotoVoteCallback release];
        
        [self.lbl_draftTitle setFont:[UIFont fontWithName:@"TravelingTypewriter" size:17]];
        [self.lbl_deadline setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
        [self.lbl_numPhotos setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
        [self.lbl_numCaptions setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
        
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
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([draftID isEqualToNumber:self.pageID] &&
            [photoID isEqualToNumber:self.topVotedPhotoID]) {
            
            //we only draw the image if this view hasnt been repurposed for another draft
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
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

- (void) onNewPhotoVote:(CallbackResult*)result {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        Photo* topPhoto = [draft photoWithHighestVotes];
        self.topVotedPhotoID = topPhoto.objectid;
        [self renderPhoto:topPhoto];
    }
}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"productionlogcell";
}


@end
