//
//  Feed.m
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Feed.h"
#import "JSONKit.h"

@implementation Feed
@dynamic message;
@dynamic feedevent;
@dynamic userid;
@dynamic hasopened;
@dynamic dateexpires;
@dynamic imageurl;
@dynamic rendertype;
@dynamic html;

@synthesize feeddata = __feeddata;

#pragma mark - Properties
- (NSArray*) feeddata {
    if (__feeddata != nil) {
        return __feeddata;
    }
    
    //we need to loop through all of the elements of the feeddatas array on the object
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    NSArray* feedDataArray = [self valueForKey:@"feeddatas"];
    
    for (NSDictionary* feedObjectDictionary in feedDataArray) {
        //we now need to cast each dictionary into a FeedData object
        FeedData* fData = [[FeedData alloc]initFromJSONDictionary:feedObjectDictionary];
        [retVal addObject:fData];
        [fData release];
    }
    
    //we now have an array created with all items deserialized, let us save it
    __feeddata = retVal;
    return __feeddata;
}

- (void) dealloc {
    [__feeddata release];
    [super dealloc];
}
@end
