//
//  UILeaderboardTableViewCell.m
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UILeaderboardTableViewCell.h"

@implementation UILeaderboardTableViewCell
@synthesize lbl_total                   = m_lbl_total;
@synthesize lbl_position                = m_lbl_position;
@synthesize lbl_username                = m_lbl_username;
@synthesize iv_profilePicture           = m_iv_profilePicture;
@synthesize leaderboardTableViewCell    = m_leaderboardTableViewCell;
@synthesize leaderboardEntry            = m_leaderboardEntry;

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
    self.lbl_total.text  = [self.leaderboardEntry.points stringValue];
    self.lbl_position.text = [self.leaderboardEntry.position stringValue];
    self.lbl_username.text = self.leaderboardEntry.username;
}
- (void) renderWithEntry:(LeaderboardEntry*)entry
{
    self.leaderboardEntry = entry;
    [self render];
}

@end
