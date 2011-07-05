//
//  User.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "User.h"


@implementation User
@dynamic displayName;
@dynamic thumbnailURL;


- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.displayName = [jsonDictionary valueForKey:an_DISPLAYNAME];
        self.thumbnailURL = [jsonDictionary valueForKey:an_THUMBNAILURL];
        
    }
    return self;
}

+ (NSString*) getTypeName {
    return USER;
    
}

- (void) copyFrom:(id)newObject {
    [super copyFrom:newObject];
    self.displayName = [newObject displayName];
    self.thumbnailURL= [newObject thumbnailURL ];

}

-  (id) getCreateNotificationName {
    return n_USER_CREATE;
}
- (id) getUpdateNotificationName {
    return n_USER_UPDATE;
}

-  (id) toJSON {
    NSMutableDictionary *dictionary = nil;
    dictionary = [super toJSON];
    
    [dictionary setObject:self.displayName forKey:an_DISPLAYNAME];
    [dictionary setObject:self.thumbnailURL forKey:an_THUMBNAILURL];
    
    return dictionary;    
}

@end
