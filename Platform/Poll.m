//
//  Poll.m
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Poll.h"
#import "PollData.h"
#import "PollState.h"

@implementation Poll
@dynamic dateexpires;
@dynamic winningobjectid;
@dynamic winningobjecttype;
@dynamic state;
@dynamic hasvoted;
@synthesize polldata = __polldata;

#pragma mark - Properties
- (NSArray*)polldata {
    if (__polldata != nil) {
        return __polldata;
    }
    //we need to loop through all of the elements of the feeddatas array on the object
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* pollDataArray = [self valueForKey:@"polldatas"];
    
    for (NSDictionary* pollObjectDictionary in pollDataArray) {
        //we now need to cast each dictionary into a FeedData object
        PollData* fData = [[PollData alloc]initFromJSONDictionary:pollObjectDictionary];
        [retVal addObject:fData];
        [fData release];
    }
    
    //we now have an array created with all items deserialized, let us save it
    __polldata = retVal;
    return __polldata;
}

- (void) dealloc {
    [__polldata release];
    [super dealloc];
}
@end
