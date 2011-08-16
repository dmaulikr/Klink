//
//  Feed.m
//  Klink V2
//
//  Created by Bobby Gill on 7/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Feed.h"


@implementation Feed
@dynamic type;
@dynamic targetid;
@dynamic targetobjecttype;
@dynamic message;
@dynamic sequencenumber;
@dynamic userid;


- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        
        if ([jsonDictionary objectForKey:an_USERID] != [NSNull null]) {
            self.userid = [jsonDictionary objectForKey:an_USERID];
        }
        
        if ([jsonDictionary objectForKey:an_TYPE] != [NSNull null]) {
            self.type = [jsonDictionary objectForKey:an_TYPE];
        }
        
        if ([jsonDictionary objectForKey:an_TARGETID] != [NSNull null]) {
            self.targetid = [jsonDictionary objectForKey:an_TARGETID];
        }
        
        if ([jsonDictionary objectForKey:an_TARGETOBJECTTYPE] != [NSNull null]) {
            self.targetobjecttype = [jsonDictionary objectForKey:an_TARGETOBJECTTYPE];
        }
        
        if ([jsonDictionary objectForKey:an_MESSAGE] != [NSNull null]) {
            self.message = [jsonDictionary objectForKey:an_MESSAGE];
        }
        
        if ([jsonDictionary objectForKey:an_SEQUENCENUMBER] != [NSNull null]) {
            self.sequencenumber = [jsonDictionary objectForKey:an_SEQUENCENUMBER];
        }
        
        
    }
    return self;
}


+ (NSString*) getTypeName {
    return tn_FEED;
    
}

- (void) copyFrom:(Feed*)newObject {
    [super copyFrom:newObject];
    self.message = [newObject message];
    self.userid= [newObject userid];
    self.type = [newObject type];
    self.targetobjecttype = [newObject targetobjecttype];
    self.targetid = [newObject targetid];
    self.sequencenumber = [newObject sequencenumber];
}


- (id) init {
    self = [super init];
    if (self != nil) {
        self.objecttype = tn_FEED;
        
    }
    return self;
}



@end
