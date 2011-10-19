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
    
    if (self != nil) {
        self.modifiedResource = [[[Resource alloc ]initWithDictionary:[jsonDictionary objectForKey:MODIFIEDRESOURCE]]autorelease];
        NSArray* secondaryResultsJSON = [jsonDictionary objectForKey:SECONDARYRESULTS];
        
        
        if (secondaryResultsJSON != nil) {
            NSMutableArray* secondaryResults = [[NSMutableArray alloc]init];
            
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];        
                id resource = [[Resource alloc]initFromJSONDictionary:obj_i];
                [secondaryResults insertObject:resource atIndex:i];
                [resource release];
                
            }
            self.secondaryResults = secondaryResults;
        }
    }
    return self;
}

@end
