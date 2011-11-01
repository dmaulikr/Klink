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
- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    
    
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {
        self.modifiedResource = [ServerManagedResource from:[jsonDictionary objectForKey:an_MODIFIEDRESOURCE]];
        NSArray* secondaryResultsJSON = [jsonDictionary objectForKey:an_SECONDARYRESULTS];
        
        
        if (secondaryResultsJSON != nil) {
            NSMutableArray* secondaryResults = [[NSMutableArray alloc]init];
            
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];        
                id resource = [ServerManagedResource from:obj_i];
                [secondaryResults insertObject:resource atIndex:i];
                
            }
            self.secondaryResults = secondaryResults;
        }
    }
    return self;
}

@end
