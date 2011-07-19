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
@dynamic numberofviews;
@dynamic rank;
@dynamic numberofvotes;
@dynamic numberofcaptions;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.displayName = [jsonDictionary valueForKey:an_DISPLAYNAME];
        self.thumbnailURL = [jsonDictionary valueForKey:an_THUMBNAILURL];
        self.numberofviews = [jsonDictionary valueForKey:an_NUMBEROFVIEWS];
        self.numberofcaptions = [jsonDictionary valueForKey:an_NUMBEROFCAPTIONS];
        self.numberofvotes = [jsonDictionary valueForKey:an_NUMBEROFVOTES];
        self.rank = [jsonDictionary valueForKey:an_RANK];
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
    self.numberofvotes = [newObject numberofvotes];
    self.numberofviews = [newObject numberofviews];
    self.numberofcaptions = [newObject numberofcaptions];
    self.rank = [newObject rank];
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
    [dictionary setObject:self.numberofcaptions forKey:an_NUMBEROFCAPTIONS];
    [dictionary setObject:self.numberofviews forKey:an_NUMBEROFVIEWS];
    [dictionary setObject:self.numberofvotes forKey:an_NUMBEROFVOTES];
    [dictionary setObject:self.rank forKey:an_RANK];
    return dictionary;    
}

@end
