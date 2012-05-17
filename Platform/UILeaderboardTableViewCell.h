//
//  UILeaderboardTableViewCell.h
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "LeaderboardEntry.h"
#import <UIKit/UIKit.h>

@interface UILeaderboardTableViewCell : UITableViewCell
{
    UITableViewCell*    m_leaderboardTableViewCell;
    UIView              *m_v_background;
    UILabel*            m_lbl_position;
    UIImageView*        m_iv_profilePicture;
    UILabel*            m_lbl_username;
    UILabel*            m_lbl_total;
    
    LeaderboardEntry*   m_leaderboardEntry;
    NSNumber*           m_userID;
}


@property (nonatomic, retain) IBOutlet UITableViewCell* leaderboardTableViewCell;
@property (nonatomic, retain) IBOutlet UIView   *v_background;
@property (nonatomic, retain) IBOutlet UILabel* lbl_position;
@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePicture;
@property (nonatomic, retain) IBOutlet UILabel* lbl_username;
@property (nonatomic, retain) IBOutlet UILabel* lbl_total;

@property (nonatomic, retain) LeaderboardEntry* leaderboardEntry;
@property (nonatomic, retain) NSNumber* userID;

- (void) renderWithEntry:(LeaderboardEntry*)entry forUserWithID:(NSNumber *)userID;

@end
