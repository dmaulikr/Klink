//
//  LeaderboardViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Leaderboard.h"
#import "LeaderboardEntry.h"

@interface LeaderboardViewController : UITableViewController
{
    NSNumber* m_leaderboardID;
    Leaderboard* m_leaderboard;
   
}

@property (nonatomic,retain) NSNumber* leaderboardID;
@property (nonatomic,retain) Leaderboard* leaderboard;

+ (LeaderboardViewController*)createInstanceFor:(NSNumber*)leaderboardID;
@end
