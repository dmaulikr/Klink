//
//  Caption.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Caption.h"


@implementation Caption
@dynamic creatorid;
@dynamic caption1;
@dynamic numberOfVotes;
@dynamic photoid;
@dynamic title;
@dynamic imageurl;
@dynamic thumbnailurl;
@dynamic creatorname;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.creatorid = [jsonDictionary valueForKey:an_CREATORID];
        self.photoid = [jsonDictionary valueForKey:an_PHOTOID];
        
        if ([jsonDictionary objectForKey:an_TITLE] != [NSNull null]) {
            self.title = [jsonDictionary valueForKey:an_TITLE];
        }
        
        if ([jsonDictionary objectForKey:an_THUMBNAILURL] != [NSNull null]) {
            self.thumbnailurl = [jsonDictionary valueForKey:an_THUMBNAILURL];
        }
        
        if ([jsonDictionary objectForKey:an_CREATORNAME] != [NSNull null]) {
            self.creatorname = [jsonDictionary valueForKey:an_CREATORNAME];
        }
        
        
        if ([jsonDictionary objectForKey:an_IMAGEURL] != [NSNull null]) {
             self.imageurl = [jsonDictionary valueForKey:an_IMAGEURL];
        }
        
        if ([jsonDictionary objectForKey:an_CAPTION] !=[NSNull null] ) {
            self.caption1 = [jsonDictionary valueForKey:an_CAPTION];
        }        

        if ([jsonDictionary objectForKey:an_NUMBEROFVOTES] !=[NSNull null] ) {
            self.numberOfVotes = [jsonDictionary valueForKey:an_NUMBEROFVOTES];
        }        

    }
    return self;
}

+ (NSString*)getNewCaptionTitle {
    return @"New Thought";
}

+(NSString*)getNewCaptionNote {
    return @"Enter your thoughts";
}

+ (NSString*) getTypeName {
    return CAPTION;
}

- (void) copyFrom:(id)newObject {
    [super copyFrom:newObject];
    self.creatorid = [newObject creatorid];
    self.caption1 = [newObject caption1];
    self.numberOfVotes = [newObject numberOfVotes];
    self.photoid = [newObject photoid];
    self.title = [newObject title];
    self.imageurl = [newObject imageurl];
    self.thumbnailurl =[newObject thumbnailurl];
}

- (id) init {
    self = [super init];
    
    if (self != nil) {
        self.objecttype = CAPTION;
    }
    return self;
}
- (id) getCreateNotificationName {
    return n_CAPTION_CREATE;
}
- (id) getUpdateNotificationName {
    return n_CAPTION_UPDATE;
}

-  (id) toJSON {
    NSMutableDictionary *dictionary = nil;
    
    dictionary = [super toJSON];
    [dictionary setValue:self.creatorid forKey:an_CREATORID];
    [dictionary setValue:self.photoid forKey:an_PHOTOID];
    [dictionary setValue:self.caption1 forKey:an_CAPTION];
    [dictionary setValue:self.numberOfVotes forKey:an_NUMBEROFVOTES];
    [dictionary setValue:self.title forKey:an_TITLE];
    [dictionary setValue:self.thumbnailurl forKey:an_THUMBNAILURL];
    [dictionary setValue:self.imageurl forKey:an_IMAGEURL];
    return dictionary;
        
}

- (BOOL)isTextCaption {
    if ([self.imageurl isEqualToString:@""] ||
        self.imageurl == nil) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
