//
//  PutResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PutResponse.h"


@implementation PutResponse
@synthesize modifiedResource;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"PutResponse.initFromDictionary:";
    
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {
        self.modifiedResource = [ServerManagedResource from:[jsonDictionary objectForKey:an_MODIFIEDRESOURCE]];

    }
    return self;
}

@end
