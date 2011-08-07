//
//  Caption.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Caption.h"
#import "User.h"
#import "IDGenerator.h"
@implementation Caption
@dynamic creatorid;
@dynamic caption1;
@dynamic numberofvotes;
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
            self.numberofvotes = [jsonDictionary valueForKey:an_NUMBEROFVOTES];
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
    self.numberofvotes = [newObject numberofvotes];
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
    [dictionary setValue:self.numberofvotes forKey:an_NUMBEROFVOTES];
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

#pragma mark - Static Initializers
+ (Caption*) captionForPhoto:(NSNumber *)photoID withText:(NSString *)captionString {
    NSString* activityName = @"Caption.captionForPhoto:";
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* appContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:appContext];
    
    Caption* caption = [[[Caption alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:nil]init];
   
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance] getAuthenticationContext];
    
    if (authenticationContext != nil) {
        User* user = [User getUserForId:authenticationContext.userid];
        caption.caption1 = captionString;
        caption.creatorid = authenticationContext.userid;
        caption.creatorname = user.username;
        caption.datecreated = [NSDate date];
        caption.dateModified = [NSDate date];
        caption.numberofvotes = 0;
        caption.photoid = photoID;
        caption.isPending = [NSNumber numberWithBool:YES];
        caption.title = captionString;
        caption.objectid = [IDGenerator generateNewId:CAPTION byUser:authenticationContext.userid];
    }
    else {
        NSString* message = [NSString stringWithFormat:@"Cannot create a caption when no user logged in"];
        [BLLog e:activityName withMessage:message];
    }
    
    return caption;
}
@end
