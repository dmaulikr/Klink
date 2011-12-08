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

#define kNOTIFICATIONID     @"notificationid"

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
    NSString* timeSinceCreated = [[NSString alloc] init];
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"%@ ago",timeSinceCreated];
}

#pragma mark - Instance Methods

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
        
    Feed* notification = (Feed*)[resourceContext resourceWithType:FEED withID:self.notificationID];
  
    if (notification != nil) {
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:notification.datecreated];
        self.lbl_notificationDate.text = [self getDateStringForNotification:dateSent];
        //self.lbl_notificationTitle.text = notification.title;
        self.lbl_notificationMessage.text = notification.message;
        self.iv_notificationImage.image = nil;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:notification.objectid forKey:kNOTIFICATIONID];
        
        if (notification.imageurl != nil &&
            ![notification.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:notification.imageurl withUserInfo:nil atCallback:callback];
            
            if (image != nil) {
                self.iv_notificationImage.contentMode = UIViewContentModeScaleAspectFit;
                self.iv_notificationImage.image = image;
            }
            else {
                self.iv_notificationImage.contentMode = UIViewContentModeCenter;
                self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
            }
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
