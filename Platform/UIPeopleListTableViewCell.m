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
#import "PeopleListType.h"


@implementation UIPeopleListTableViewCell
@synthesize followID                    = m_followID;
@synthesize listType                    = m_listType;
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
    Follow* follow = (Follow*)[resourceContext resourceWithType:FOLLOW withID:self.followID];
    
    if (follow != nil) {
        if (self.listType == kFOLLOWING) {
            self.lbl_username.text = follow.username;
            
            //set the appropriate state for the follow button
            if ([loggedInUserID longValue] != [follow.userid longValue] && ![Follow doesFollowExistFor:follow.userid withFollowerID:loggedInUserID]) {
                //this is not the logged in user, nor does the logged in user follow this person, enable the follow button
                [self.btn_follow setSelected:NO];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
            }
            else {
                //logged in user does follow this person, set follow button as selected already
                [self.btn_follow setSelected:YES];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
            }
        }
        else {
            self.lbl_username.text = follow.followername;
            
            //set the appropriate state for the follow button
            if ([loggedInUserID longValue] != [follow.followeruserid longValue] && ![Follow doesFollowExistFor:follow.followeruserid withFollowerID:loggedInUserID]) {
                //this is not the logged in user, nor does the logged in user follow this person, enable the follow button
                [self.btn_follow setSelected:NO];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
            }
            else {
                //logged in user does follow this person, set follow button as selected already
                [self.btn_follow setSelected:YES];
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
            }
        }
    }
    
    [self setNeedsDisplay];
}

- (void) renderCellOfPeopleListType:(int)peopleListType withFollowID:(NSNumber*)followID {
    // Reset tableviewcell properties
    self.followID = nil;
    self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-highlighted.png"];
    self.lbl_username.text = nil;
    [self.btn_follow setSelected:NO];
    
    self.followID = followID;
    self.listType = peopleListType;
    [self render];
}


#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"peoplelisttablecell";
}

@end
