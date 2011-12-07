//
//  PutResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PutResponse.h"


@implementation PutResponse
@synthesize modifiedResource = m_modifiedResource;
@synthesize secondaryResults = m_secondaryResults;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {

    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil && 
        [self.didSucceed boolValue] == YES) {
        
        NSDictionary* modifiedResourceJSONDictionary = [jsonDictionary valueForKey:MODIFIEDRESOURCE];
        if (modifiedResourceJSONDictionary != nil && modifiedResourceJSONDictionary != [NSNull null]) {
        
            self.modifiedResource = [Resource createInstanceOfTypeFromJSON:modifiedResourceJSONDictionary];
        }
        
        //each put response can contain a secondary set of objects that are updated
        //or relevant to the request
        NSArray* secondaryResultsJSON = [jsonDictionary valueForKey:SECONDARYRESULTS];
        
        
        if (secondaryResultsJSON != nil && secondaryResultsJSON != [NSNull null]) {
            NSMutableArray* secondaryResults = [[NSMutableArray alloc]init];
            
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];
                id resource = [Resource createInstanceOfTypeFromJSON:obj_i];
                [secondaryResults addObject:resource];
              
                
            }
            self.secondaryResults = secondaryResults;
            [secondaryResults release];
        }
    }
    return self;
}

@end
