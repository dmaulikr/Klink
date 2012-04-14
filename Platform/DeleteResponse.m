//
//  DeleteResponse.m
//  Platform
//
//  Created by Jasjeet Gill on 3/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "DeleteResponse.h"
#import "AttributeChange.h"
@implementation DeleteResponse
@synthesize deletedObejctID = m_deletedObjectID;
@synthesize consequentialUpdates = m_consequentialUpdates;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
{
    
    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    if ([self.didSucceed boolValue] == YES) 
    {
        self.deletedObejctID = [jsonDictionary valueForKey:DELETEDOBJECTID];
        
        //can also contain consequential updates
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
@end
