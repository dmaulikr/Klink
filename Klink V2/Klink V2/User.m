//
//  User.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "User.h"
#import "DataLayer.h"

@implementation User
@dynamic displayname;
@dynamic thumbnailURL;
@dynamic numberofviews;
@dynamic rank;
@dynamic numberofvotes;
@dynamic numberofcaptions;
@dynamic username;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
      
        if ([jsonDictionary objectForKey:an_DISPLAYNAME] != nil) {
            self.displayname = [jsonDictionary objectForKey:an_DISPLAYNAME];
        }
        
        if ([jsonDictionary objectForKey:an_THUMBNAILURL] != nil) {
            self.thumbnailURL = [jsonDictionary objectForKey:an_THUMBNAILURL];
        }
        
        if ([jsonDictionary objectForKey:an_NUMBEROFVIEWS] != nil) {
            self.numberofviews = [jsonDictionary objectForKey:an_NUMBEROFVIEWS];
        }
        else {
            self.numberofviews = [NSNumber numberWithInt:0];
        }
        
        if ([jsonDictionary objectForKey:an_NUMBEROFVOTES] != nil) {
            self.numberofvotes = [jsonDictionary objectForKey:an_NUMBEROFVOTES];
        }
        else {
            self.numberofvotes = [NSNumber numberWithInt:0];
        }
        
        if ([jsonDictionary objectForKey:an_NUMBEROFCAPTIONS] != nil) {
            self.numberofcaptions = [jsonDictionary objectForKey:an_NUMBEROFCAPTIONS];
        }
        
        else {
            self.numberofcaptions = [NSNumber numberWithInt:0];
        }
        
        if ([jsonDictionary objectForKey:an_RANK] != nil) {
            self.rank = [jsonDictionary objectForKey:an_RANK];
        }
        
        else {
            self.rank = [NSNumber numberWithInt:0];
        }
        
        if ([jsonDictionary objectForKey:an_USERNAME] != nil) {
            self.username = [jsonDictionary objectForKey:an_USERNAME];
        }
       
    }
    return self;
}

+ (NSString*) getTypeName {
    return USER;
    
}

- (void) copyFrom:(id)newObject {
    [super copyFrom:newObject];
    self.displayname = [newObject displayname];
    self.thumbnailURL= [newObject thumbnailURL ];
    self.numberofvotes = [newObject numberofvotes];
    self.numberofviews = [newObject numberofviews];
    self.numberofcaptions = [newObject numberofcaptions];
    self.username = [newObject username];
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
    [dictionary setObject:self.username forKey:an_USERNAME];
    [dictionary setObject:self.displayname forKey:an_DISPLAYNAME];
    [dictionary setObject:self.thumbnailURL forKey:an_THUMBNAILURL];
    [dictionary setObject:self.numberofcaptions forKey:an_NUMBEROFCAPTIONS];
    [dictionary setObject:self.numberofviews forKey:an_NUMBEROFVIEWS];
    [dictionary setObject:self.numberofvotes forKey:an_NUMBEROFVOTES];
    [dictionary setObject:self.rank forKey:an_RANK];
    return dictionary;    
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.objecttype = USER;
        
    }
    return self;
}

+ (User*) getUserForId:(NSNumber *)userid {
    User* user = [DataLayer getObjectByType:USER withId:userid];
    return user;
}

@end
