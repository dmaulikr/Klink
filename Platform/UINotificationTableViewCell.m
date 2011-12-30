//
//  UINotificationTableViewCell.m
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UINotificationTableViewCell.h"
#import "Feed.h"
#import "Types.h"
#import "Attributes.h"
#import "FeedManager.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "DateTimeHelper.h"
#import "FeedTypes.h"

#define kNOTIFICATIONID             @"notificationid"

@implementation UINotificationTableViewCell
@synthesize notificationID = m_notificationID;
@synthesize notificationTableViewCell = m_notificationTableViewCell;
//@synthesize lbl_notificationTitle = m_lbl_notificationTitle;
@synthesize lbl_notificationMessage = m_lbl_notificationMessage;
@synthesize lbl_notificationDate = m_lbl_notificationDate;
@synthesize iv_notificationImage = m_iv_notificationImage;
@synthesize iv_notificationTypeImage = m_iv_notificationTypeImage;


- (NSString*) getDateStringForNotification:(NSDate*)notificationDate {
    NSDate* now = [NSDate date];
    NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:notificationDate];
    NSString* timeSinceCreated = nil;
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"%@ ago",timeSinceCreated];
}

#pragma mark - Instance Methods
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    // If not dragging, send event to next responder

        [self.nextResponder touchesEnded: touches withEvent:event]; 

}


- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
        
    Feed* notification = (Feed*)[resourceContext resourceWithType:FEED withID:self.notificationID];
  
    if (notification != nil) {
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:notification.datecreated];
        self.lbl_notificationDate.text = [self getDateStringForNotification:dateSent];
        //self.lbl_notificationTitle.text = notification.title;
        self.lbl_notificationMessage.text = notification.message;
        
        
        /*switch ([notification.type intValue]) {
            case kCAPTION_VOTE | kPHOTO_VOTE:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-thumbUp.png"];
                break;
            case kCAPTION_ADDED:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-compose.png"];
                break;
            case kPHOTO_ADDED_TO_DRAFT:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-camera2.png"];
                break;
            case kDRAFT_SUBMITTED_TO_EDITORS | kDRAFT_EXPIRED | kDRAFT_NOT_PUBLISHED:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-page4.png"];
                break;
            case kDRAFT_PUBLISHED:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-trophy.png"];
                break;
            case kEDITORIAL_BOARD_VOTE_STARTED | kEDITORIAL_BOARD_VOTE_ENDED | kEDITORIAL_BOARD_NO_RESULT:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-globe.png"];
                break;
            case kPROMOTION_TO_EDITOR:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-ribbon1.png"];
                break;
            case kDEMOTION_FROM_EDITOR:
                self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-community.png"];
                break;
            default:
                break;
        }*/
        
        
        if ([notification.type intValue] == kCAPTION_VOTE || [notification.type intValue] == kPHOTO_VOTE) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-thumbUp.png"];
        }
        else if ([notification.type intValue] == kCAPTION_ADDED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-compose.png"];
        }
        else if ([notification.type intValue] == kPHOTO_ADDED_TO_DRAFT) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-camera2.png"];
        }
        else if ([notification.type intValue] == kDRAFT_SUBMITTED_TO_EDITORS || [notification.type intValue] == kDRAFT_EXPIRED || [notification.type intValue] == kDRAFT_NOT_PUBLISHED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-page4.png"];
        }
        else if ([notification.type intValue] == kDRAFT_PUBLISHED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-trophy.png"];
        }         
        else if ([notification.type intValue] == kEDITORIAL_BOARD_VOTE_STARTED || [notification.type intValue] == kEDITORIAL_BOARD_VOTE_ENDED || [notification.type intValue] == kEDITORIAL_BOARD_NO_RESULT) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-globe.png"];
        }         
        else if ([notification.type intValue] == kPROMOTION_TO_EDITOR) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-ribbon1.png"];
        }         
        else if ([notification.type intValue] == kDEMOTION_FROM_EDITOR) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-community.png"];
        }
        
        
        self.iv_notificationImage.image = nil;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:notification.objectid forKey:kNOTIFICATIONID];
        
        if (notification.imageurl != nil &&
            ![notification.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:notification.imageurl withUserInfo:nil atCallback:callback];
            [callback release];
            
            if (image != nil) {
                self.iv_notificationImage.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_notificationImage.image = image;
            }
            else {
                self.iv_notificationImage.contentMode = UIViewContentModeCenter;
                self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
            }
        }
        else {
            self.iv_notificationImage.contentMode = UIViewContentModeCenter;
            self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
        }
    }
    [self setNeedsDisplay];
}

- (void) renderNotificationWithID:(NSNumber*)notificationID {
    self.notificationID = notificationID;
    [self render];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UINotificationTableViewCell" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UINotificationTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.notificationTableViewCell];
        //self.userInteractionEnabled = YES;
        
        /*[self.lbl_notificationMessage setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
        [self.lbl_notificationDate setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];*/
        
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
    /*self.notificationID = nil;
    self.notificationTableViewCell = nil;
    //self.lbl_notificationTitle = nil;
    self.lbl_notificationMessage = nil;
    self.lbl_notificationDate = nil;
    self.iv_notificationImage = nil;
    self.iv_notificationTypeImage = nil;*/
    
    [super dealloc];
}

#pragma mark - Async callbacks
- (void) onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"UINotificationTableViewCell.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    NSNumber* nid = [userInfo valueForKey:kNOTIFICATIONID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([nid isEqualToNumber:self.notificationID]) {
            //we only draw the image if this view hasnt been repurposed for another notification
            LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
            [self.iv_notificationImage performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            self.iv_notificationImage.contentMode = UIViewContentModeScaleAspectFit;
            [self setNeedsDisplay];
        }
    }
    else {
        self.iv_notificationImage.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"notificationtablecell";
}
@end
