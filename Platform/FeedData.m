//
//  FeedData.m
//  Platform
//
//  Created by Jasjeet Gill on 11/20/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FeedData.h"
#import "Attributes.h"

@implementation FeedData
@synthesize key = m_key;
@synthesize objectid = m_objectid;
@synthesize objecttype = m_objecttype;


- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    self.key = [jsonDictionary valueForKey:KEY];
    self.objectid = [jsonDictionary valueForKey:OBJECTID];
    self.objecttype = [jsonDictionary valueForKey:OBJECTTYPE];
    return self;
}

@end
