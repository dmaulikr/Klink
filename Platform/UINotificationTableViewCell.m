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
@synthesize lbl_notificationTitle = m_lbl_notificationTitle;
@synthesize lbl_notificationMessage = m_lbl_notificationMessage;
@synthesize img_notificationImage = m_img_notificationImage;
#pragma mark - Frames
- (CGRect) frameForImageView {
    return CGRectMake(20, 28, 108, 83);
}

- (CGRect) frameForNotificationTitle {
    return CGRectMake(0, 0, 240, 21);
}

- (CGRect) frameForNotificationBody {
    return CGRectMake(136, 55, 124, 56);
}

#pragma mark - Instance Methods

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
        
    Feed* notification = (Feed*)[resourceContext resourceWithType:FEED withID:self.notificationID];
   
  
    if (notification != nil) {
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:notification.datecreated];
        self.lbl_notificationTitle.text = [DateTimeHelper formatMediumDateWithTime:dateSent];
        self.lbl_notificationMessage.text = notification.message;
        self.img_notificationImage.image = nil;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:notification.objectid forKey:kNOTIFICATIONID];
        
        if (notification.imageurl != nil &&
            ![notification.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            UIImage* image = [imageManager downloadImage:notification.imageurl withUserInfo:nil atCallback:callback];
            
            if (image != nil) {
                self.img_notificationImage.image = image;
            }
        }

        
    }
}

- (void) renderNotificationWithID:(NSNumber*)notificationID {
    self.notificationID = notificationID;
    [self render];
}

-(id)initWithNotificationID:(NSNumber *)notificationID withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.notificationID = notificationID;
        
        CGRect frameForNotificationMessage = [self frameForNotificationBody];
        self.lbl_notificationMessage = [[UILabel alloc]initWithFrame:frameForNotificationMessage];
        self.lbl_notificationMessage.lineBreakMode = UILineBreakModeWordWrap;
        self.lbl_notificationMessage.numberOfLines = 0;
        
        CGRect frameForNotificationTitle = [self frameForNotificationTitle];
        self.lbl_notificationTitle = [[UILabel alloc]initWithFrame:frameForNotificationTitle];
        
        CGRect frameForImageView = [self frameForImageView];
        self.img_notificationImage = [[UIImageView alloc]initWithFrame:frameForImageView];
        self.img_notificationImage.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.lbl_notificationTitle];
        [self.contentView addSubview:self.lbl_notificationMessage];
        [self.contentView addSubview:self.img_notificationImage];
        
        
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
            [self.img_notificationImage performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
            
            [self setNeedsDisplay];
        }
    }
    else {
        self.img_notificationImage.backgroundColor = [UIColor blackColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"notificationtablecell";
}
@end
