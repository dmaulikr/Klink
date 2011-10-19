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



- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
   
    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil) {                 
        NSArray* jsonCreatedResource = [jsonDictionary objectForKey:CREATEDRESOURCES];
        NSMutableArray *newObjects = [[NSMutableArray alloc]initWithCapacity:[jsonCreatedResource count]];
        for (int i = 0; i < [jsonCreatedResource count];i++) {
            Resource *object = [[Resource alloc]initFromJSONDictionary:[jsonCreatedResource objectAtIndex:i]];
            [newObjects insertObject:object atIndex:i];
        }
        self.createdResources = newObjects;
        [newObjects release];
     
               
    }
    return self;
}



@end
