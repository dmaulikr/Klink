//
//  EnumerationResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EnumerationResponse.h"
#import "ServerManagedResource.h"

@implementation EnumerationResponse
@synthesize enumerationContext;
@synthesize date;
@synthesize primaryResults;
@synthesize secondaryResults;


- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"EnumerationResponse.initFromDictionary:";
    
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {
        
        if ([jsonDictionary objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
            self.enumerationContext =[[EnumerationContext alloc]initFromDictionary:[jsonDictionary objectForKey:an_ENUMERATIONCONTEXT]];
            
        }
        
        
        NSNumber* dateInSecondsSinceEpoch = [jsonDictionary objectForKey:an_DATE];
        self.date = [[NSDate alloc]initWithTimeIntervalSince1970:[dateInSecondsSinceEpoch doubleValue]];
        
        NSArray* primaryResultsJSON = [jsonDictionary objectForKey:an_PRIMARYRESULTS];
        NSArray* secondaryResultsJSON = [jsonDictionary objectForKey:an_SECONDARYRESULTS];                        
        //Need to call generic methods to deserialize generic object instances
        
        if (primaryResultsJSON != nil) {
            
            NSMutableArray *primaryResultsObjects = [[NSMutableArray alloc]initWithCapacity:[primaryResultsJSON count]];
            
            for (int i = 0; i < [primaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [primaryResultsJSON objectAtIndex:i];        
                id resource = [ServerManagedResource from:obj_i];
                [primaryResultsObjects insertObject:resource atIndex:i];
                
            }
            self.primaryResults = primaryResultsObjects;
        }
        
        if (secondaryResultsJSON != nil) {
            
            NSMutableArray *secondaryResultsObjects = [[NSMutableArray alloc]initWithCapacity:[secondaryResultsJSON count]];
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];        
                id resource = [ServerManagedResource from:obj_i];
                [secondaryResultsObjects insertObject:resource atIndex:i];
                
            }
            self.secondaryResults = secondaryResultsObjects;
        }
        
        
        
        NSString* message = [[NSString alloc]initWithFormat:@"Created with: date=%@, #ofPrimaryResults=%i, #ofSecondaryResults=%i",date,[primaryResults count],[secondaryResults count]];
        [BLLog v:activityName withMessage:message];
        
        [message release];
    }
    return self;
}

- (void)dealloc {
    [self.primaryResults release];
    [self.secondaryResults release];
    [super dealloc];
}

@end
