//
//  EnumerationResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EnumerationResponse.h"
#import "Resource.h"
#import "Attributes.h"
#import "EnumerationContext.h"
#import "JSONKit.h"
@implementation EnumerationResponse
@synthesize enumerationContext  = m_enumerationContext;
@synthesize date                = m_date;
@synthesize primaryResults      = m_primaryResults;
@synthesize secondaryResults    = m_secondaryResults;

- (id) init {
    self = [super init];
    if (self) {
        self.primaryResults = [[NSArray alloc]init];
        self.secondaryResults = [[NSArray alloc]init];
        self.date = [NSDate date];
        self.enumerationContext = nil;
    }
    return self;
}
- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
        
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil) {
        NSDictionary *enumerationContextDictionary = [jsonDictionary valueForKey:ENUMERATIONCONTEXT];
        if (enumerationContextDictionary != [NSNull null]) {
            self.enumerationContext = [[EnumerationContext alloc]initFromJSONDictionary:[jsonDictionary objectForKey:ENUMERATIONCONTEXT]];
        }

        NSNumber* dateInSecondsSinceEpoch = [jsonDictionary objectForKey:DATE];
        self.date = [[NSDate alloc]initWithTimeIntervalSince1970:[dateInSecondsSinceEpoch doubleValue]];
        
        NSArray* primaryResultsJSON = [jsonDictionary objectForKey:PRIMARY_RESULTS];
        NSArray* secondaryResultsJSON = [jsonDictionary objectForKey:SECONDARY_RESULTS];                        
        //Need to call generic methods to deserialize generic object instances
        
        if (primaryResultsJSON != nil) {
            
            NSMutableArray *primaryResultsObjects = [[NSMutableArray alloc]initWithCapacity:[primaryResultsJSON count]];
            
            for (int i = 0; i < [primaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [primaryResultsJSON objectAtIndex:i];        
                id resource = [Resource createInstanceOfTypeFromJSON:obj_i];
                [primaryResultsObjects insertObject:resource atIndex:i];
                
            }
            self.primaryResults = primaryResultsObjects;
        }
        
        if (secondaryResultsJSON != nil) {
            
            NSMutableArray *secondaryResultsObjects = [[NSMutableArray alloc]initWithCapacity:[secondaryResultsJSON count]];
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];        
                id resource = [Resource createInstanceOfTypeFromJSON:obj_i];
                [secondaryResultsObjects insertObject:resource atIndex:i];
                
            }
            self.secondaryResults = secondaryResultsObjects;
        }

    }
    return self;
}

- (NSString*) toJSON {
    NSString* retVal = nil;
    NSString* responseJSON = [super toJSON];
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc]init];
    
    if (responseJSON != nil) {
        [jsonDictionary setValue:self.enumerationContext forKey:ENUMERATIONCONTEXT];
        [jsonDictionary setValue:self.date forKey:DATE];
        [jsonDictionary setValue:self.primaryResults forKey:PRIMARY_RESULTS];
        [jsonDictionary setValue:self.secondaryResults forKey:SECONDARY_RESULTS];
        NSString* json = [jsonDictionary JSONString];
        retVal = [NSString stringWithFormat:@"%@%@",responseJSON,json];
    }
    return retVal;
}

- (void)dealloc {
    [self.primaryResults release];
    [self.secondaryResults release];
    [super dealloc];
}

@end
