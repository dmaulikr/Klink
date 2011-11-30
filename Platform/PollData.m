//
//  PollData.m
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PollData.h"
#import "Attributes.h"

@implementation PollData
@synthesize pollid = m_pollid;
@synthesize numberofvotes = m_numberofvotes;
@synthesize targetobjecttype = m_targetobjecttype;
@synthesize targetid = m_targetid;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    self.pollid = [jsonDictionary valueForKey:POLLID];
    self.targetid = [jsonDictionary valueForKey:TARGETID];
    self.targetobjecttype = [jsonDictionary valueForKey:TARGETOBJECTTYPE];
    return self;
}

@end
