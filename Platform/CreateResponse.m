//
//  CreateResponse.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CreateResponse.h"
#import "JSONKit.h"
#import "Resource.h"
#import "AttributeChange.h"
@implementation CreateResponse
@synthesize createdResources;
@synthesize consequentialUpdates = m_consequentialUpdates;


- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
   
    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil &&
        [self.didSucceed boolValue] == YES) {
        
        NSArray* jsonCreatedResource = [jsonDictionary valueForKey:CREATEDRESOURCES];
        NSMutableArray *newObjects = [[NSMutableArray alloc]initWithCapacity:[jsonCreatedResource count]];
        for (int i = 0; i < [jsonCreatedResource count];i++) {
            id obj = [jsonCreatedResource objectAtIndex:i];
            Resource *object = [Resource createInstanceOfTypeFromJSON:obj];
            [newObjects insertObject:object atIndex:i];
        }
        self.createdResources = newObjects;
        [newObjects release];
        
        NSArray* jsonConsequentialUpdates = [jsonDictionary valueForKey:CONSEQUENTIALUPDATES];
        if (jsonConsequentialUpdates != nil &&
            jsonConsequentialUpdates != [NSNull null] &&
            [jsonConsequentialUpdates count] > 0)
        {
            NSMutableArray* attributeChanges = [[NSMutableArray alloc]initWithCapacity:[jsonConsequentialUpdates count]];
            
            for (int j = 0; j < [attributeChanges count]; j++)
            {
                //we iterate through the JSON fragments and deserialize the
                //attribute change objects
                //now we process any consequential attribute changes
                id obj = [attributeChanges objectAtIndex:j];
                //now lets deserialize the json payload into instances of this
                AttributeChange* attributeChange = [AttributeChange createInstanceOfAttributeChangeFromJSON:obj];
                //now lets add this attribute change to our array
                [attributeChanges addObject:attributeChange];
            }
            self.consequentialUpdates = attributeChanges;
            [attributeChanges release];
        }
       
     
               
    }
    return self;
}

//this method will return the representation of a created resource
//within this response object whcih matches the specified parameters
-(Resource*) createdResourceWith:(NSNumber*)resourceid 
          withTargetResourceType:(NSString*)targetresourcetype 
{   
    Resource* retVal = nil;
    
    
    for (Resource* createdResource in self.createdResources) {
        if ([createdResource.objectid isEqualToNumber:resourceid] &&
            [createdResource.objecttype isEqualToString:targetresourcetype]) {
            
            //found a match
            retVal = createdResource;
            break;
        }
    }
    
    return retVal;
}


@end
