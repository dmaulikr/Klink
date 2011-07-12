//
//  Theme.m
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Theme.h"


@implementation Theme
@dynamic creatorid;
@dynamic creatorname;
@dynamic descr;
@dynamic displayname;
@dynamic homeimageurl;


- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        
        if ([jsonDictionary objectForKey:an_CREATORID] != [NSNull null]) {
            self.creatorid = [jsonDictionary objectForKey:an_CREATORID];
        }
        
        if ([jsonDictionary objectForKey:an_CREATORNAME] != [NSNull null]) {
            self.creatorname = [jsonDictionary objectForKey:an_CREATORNAME];
        }
        
        if ([jsonDictionary objectForKey:an_DESCRIPTION] != [NSNull null]) {
            self.descr = [jsonDictionary objectForKey:an_DESCRIPTION];
        }
        
        if ([jsonDictionary objectForKey:an_DISPLAYNAME] != [NSNull null]) {
            self.displayname = [jsonDictionary objectForKey:an_DISPLAYNAME];
        }
        
        if ([jsonDictionary objectForKey:an_HOMEIMAGEURL] != [NSNull null]) {
            self.homeimageurl = [jsonDictionary objectForKey:an_HOMEIMAGEURL];
        }
        
                
    }
    return self;
}

+ (NSString*) getTypeName {
    return tn_THEME;
    
}

- (void) copyFrom:(id)newObject {
    [super copyFrom:newObject];
    self.creatorid = [newObject creatorid];
    self.creatorname= [newObject creatorname];
    self.descr = [newObject descr];
    self.displayname = [newObject displayname];
    self.homeimageurl = [newObject homeimageurl];

}


- (id) init {
    self = [super init];
    if (self != nil) {
        self.objecttype = tn_THEME;
        
    }
    return self;
}

-  (id) toJSON {
    
    NSMutableDictionary *dictionary = nil;
    dictionary = [super toJSON];
    
    [dictionary setValue:self.creatorid forKey:an_CREATORID];
    [dictionary setValue:self.creatorname forKey:an_CREATORNAME];
    [dictionary setValue:self.descr forKey:an_DESCRIPTION];
    [dictionary setValue:self.displayname forKey:an_DISPLAYNAME];
    [dictionary setValue:self.homeimageurl forKey:an_HOMEIMAGEURL];

    
    return dictionary;    
}
@end
