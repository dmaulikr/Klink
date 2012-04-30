//
//  Leaderboard.h
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Leaderboard : Resource

@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSNumber* type;
@property (nonatomic,retain) NSNumber* relativeto;
@property (nonatomic,retain) NSArray* leaderboardentries;
@end