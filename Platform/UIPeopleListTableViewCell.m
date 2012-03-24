//
//  UIPeopleListTableViewCell.m
//  Platform
//
//  Created by Jordan Gurrieri on 3/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPeopleListTableViewCell.h"
#import "User.h"
#import "Follow.h"
#import "AuthenticationManager.h"


@implementation UIPeopleListTableViewCell
@synthesize userID                      = m_userID;
@synthesize peopleListTableViewCell     = m_peopleListTableViewCell;
@synthesize lbl_username                = m_lbl_username;
@synthesize iv_profilePicture           = m_iv_profilePicture;
@synthesize btn_follow                  = m_btn_follow;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIPeopleListTableViewCell" owner:self options:nil];
        
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UIPeopleListTableViewCell nib file for %@.\n", reuseIdentifier);
        }
        
        [self.contentView addSubview:self.peopleListTableViewCell];
        
        [self.contentView addSubview:self.btn_follow];
        
        // Setup follow and unfollow buttons
        UIImage* followButtonImageNormal = [UIImage imageNamed:@"button_standardcontrol_blue.png"];
        UIImage* stretchablefollowButtonImageNormal = [followButtonImageNormal stretchableImageWithLeftCapWidth:26 topCapHeight:16];
        [self.btn_follow setBackgroundImage:stretchablefollowButtonImageNormal forState:UIControlStateNormal];
        
        UIImage* followButtonImageSelected = [UIImage imageNamed:@"button_standardcontrol_lightgrey_selected.png"];
        UIImage* stretchablefollowButtonImageSelected = [followButtonImageSelected stretchableImageWithLeftCapWidth:26 topCapHeight:16];
        [self.btn_follow setBackgroundImage:stretchablefollowButtonImageSelected forState:UIControlStateSelected];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) render {
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    
    if (user != nil) {
        self.lbl_username.text = user.username;
        
        //set the appropriate state for the follow button
        //if ([loggedInUserID longValue] == [self.userID longValue]) {
            //yes it is, hide the follow button
        //    self.btn_follow.hidden = YES;
        //}
        //else {
        //    //no it isnt
        //    self.btn_follow.hidden = NO;
            
            if ([loggedInUserID longValue] != [self.userID longValue] && ![Follow doesFollowExistFor:self.userID withFollowerID:loggedInUserID]) {
                //logged in user does not follow this person, enable the follow button
                [self.btn_follow setSelected:NO];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
            }
            else {
                //logged in user does follow this person, set follow button as selected already
                [self.btn_follow setSelected:YES];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
            }
        //}
    }
    
    [self setNeedsDisplay];
}

- (void) renderCellWithUserID:(NSNumber*)userID {
    // Reset tableviewcell properties
    self.userID = nil;
    self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-highlighted.png"];
    self.lbl_username.text = nil;
    [self.btn_follow setSelected:NO];
    
    self.userID = userID;
    [self render];
}


#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"peoplelisttablecell";
}

@end
