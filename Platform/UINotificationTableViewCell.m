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

@implementation UINotificationTableViewCell
@synthesize notificationID = m_notificationID;
@synthesize notificationTableViewCell = m_notificationTableViewCell;
@synthesize resourceLinkButton = m_resourceLinkButton;
@synthesize lbl_notificationMessage = m_lbl_notificationMessage;
@synthesize lbl_notificationDate = m_lbl_notificationDate;
@synthesize iv_notificationImage = m_iv_notificationImage;
@synthesize iv_notificationTypeImage = m_iv_notificationTypeImage;
@synthesize btn_notificationBadge = m_btn_notificationBadge;
@synthesize selector = m_selector;
@synthesize target = m_target;

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
    return [UIFont fontWithName:@"AmericanTypewriter-Bold" size:13];
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
        NSError* error = NULL;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:kUSERREGEX options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:notification.message options:0 range:NSMakeRange(0, [notification.message length])];
        
        // Set up notification image
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
                self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2-large.png"];
            }
        }
        else {
            self.lbl_notificationMessage.frame = CGRectMake(self.lbl_notificationMessage.frame.origin.x, self.lbl_notificationMessage.frame.origin.y, self.iv_notificationImage.frame.origin.x + self.iv_notificationImage.frame.size.width/2, self.lbl_notificationMessage.frame.size.height);
            self.iv_notificationImage.hidden = YES;
        }
        
        
        // Set up notification message
        UIFont* font = [self fontForLabel];
        
        if (numberOfMatches > 0) {
            //we have matches for embedded user links
            
            NSArray* matches = [regex matchesInString:notification.message options:0 range:NSMakeRange(0, [notification.message length])];
            NSMutableArray* newMessageArray = [NSMutableArray arrayWithCapacity:[matches count]];
            
            int startIndex = 0;
            NSRange range;
            NSString* indent = [NSString stringWithFormat:@" "];
            CGSize indentSize = [indent sizeWithFont:font];
            CGSize resourceLinkButtonSize = CGSizeMake(0, 0);
            
            
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
                //now we parse into a NSDictionary
                NSDictionary* jsonDictionary = [jsonString objectFromJSONString];
                //now we have a json dictionary
                NSNumber* userID = [jsonDictionary valueForKey:ID];
                NSString* username = [jsonDictionary valueForKey:USERNAME];
                
                resourceLinkButtonSize = [username sizeWithFont:font];
                self.resourceLinkButton.frame = CGRectMake(self.resourceLinkButton.frame.origin.x, self.resourceLinkButton.frame.origin.y, resourceLinkButtonSize.width, resourceLinkButtonSize.height);
                
                [self.resourceLinkButton setTitle:[NSString stringWithFormat:@"%@",username] forState:UIControlStateNormal];
                [self.resourceLinkButton renderWithObjectID:userID withName:username];
                
                [self.resourceLinkButton setEnabled:YES];
                [self.resourceLinkButton setHidden:NO];
                
            }
            
            //we need to grab the rest of the string from the last range
            if (startIndex < [notification.message length]) {
                NSString* remainder = [notification.message substringFromIndex:startIndex];
                
                for (int i; indentSize.width < resourceLinkButtonSize.width; i++) {
                    // add a space until the indent equals the size of the username resourceLinkButton
                    indent = [NSString stringWithFormat:@"%@ ", indent];
                    indentSize = [indent sizeWithFont:font];
                }
                
                CGSize maximumSize = CGSizeMake(self.lbl_notificationMessage.frame.size.width, 38);
                remainder = [NSString stringWithFormat:@"%@%@", indent, remainder];
                CGSize remainderSize = [remainder sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:self.lbl_notificationMessage.lineBreakMode];
                 
                [self.lbl_notificationMessage setText:[NSString stringWithFormat:@"%@", remainder]];
                
                self.lbl_notificationMessage.frame = CGRectMake(self.lbl_notificationMessage.frame.origin.x, self.lbl_notificationMessage.frame.origin.y, remainderSize.width, remainderSize.height);
                
            }
            
        }
        else {
            //no embedded user links found
            [self.lbl_notificationMessage setText:notification.message];
            
            CGSize maximumSize = CGSizeMake(self.lbl_notificationMessage.frame.size.width, 38);
            CGSize messageSize = [notification.message sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:self.lbl_notificationMessage.lineBreakMode];
            
            self.lbl_notificationMessage.frame = CGRectMake(self.lbl_notificationMessage.frame.origin.x, self.lbl_notificationMessage.frame.origin.y, messageSize.width, messageSize.height);
            
            [self.resourceLinkButton setEnabled:NO];
            [self.resourceLinkButton setHidden:YES];
           
        }
       
        //need to check if the notification has been opened before
        if ([notification.hasopened boolValue] == NO) {
            //never been read, show the unreaad badge
            [self.btn_notificationBadge setHidden:NO];
        }
        else {
            //has been read, hide the unreaad badge
            [self.btn_notificationBadge setHidden:YES];
        }
        
        if ([notification.feedevent intValue] == kCAPTION_VOTE ||
            [notification.feedevent intValue] == kPHOTO_VOTE ||
            [notification.feedevent intValue] == kCAPTION_UNAUTHENTICATED_VOTE ||
            [notification.feedevent intValue] == kPHOTO_UNAUTHENTICATED_VOTE) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-thumbUp.png"];
        }
        else if ([notification.feedevent intValue] == kCAPTION_ADDED) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-compose.png"];
        }
        else if ([notification.feedevent intValue] == kPHOTO_ADDED_TO_DRAFT) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-camera2.png"];
        }
        else if ([notification.feedevent intValue] == DRAFT_ADDED ||
                 [notification.feedevent intValue] == kDRAFT_LEADER_CHANGED) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-page2.png"];
        }
        else if ([notification.feedevent intValue] == kDRAFT_SUBMITTED_TO_EDITORS ||
                 [notification.feedevent intValue] == DRAFT_NOT_SUBMITTED_TO_EDITORS ||
                 [notification.feedevent intValue] == kDRAFT_EXPIRED ||
                 [notification.feedevent intValue] == kDRAFT_NOT_PUBLISHED) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-page4.png"];
        }
        else if ([notification.feedevent intValue] == kDRAFT_PUBLISHED) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-trophy.png"];
        }         
        else if ([notification.feedevent intValue] == kEDITORIAL_BOARD_VOTE_STARTED ||
                 [notification.feedevent intValue] == kEDITORIAL_BOARD_VOTE_CAST ||
                 [notification.feedevent intValue] == kEDITORIAL_BOARD_VOTE_ENDED ||
                 [notification.feedevent intValue] == kEDITORIAL_BOARD_NO_RESULT ||
                 [notification.feedevent intValue] == kMESSAGE) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-globe.png"];
        }         
        else if ([notification.feedevent intValue] == kPROMOTION_TO_EDITOR) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-ribbon1.png"];
        }         
        else if ([notification.feedevent intValue] == kDEMOTION_FROM_EDITOR) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-community.png"];
        }
        else if ([notification.feedevent intValue] == kSHARE_CAPTION_FACEBOOK ||
                 [notification.feedevent intValue] == kSHARE_PAGE_FACEBOOK) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-facebook.png"];
        }
        else if ([notification.feedevent intValue] == kSHARE_CAPTION_TWITTER ||
                 [notification.feedevent intValue] == kSHARE_PAGE_TWITTER) {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-twitter-t.png"];
        }
        else {
            
            self.iv_notificationTypeImage.image = [UIImage imageNamed:@"icon-globe.png"];
        }
    }
    [self setNeedsDisplay];
}

- (void) renderNotificationWithID:(NSNumber*)notificationID 
                  linkClickTarget:(id)target 
                linkClickSelector:(SEL)selector 
{
    // Reset tableviewcell properties
    self.lbl_notificationMessage.frame = CGRectMake(34, 6, 212, 19);
    self.lbl_notificationDate.text = nil;
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
        
        [self.contentView addSubview:self.resourceLinkButton];
        [self.contentView addSubview:self.btn_notificationBadge];
        
        // Custom initialization
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
        
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
    self.notificationID = nil;
    self.notificationTableViewCell = nil;
    self.lbl_notificationMessage = nil;
    self.resourceLinkButton = nil;
    self.lbl_notificationDate = nil;
    self.iv_notificationImage = nil;
    self.iv_notificationTypeImage = nil;
    self.btn_notificationBadge = nil;
    
    [super dealloc];
}

#pragma mark - Button Handlers
- (IBAction) onUsernameButtonPress:(id)sender {
    //click from a resource link
    UIResourceLinkButton* rlb = (UIResourceLinkButton*)sender;
    if (self.target != nil) {
        if ([self.target respondsToSelector:self.selector]) {
            NSNumber* objectID = rlb.objectID;
            [self.target performSelector:self.selector withObject:objectID];
        }
    }
}

- (IBAction) onNotificationBadgeButtonPress:(id)sender {
    [self.btn_notificationBadge setHidden:YES];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Feed* notification = (Feed*)[resourceContext resourceWithType:FEED withID:self.notificationID];
    
    //we need to mark the notification as having been opened
    if ([notification.hasopened boolValue] == NO)
    {
        notification.hasopened = [NSNumber numberWithBool:YES];
    }
    
    //save the notification change
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
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
        //self.iv_notificationImage.backgroundColor = [UIColor redColor];
        // show the photo placeholder icon
        [self.iv_notificationImage setContentMode:UIViewContentModeCenter];
        self.iv_notificationImage.image = [UIImage imageNamed:@"icon-pics2-large.png"];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }

}

- (void)handleTweetNotification:(NSNotification *)notification
{
	NSLog(@"handleTweetNotification: notification = %@", notification);
}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"notificationtablecell";
}
@end
