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
    
    CloudEnumerator* m_allALLTIMELeaderboardCloudEnumerator;
    CloudEnumerator* m_allWEEKLYLeaderboardCloudEnumerator;
    CloudEnumerator* m_friendsALLTIMELeaderboardCloudEnumerator;
    CloudEnumerator* m_friendsWEEKLYLeaderboardCloudEnumerator;
   
}

@property (nonatomic,retain) NSNumber* leaderboardID;
@property (nonatomic,retain) Leaderboard* leaderboard;
@property (nonatomic,retain) NSNumber*  userID;

@property (nonatomic, retain) IBOutlet UITableView          *tbl_leaderboard;
@property (nonatomic, retain) IBOutlet UISegmentedControl   *sc_relativeTo;
@property (nonatomic, retain) IBOutlet UISegmentedControl   *sc_type;

@property (nonatomic, retain) CloudEnumerator               *allALLTIMELeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator               *allWEEKLYLeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator               *friendsALLTIMELeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator               *friendsWEEKLYLeaderboardCloudEnumerator;

- (IBAction)onRelativeSelectionChanged:(id)sender;
- (IBAction)onTypeSelectionChanged:(id)sender;
- (void) enumerateLeaderboardOfType:(LeaderboardTypes)type relativeTo:(LeaderboardRelativeTo)relativeTo;

+ (LeaderboardViewController*)createInstanceFor:(NSNumber*)leaderboardID;
+ (LeaderboardViewController*)createInstanceFor:(NSNumber *)leaderboardID forUserID:(NSNumber*)userID;

@end
