//
//  Vote.m
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Vote.h"
#import "AuthenticationManager.h"

@implementation Vote
@dynamic creatorid;
@dynamic targetid;
@dynamic targetobjecttype;
@dynamic pollid;

+ (Vote*)createVoteFor:(NSNumber*)pollID forTarget:(NSNumber *)objectid withType:(NSString *)type {
    ResourceContext* resourceContext = [ResourceContext instance];
    Vote* retVal = [Resource createInstanceOfType:VOTE withResourceContext:resourceContext];
    retVal.pollid = pollID;
    retVal.targetid = objectid;
    retVal.targetobjecttype = type;
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    if ([authenticationManager isUserAuthenticated]) {
        //there is a user authenticated at the moment
        retVal.creatorid = authenticationManager.m_LoggedInUserID;
    }
    return retVal;
    
}
@end
