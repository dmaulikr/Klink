//
//  CreateResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CreateResponse.h"


@implementation CreateResponse
@synthesize createdResources;



- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"CreateResponse.initFromDictionary:";
    
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {                 
        NSArray* jsonCreatedResource = [jsonDictionary objectForKey:an_CREATEDRESOURCES];
        NSMutableArray *newObjects = [[NSMutableArray alloc]initWithCapacity:[jsonCreatedResource count]];
        for (int i = 0; i < [jsonCreatedResource count];i++) {
            ServerManagedResource *object = [ServerManagedResource from:[jsonCreatedResource objectAtIndex:i]];
            [newObjects insertObject:object atIndex:i];
        }
        self.createdResources = newObjects;
        [newObjects release];
        [BLLog v:activityName withMessage:@"dicks"]; 
               
    }
    return self;
}



@end
