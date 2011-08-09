//
//  Photo.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Photo.h"
#import "DataLayer.h"

@implementation Photo
@dynamic descr;
@dynamic numberOfViews;
@dynamic numberOfCaptions;
@dynamic latitude;
@dynamic longitude;
@dynamic thumbnailurl;
@dynamic imageurl;
@dynamic creatorid;
@dynamic themeid;
@dynamic creatorname;
@dynamic numberofvotes;
@synthesize topCaption = __topCaption;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.numberOfCaptions = [jsonDictionary objectForKey:an_NUMBEROFCAPTIONS];
        self.numberOfViews = [jsonDictionary objectForKey:an_NUMBEROFVIEWS];                        
        self.creatorid = [jsonDictionary valueForKey:an_CREATORID];
        
        if ([jsonDictionary objectForKey:an_THEMEID] != [NSNull null]) {
            self.themeid = [jsonDictionary objectForKey:an_THEMEID];
        }
        
        
        if ([jsonDictionary objectForKey:an_DESCRIPTION] != [NSNull null]) {
             self.descr = [jsonDictionary objectForKey:an_DESCRIPTION];
        }

        if ([jsonDictionary objectForKey:an_CREATORNAME] != [NSNull null]) {
            self.creatorname = [jsonDictionary objectForKey:an_CREATORNAME];
        }
        
        if ([jsonDictionary objectForKey:an_NUMBEROFVOTES] != [NSNull null]) {
            self.numberofvotes = [jsonDictionary objectForKey:an_NUMBEROFVOTES];
        }
        
        if ([jsonDictionary objectForKey:an_THUMBNAILURL] != [NSNull null]) {
            self.thumbnailurl = [jsonDictionary objectForKey:an_THUMBNAILURL];
        }
        
        if ([jsonDictionary objectForKey:an_IMAGEURL] != [NSNull null]) {
            self.imageurl = [jsonDictionary objectForKey:an_IMAGEURL];
        }
        
        
        if ([jsonDictionary objectForKey:an_LATITUDE] != [NSNull null]) {
            self.latitude = [jsonDictionary valueForKey:an_LATITUDE];
        }
        
        if ([jsonDictionary objectForKey:an_LONGITUDE] != [NSNull null]) {
            self.longitude = [jsonDictionary valueForKey:an_LONGITUDE];
        }
        
    }
    return self;
}


+ (NSString*) getTypeName {
    return PHOTO;
    
}

- (void) copyFrom:(id)newObject {
    [super copyFrom:newObject];
    self.numberOfCaptions = [newObject numberOfCaptions];
    self.numberOfViews= [newObject numberOfViews ];
    self.creatorid= [newObject creatorid ];
    self.descr= [newObject descr ];
    self.thumbnailurl = [newObject thumbnailurl];
    self.imageurl = [newObject imageurl];
    self.latitude = [newObject latitude];
    self.longitude = [newObject longitude];
    self.themeid = [newObject themeid];
    self.numberofvotes = [newObject numberofvotes];
}



- (id) init {
    self = [super init];
    if (self != nil) {
        self.objecttype = PHOTO;
        
    }
    return self;
}

-  (id) getCreateNotificationName {
    return n_PHOTO_CREATE;
}
-  (id) getUpdateNotificationName {
    return n_PHOTO_UPDATE;
}

-  (id) toJSON {
    
    NSMutableDictionary *dictionary = nil;
    dictionary = [super toJSON];
    
    [dictionary setValue:self.creatorid forKey:an_CREATORID];
    [dictionary setValue:self.numberOfCaptions forKey:an_NUMBEROFCAPTIONS];
    [dictionary setValue:self.numberOfViews forKey:an_NUMBEROFVIEWS];
    [dictionary setValue:self.descr forKey:an_DESCRIPTION];
    [dictionary setValue:self.imageurl forKey:an_IMAGEURL];
    [dictionary setValue:self.thumbnailurl forKey:an_THUMBNAILURL];
    [dictionary setValue:self.themeid forKey:an_THEMEID];
    [dictionary setValue:self.numberofvotes forKey:an_NUMBEROFVOTES];
    return dictionary;    
}

- (void) dealloc {
    if (__topCaption != nil) {
        [__topCaption release];
    }
}

- (Caption*)topCaption {
    if (__topCaption != nil) {
        return __topCaption;
    }
    
    Caption* caption = [[DataLayer getTopCaption:self.objectid] retain];
    __topCaption = caption;
    return __topCaption;
}


+ (NSString*) getNewPhotoTitle {
    NSDate* date = [NSDate date];
    NSString* formattedDateString = [DateTimeHelper formatShortDate:date];
    
    return [NSString stringWithFormat:@"New Topic (%@)",formattedDateString];
}


+ (Photo*)photo:(NSNumber*)objectID {
    Photo* retVal = [DataLayer getObjectByType:PHOTO withId:objectID];
    return retVal;
}

@end
