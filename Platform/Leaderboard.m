//
//  Leaderboard.m
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Leaderboard.h"
#import "LeaderboardEntry.h"
#import "LeaderboardRelativeTo.h"
#import "LeaderboardTypes.h"
#import "AuthenticationManager.h"
#import "Types.h"

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
    
//    if (leaderboardentryArray != nil &&
//        [leaderboardentryArray count] > 0) 
//    {
//        NSDictionary* leaderboardEntryDictionary  = [leaderboardentryArray objectAtIndex:0];
//        NSArray* keyArray = [leaderboardEntryDictionary allKeys];
//        int count = [keyArray count];
//        
//        for (int i = 0; i < count; i++)
//        {
//            
//        }
//        
//        
//
//    }
    __entries = retVal;
    return __entries;
}

- (void) dealloc
{
    [__entries release];
    [super dealloc];
}

+ (Leaderboard*) leaderboardForType:(LeaderboardTypes)type andRelativeTo:(LeaderboardRelativeTo)relativeTo
{
    Leaderboard* retVal = nil;
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if (authenticationManager.isUserAuthenticated)
    {
        NSNumber* loggedInUserID = [authenticationManager m_LoggedInUserID];
       
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[loggedInUserID stringValue], [NSString stringWithFormat:@"%d",relativeTo],[NSString stringWithFormat:@"%d",type], nil];
        
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO,TYPE, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        retVal = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        return retVal;
    }
    else
    {
        return nil;
    }
}
@end
