//
//  Leaderboard.m
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Leaderboard.h"
#import "LeaderboardEntry.h"
@implementation Leaderboard
@dynamic userid;
@dynamic type;
@dynamic relativeto;
@synthesize leaderboardentries = __leaderboardentries;

- (NSArray*) leaderboardentries
{
    if (__leaderboardentries != nil)
    {
        return __leaderboardentries;
    }
    
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* leaderboardentryArray = [self valueForKey:@"leaderboardentries"];
    
    for (NSDictionary* leaderboardEntryDictionary in leaderboardentryArray)
    {
        LeaderboardEntry* leaderboardEntry = [[LeaderboardEntry alloc]initFromJSONDictionary:leaderboardEntryDictionary];
        [retVal addObject:leaderboardEntry];
        [leaderboardEntry release];
    }
    __leaderboardentries = retVal;
    return __leaderboardentries;
}

- (void) dealloc
{
    [__leaderboardentries release];
    [super dealloc];
}
@end
