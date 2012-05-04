//
//  PutResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PutResponse.h"
#import "AttributeChange.h"
#import "ObjectChange.h"

@implementation PutResponse
@synthesize modifiedResource = m_modifiedResource;
@synthesize secondaryResults = m_secondaryResults;
@synthesize consequentialUpdates = m_consequentialUpdates;
@synthesize consequentialInserts = m_consequentialInserts;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {

    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil && 
        [self.didSucceed boolValue] == YES) {
        
        NSDictionary* modifiedResourceJSONDictionary = [jsonDictionary valueForKey:MODIFIEDRESOURCE];
        if (modifiedResourceJSONDictionary != nil && ! [modifiedResourceJSONDictionary isEqual:[NSNull null]]) {
        
            self.modifiedResource = [Resource createInstanceOfTypeFromJSON:modifiedResourceJSONDictionary];
        }
        
        //each put response can contain a secondary set of objects that are updated
        //or relevant to the request
        NSArray* secondaryResultsJSON = [jsonDictionary valueForKey:SECONDARYRESULTS];
        
        
        if (secondaryResultsJSON != nil && ![secondaryResultsJSON isEqual: [NSNull null]]) {
            NSMutableArray* secondaryResults = [[NSMutableArray alloc]init];
            
            
            for (int i = 0; i < [secondaryResultsJSON count]; i++) {
                NSDictionary* obj_i = [secondaryResultsJSON objectAtIndex:i];
                id resource = [Resource createInstanceOfTypeFromJSON:obj_i];
                [secondaryResults addObject:resource];
              
                
            }
            self.secondaryResults = secondaryResults;
            [secondaryResults release];
        }
        
        //can also contain consequential updates
        NSArray* jsonConsequentialUpdates = [jsonDictionary valueForKey:CONSEQUENTIALUPDATES];
        if (jsonConsequentialUpdates != nil &&
            jsonConsequentialUpdates != [NSNull null] &&
            [jsonConsequentialUpdates count] > 0)
        {
            NSMutableArray* attributeChanges = [[NSMutableArray alloc]init];
            int count = [jsonConsequentialUpdates count];
            //NSMutableArray* attributeChanges = [[NSMutableArray alloc]initWithCapacity:[jsonConsequentialUpdates count]];
            
            for (int j = 0; j < count; j++)
            {
                //we iterate through the JSON fragments and deserialize the
                //attribute change objects
                //now we process any consequential attribute changes
                id obj = [jsonConsequentialUpdates objectAtIndex:j];
                //now lets deserialize the json payload into instances of this
                AttributeChange* attributeChange = [AttributeChange createInstanceOfAttributeChangeFromJSON:obj];
                //now lets add this attribute change to our array
                [attributeChanges addObject:attributeChange];
            }
            self.consequentialUpdates = attributeChanges;
            
            [attributeChanges release];
        }
        
        NSArray* jsonConsequentialInserts = [jsonDictionary valueForKey:CONSEQUENTIALINSERTS];
        
        if (jsonConsequentialInserts != nil &&
            jsonConsequentialInserts != [NSNull null] &&
            [jsonConsequentialInserts count] > 0) {
            
            NSMutableArray* objectInsertions = [[NSMutableArray alloc]init];
            
            for (int j = 0; j < [jsonConsequentialInserts count]; j++)
            {
                id obj = [jsonConsequentialInserts objectAtIndex:j];
                ObjectChange* objectChange = [ObjectChange createInstanceOfObjectChangeFromJSON:obj];
                [objectInsertions addObject:objectChange];
            }
            self.consequentialInserts = objectInsertions;
            [objectInsertions release];
        }
    }
    return self;
}

@end
