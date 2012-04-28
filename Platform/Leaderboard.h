//
//  Leaderboard.h
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"
#import "LeaderboardTypes.h"
#import "LeaderboardRelativeTo.h"
@interface Leaderboard : Resource

@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSNumber* type;
@property (nonatomic,retain) NSNumber* relativeto;
@property (nonatomic,retain) NSArray* entries;

+ (Leaderboard*) leaderboardForType:(LeaderboardTypes)type andRelativeTo:(LeaderboardRelativeTo)relativeTo;
+ (Leaderboard*) leaderboardForUserID:(NSNumber*)userID withType:(LeaderboardTypes)type andRelativeTo:(LeaderboardRelativeTo)relativeTo;
@end
