//
//  UILeaderboardTableViewCell.m
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UILeaderboardTableViewCell.h"
#import "AuthenticationManager.h"
#import "ImageManager.h"
#import "CallbackResult.h"
#import "Callback.h"

@implementation UILeaderboardTableViewCell
@synthesize v_background                = m_v_background;
@synthesize lbl_total                   = m_lbl_total;
@synthesize lbl_position                = m_lbl_position;
@synthesize lbl_username                = m_lbl_username;
@synthesize iv_profilePicture           = m_iv_profilePicture;
@synthesize leaderboardTableViewCell    = m_leaderboardTableViewCell;
@synthesize leaderboardEntry            = m_leaderboardEntry;
@synthesize userID                      = m_userID;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UILeaderboardTableViewCell" owner:self options:nil];
        
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIProductionLogTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.leaderboardTableViewCell];

    }
    return self;
}

- (void) dealloc
{
    self.leaderboardEntry = nil;
    self.v_background = nil;
    self.lbl_position = nil;
    self.lbl_total = nil;
    self.lbl_username = nil;
    self.iv_profilePicture = nil;
    self.leaderboardTableViewCell= nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) render
{
    ImageManager* imageManager = [ImageManager instance];
    self.lbl_total.text  = [self.leaderboardEntry.points stringValue];
    self.lbl_position.text = [NSString stringWithFormat:@"# %@", [self.leaderboardEntry.position stringValue]];
    self.lbl_username.text = self.leaderboardEntry.username;
    
    NSMutableDictionary* context = [NSMutableDictionary dictionaryWithObject:self.userID forKey:USERID];
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onImageDownloadComplete:) fireOnMainThread:YES];
    callback.context = context;
    UIImage* image = [imageManager downloadImage:self.leaderboardEntry.imageurl withUserInfo:nil atCallback:callback];
    if (image != nil) {
        self.iv_profilePicture.image = image;
    }
    
    /*// If this entry if for the current logged in user, we need to apply special cell formatting
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    if ([self.leaderboardEntry.userid isEqualToNumber:authenticationManager.m_LoggedInUserID]) {*/
    
    // If this entry if for the profile user, we need to apply special cell formatting
    if ([self.leaderboardEntry.userid isEqualToNumber:self.userID]) {
        
        [self.v_background setHidden:NO];
        
        self.lbl_total.textColor = [UIColor whiteColor];
        self.lbl_position.textColor = [UIColor whiteColor];
        self.lbl_username.textColor = [UIColor whiteColor];
        
        self.lbl_username.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:15.0];
         
        // Set text shadow of labels
        [self.lbl_total setShadowColor:[UIColor blackColor]];
        [self.lbl_position setShadowColor:[UIColor blackColor]];
        [self.lbl_username setShadowColor:[UIColor blackColor]];
        [self.lbl_total setShadowOffset:CGSizeMake(0.0, -1.0)];
        [self.lbl_position setShadowOffset:CGSizeMake(0.0, -1.0)];
        [self.lbl_username setShadowOffset:CGSizeMake(0.0, -1.0)];
    }
    else {
        [self.v_background setHidden:YES];
        
        self.lbl_total.textColor = [UIColor blackColor];
        self.lbl_position.textColor = [UIColor darkGrayColor];
        self.lbl_username.textColor = [UIColor blackColor];
        
        self.lbl_username.font = [UIFont fontWithName:@"AmericanTypewriter" size:15.0];
        
        // Set text shadow of labels
        [self.lbl_total setShadowColor:[UIColor whiteColor]];
        [self.lbl_position setShadowColor:[UIColor whiteColor]];
        [self.lbl_username setShadowColor:[UIColor whiteColor]];
        [self.lbl_total setShadowOffset:CGSizeMake(0.0, 1.0)];
        [self.lbl_position setShadowOffset:CGSizeMake(0.0, 1.0)];
        [self.lbl_username setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
}

- (void) renderWithEntry:(LeaderboardEntry*)entry forUserWithID:(NSNumber *)userID
{
    self.leaderboardEntry = entry;
    self.userID = userID;
    [self render];
}
                          
#pragma mark - Image Download Handler
- (void) onImageDownloadComplete:(CallbackResult*)result
{
    NSNumber* userID = [result.context valueForKey:USERID];
    if ([self.userID isEqualToNumber:userID])
    {
        ImageManager* imageManager = [ImageManager instance];
        UIImage* image = [imageManager downloadImage:self.leaderboardEntry.imageurl withUserInfo:nil atCallback:nil];
        self.iv_profilePicture.image = image;
    }
}

@end
