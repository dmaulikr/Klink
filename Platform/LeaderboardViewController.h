//
//  LeaderboardViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 4/24/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Leaderboard.h"
#import "LeaderboardEntry.h"

@interface LeaderboardViewController : BaseViewController < UITableViewDelegate, UITableViewDataSource, CloudEnumeratorDelegate >
{
    NSNumber* m_leaderboardID;
    NSNumber* m_userID;
    Leaderboard* m_leaderboard;
    
    UITableView         *m_tbl_leaderboard;
    UISegmentedControl  *m_sc_relativeTo;
    UISegmentedControl  *m_sc_type;
    
    CloudEnumerator* m_allLeaderboardCloudEnumerator;
    CloudEnumerator* m_friendsLeaderboardCloudEnumerator;
   
}

@property (nonatomic,retain) NSNumber* leaderboardID;
@property (nonatomic,retain) Leaderboard* leaderboard;
@property (nonatomic,retain) NSNumber*  userID;

@property (nonatomic, retain) IBOutlet UITableView          *tbl_leaderboard;
@property (nonatomic, retain) IBOutlet UISegmentedControl   *sc_relativeTo;
@property (nonatomic, retain) IBOutlet UISegmentedControl   *sc_type;

@property (nonatomic, retain) CloudEnumerator               *allLeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator               *friendsLeaderboardCloudEnumerator;

- (IBAction)onRelativeSelectionChanged:(id)sender;
- (IBAction)onTypeSelectionChanged:(id)sender;

+ (LeaderboardViewController*)createInstanceFor:(NSNumber*)leaderboardID;
+ (LeaderboardViewController*)createInstanceFor:(NSNumber *)leaderboardID forUserID:(NSNumber*)userID;

@end
