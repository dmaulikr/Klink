//
//  DeleteResponse.m
//  Platform
//
//  Created by Jasjeet Gill on 3/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "DeleteResponse.h"

@implementation DeleteResponse
@synthesize deletedObejctID = m_deletedObjectID;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
{
    
    
    self = [super initFromJSONDictionary:jsonDictionary]; 
    if ([self.didSucceed boolValue] == YES) 
    {
        self.deletedObejctID = [jsonDictionary valueForKey:DELETEDOBJECTID];
    }
    return self;

}
@end
