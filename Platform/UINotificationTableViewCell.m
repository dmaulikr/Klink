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
#import "UIViewCategory.h"
#import "Macros.h"

#define kNOTIFICATIONID             @"notificationid"
#define kUSERREGEX                  @"\\{.*?\\}"

#define kUNREAD_RED         122
#define kUNREAD_BLUE        122
#define kUNREAD_GREEN       122
#define kUNREAD_ALPHA       0.5

@implementation UINotificationTableViewCell
@synthesize notificationID = m_notificationID;
@synthesize notificationTableViewCell = m_notificationTableViewCell;
//@synthesize lbl_notificationTitle = m_lbl_notificationTitle;
//@synthesize lbl_notificationMessage = m_lbl_notificationMessage;
@synthesize lbl_notificationDate = m_lbl_notificationDate;
@synthesize iv_notificationImage = m_iv_notificationImage;
@synthesize iv_notificationTypeImage = m_iv_notificationTypeImage;
@synthesize selector = m_selector;
@synthesize target = m_target;
@synthesize resourceLinkButton = m_resourceLinkButton;
@synthesize containerView = m_containerView;
@synthesize label = m_label;

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

- (UIFont*) fontForLabel 
{
    return [UIFont fontWithName:@"American Typewriter" size:12];
}
- (UILabel*) labelWithFrame:(CGRect)frame withText:(NSString*)text 
{
    UILabel* label = [[[UILabel alloc]initWithFrame:frame]autorelease];
    label.font = [self fontForLabel];
    label.textColor = [UIColor blackColor];
    label.text = text;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;

    return label;
    
}

- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
        
    Feed* notification = (Feed*)[resourceContext resourceWithType:FEED withID:self.notificationID];
   
    
    if (notification != nil) {
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:notification.datecreated];
        self.lbl_notificationDate.text = [self getDateStringForNotification:dateSent];
        //self.lbl_notificationTitle.text = notification.title;
        NSError* error = NULL;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:kUSERREGEX options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:notification.message options:0 range:NSMakeRange(0, [notification.message length])];
        
        if (numberOfMatches > 0) {
            //we have matches for embedded user links
            CGRect vFrame = CGRectMake(74, 4, 218, 40);
            UIView* containerView = [[UIView alloc]initWithFrame:vFrame];
            [self.contentView addSubview:containerView];
            self.containerView = containerView;
            [containerView release];
            
            NSArray* matches = [regex matchesInString:notification.message options:0 range:NSMakeRange(0, [notification.message length])];
            NSMutableArray* newMessageArray = [NSMutableArray arrayWithCapacity:[matches count]];
            int startIndex = 0;
            int X = 0;
            int Y = 4;
            NSRange range;
            
            for (NSTextCheckingResult *match in matches) {
                range = [match range];
                //need to grab the matched substring
                NSString* jsonString = [notification.message substringWithRange:range];
                //we grab the string token to the left of the substring
                int leftStringEndIndex = range.location;
                if (leftStringEndIndex > 0) 
                {
                    NSRange leftStringRange = NSMakeRange(startIndex, leftStringEndIndex);
                    NSString* leftString = [notification.message substringWithRange:leftStringRange];
                    [newMessageArray addObject:leftString];
                    
                }
                startIndex = range.location + range.length;
                //now we parse into a nsdictionary
                NSDictionary* jsonDictionary = [jsonString objectFromJSONString];
                //now we have a json dictionary
                NSNumber* userID = [jsonDictionary valueForKey:ID];
                NSString* username = [jsonDictionary valueForKey:USERNAME];
                
                //we need to grabthe string range
                //create a resource link button and add it to the
                UIFont* font = [self fontForLabel];
                CGSize labelSize = [username sizeWithFont:font];
                CGRect linkButtonFrame = CGRectMake(X, Y, labelSize.width, labelSize.height);
                UIResourceLinkButton* rlb = [[UIResourceLinkButton alloc]initWithFrame:linkButtonFrame];            
                rlb.titleLabel.font = font;            
                rlb.titleLabel.textColor = [UIColor blackColor];
                [rlb addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
                [rlb renderWithObjectID:userID withName:username];
                X = X + labelSize.width;
                self.resourceLinkButton = rlb;
                
                [containerView addSubview:rlb];
                [rlb release];
                
            }
            
            //we need to grab the rest of the string from the last range
            if (startIndex < [notification.message length]) {
                NSString* remainder = [notification.message substringFromIndex:startIndex];
                UIFont* font = [self fontForLabel];
                CGSize size = [remainder sizeWithFont:font];
                CGRect frame = CGRectMake(X, Y, size.width,size.height);
                UILabel* label = [self labelWithFrame:frame withText:remainder];
                label.autoresizingMask = 2;
                [containerView addSubview:label];
                
            }
            
            
        }
        else {
            //no embedded user links found
            CGRect labelFrame = CGRectMake(74,4,218,40);
            self.label = [self labelWithFrame:labelFrame withText:notification.message];
            [self.contentView addSubview:self.label];
           
        }
       
        //need to check if the notification ahs been opened before
        if ([notification.hasopened boolValue] == NO) {
            //never been read, so lets highlight the background
            self.contentView.backgroundColor = [UIColor colorWithRed:kUNREAD_RED green:kUNREAD_GREEN blue:kUNREAD_BLUE alpha:kUNREAD_ALPHA];
            self.contentView.opaque = NO;
            
            /*CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(0,0,160,73);
            gradient.startPoint = CGPointMake(0.0, 0.5);
            gradient.endPoint = CGPointMake(1.0, 0.5);
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:kUNREAD_RED green:kUNREAD_GREEN blue:kUNREAD_BLUE alpha:kUNREAD_ALPHA] CGColor], (id)[[UIColor clearColor] CGColor], nil];
            [self.contentView.layer insertSublayer:gradient atIndex:0];*/
        }
        else {
            //has been read so lets not highlight the background
            self.contentView.backgroundColor = [UIColor clearColor];
            self.contentView.opaque = YES;
        }
        
        if ([notification.feedevent intValue] == kCAPTION_VOTE || [notification.feedevent intValue] == kPHOTO_VOTE) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-thumbUp.png"];
        }
        else if ([notification.feedevent intValue] == kCAPTION_ADDED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-compose.png"];
        }
        else if ([notification.feedevent intValue] == kPHOTO_ADDED_TO_DRAFT) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-camera2.png"];
        }
        else if ([notification.feedevent intValue] == kDRAFT_SUBMITTED_TO_EDITORS || [notification.feedevent intValue] == kDRAFT_EXPIRED || [notification.feedevent intValue] == kDRAFT_NOT_PUBLISHED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-page4.png"];
        }
        else if ([notification.feedevent intValue] == kDRAFT_PUBLISHED) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-trophy.png"];
        }         
        else if ([notification.feedevent intValue] == kEDITORIAL_BOARD_VOTE_STARTED || [notification.feedevent intValue] == kEDITORIAL_BOARD_VOTE_ENDED || [notification.feedevent intValue] == kEDITORIAL_BOARD_NO_RESULT) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-globe.png"];
        }         
        else if ([notification.feedevent intValue] == kPROMOTION_TO_EDITOR) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-ribbon1.png"];
        }         
        else if ([notification.feedevent intValue] == kDEMOTION_FROM_EDITOR) {
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-community.png"];
        }
        
        
        self.iv_notificationImage.image = nil;
        
        ImageManager* imageManager = [ImageManager instance];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:notification.objectid forKey:kNOTIFICATIONID];
        
        if (notification.imageurl != nil &&
            ![notification.imageurl isEqualToString:@""]) {
            Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
            callback.fireOnMainThread = YES;
            self.iv_notificationImage.hidden = NO;
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
            self.iv_notificationImage.hidden = YES;
            self.iv_notificationImage.contentMode = UIViewContentModeCenter;
            self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
        }
    }
    [self setNeedsDisplay];
}

- (void) renderNotificationWithID:(NSNumber*)notificationID 
                  linkClickTarget:(id)target 
                linkClickSelector:(SEL)selector 
{
    
    if (self.resourceLinkButton != nil) {
        [self.resourceLinkButton removeFromSuperview];
        self.resourceLinkButton = nil;
    }
    self.lbl_notificationDate.text = nil;
    
    if (self.label != nil) {
        [self.label removeFromSuperview];
        self.label = nil;
    }
    if (self.containerView != nil) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.opaque = YES;
    self.target = target;
    self.selector = selector;
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

- (void) onClick:(id)sender {
    //click from a resource link
    UIResourceLinkButton* rlb = (UIResourceLinkButton*)sender;
    if (self.target != nil) {
        if ([self.target respondsToSelector:self.selector]) {
            NSNumber* objectID = rlb.objectID;
            [self.target performSelector:self.selector withObject:objectID];
        }
    }
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
