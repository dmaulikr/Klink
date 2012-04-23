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
@synthesize entries = __entries;

- (NSArray*) entries
{
    if (__entries != nil)
    {
        return __entries;
    }
    
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* leaderboardentryArray = [self valueForKey:@"leaderboardentries"];
    
    for (NSDictionary* leaderboardEntryDictionary in leaderboardentryArray)
    {
        LeaderboardEntry* leaderboardEntry = [[LeaderboardEntry alloc]initFromJSONDictionary:leaderboardEntryDictionary];
        [retVal addObject:leaderboardEntry];
        [leaderboardEntry release];
    }
    __entries = retVal;
    return __entries;
}

- (void) dealloc
{
    [__entries release];
    [super dealloc];
}
@end
