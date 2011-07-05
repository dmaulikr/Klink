//
//  Photo.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Photo.h"


@implementation Photo
@dynamic photodescription;
@dynamic numberOfViews;
@dynamic numberOfCaptions;
@dynamic latitude;
@dynamic longitude;
@dynamic thumbnailurl;
@dynamic imageurl;
@dynamic creatorid;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.numberOfCaptions = [jsonDictionary objectForKey:an_NUMBEROFCAPTIONS];
        self.numberOfViews = [jsonDictionary objectForKey:an_NUMBEROFVIEWS];                        
        self.creatorid = [jsonDictionary valueForKey:an_CREATORID];
        
        if ([jsonDictionary objectForKey:an_LOCATIONDESCRIPTION] != [NSNull null]) {
             self.photodescription = [jsonDictionary objectForKey:an_LOCATIONDESCRIPTION];
        }

        
        if ([jsonDictionary objectForKey:an_THUMBNAILURL] != [NSNull null]) {
            self.thumbnailurl = [jsonDictionary objectForKey:an_THUMBNAILURL];
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
    self.photodescription= [newObject photodescription ];
    self.thumbnailurl = [newObject thumbnailurl];
    self.latitude = [newObject latitude];
    self.longitude = [newObject longitude];
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
    [dictionary setValue:self.photodescription forKey:an_LOCATIONDESCRIPTION];
    [dictionary setValue:self.imageurl forKey:an_IMAGEURL];
    [dictionary setValue:self.thumbnailurl forKey:an_THUMBNAILURL];
    
    return dictionary;    
}

+ (NSString*) getNewPhotoTitle {
    NSDate* date = [NSDate date];
    NSString* formattedDateString = [DateTimeHelper formatShortDate:date];
    
    return [NSString stringWithFormat:@"New Topic (%@)",formattedDateString];
}

@end
