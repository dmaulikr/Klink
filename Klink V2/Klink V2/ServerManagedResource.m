//
//  ServerManagedResource.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ServerManagedResource.h"
#import "UserStatistics.h"
#import "User.h"
#import "Photo.h"
#import "Caption.h"
#import "Theme.h"

@implementation ServerManagedResource
@dynamic objectid;
@dynamic datecreated;
@dynamic isPending;
@dynamic dateModified;
@dynamic objecttype;
@dynamic dateLastServerSync;
@dynamic sys_timestamp;
@dynamic sys_version;


- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"ServerManagedResource.initFromDictionary:";
    self.objectid = [jsonDictionary valueForKey:an_OBJECTID];
    
//    //extract system timestamp
//    NSDictionary* timestamp = [jsonDictionary valueForKey:an_SYSTIMESTAMP];
//    NSData *buffer = [timestamp objectForKey:@"Bytes"];
//    self.sys_timestamp =[NSKeyedArchiver archivedDataWithRootObject:buffer];
    self.sys_version = [jsonDictionary objectForKey:an_SYSVERSION];
    
    NSNumber* dateCreatedInSecondsSinceEpoch = [jsonDictionary valueForKey:an_DATECREATED];
    NSDate* dateCreated = [[NSDate alloc] initWithTimeIntervalSince1970:[dateCreatedInSecondsSinceEpoch doubleValue]];
    self.datecreated = dateCreated;
    
    self.objecttype = [jsonDictionary objectForKey:an_OBJECTTYPE];
    //optional attributes
    if ([jsonDictionary objectForKey:an_DATEMODIFIED] !=[NSNull null] ) {
        NSNumber* dateModifiedInSecondsSinceEpoch = [jsonDictionary objectForKey:an_DATEMODIFIED];
        NSDate* dateModified = [[NSDate alloc] initWithTimeIntervalSince1970:[dateModifiedInSecondsSinceEpoch doubleValue]];
        self.dateModified = dateModified;
    }

    
    NSString* message = [NSString stringWithFormat:@"Created from JSON with id=%@, dateCreated=%@,  dateModified=%@", self.objectid,self.datecreated,self.dateModified];
    
    [BLLog v:activityName withMessage:message];
    [dateCreated release];
    
    return self;
}

- (id)init {
    self.objectid = [[DataLayer getInstance] getNextID];
    self.isPending = [NSNumber numberWithBool:YES];
    self.datecreated = [NSDate date];
    self.dateModified = [NSDate date];
    self.sys_version = 0;
    return self;
}

+ (NSString*) getTypeName {
    return SERVERMANAGEDRESOURCE;
}


+ (id) from:(NSDictionary*)jsonObject {
    NSString* activityName = @"ServerManagedResource.from:";    
    NSString* objectType = [jsonObject objectForKey:an_OBJECTTYPE];
    
    NSString* message = [[NSString alloc] initWithFormat:@"deserializing json into objectType %@",objectType];
    [BLLog v:activityName withMessage:message];
    [message release];
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;    
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectType inManagedObjectContext:appContext];
;
    
    
    if ([objectType isEqualToString:tn_USERSTATISTICS]) {
        UserStatistics* userStatisticsObject = [[[[UserStatistics alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] initFromDictionary:jsonObject] autorelease];
        return userStatisticsObject;
    }
    else if ([objectType isEqualToString:PHOTO]) {
         Photo* photoObject = [[[[Photo alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] initFromDictionary:jsonObject] autorelease];
         return photoObject;
    }
    else if ([objectType isEqualToString:CAPTION]) {
        Caption* captionObject = [[[[Caption alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] initFromDictionary:jsonObject] autorelease];
        return captionObject;
    }
    else if ([objectType isEqualToString:USER]) {
        User* userObject = [[[[User alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] initFromDictionary:jsonObject] autorelease];
        return userObject;
    }
    else if ([objectType isEqualToString:tn_THEME]) {
        Theme* themeObject =[[Theme alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil]; 
        [[themeObject initFromDictionary:jsonObject] autorelease];
        return themeObject;
    }
    else {
        [BLLog e:activityName withMessage:@"Unrecognized object type, can not deserialize into client type"];
    }
    
    return nil;
}

- (BOOL) doesExistInStore {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;   
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:self.objecttype inManagedObjectContext:appContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectid=%@",self.objectid];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = nil;
    NSUInteger count = [appContext countForFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    if (count > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void) copyFrom:(id)newObject {
     self.datecreated = [newObject datecreated];
     self.isPending= [newObject isPending ];
     self.dateModified= [newObject dateModified ];
     self.sys_timestamp = [newObject sys_timestamp];
        self.sys_version = [newObject sys_version];
}

- (id) getCreateNotificationName {
    return nil;
}
- (id) getUpdateNotificationName {
    return nil;

}

-  (id) toJSON {
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    NSNumber* dateCreatedInSecondsSinceEpoch =[NSNumber numberWithDouble:[DateTimeHelper convertDateToDouble:self.datecreated]];
    NSNumber* dateModifiedInSecondsSinceEpoch = [NSNumber numberWithDouble:[DateTimeHelper convertDateToDouble:self.dateModified]];
    
    [dictionary setValue:self.objectid forKey:an_OBJECTID];
    [dictionary setValue:dateCreatedInSecondsSinceEpoch forKey:an_DATECREATED];
    [dictionary setValue:dateModifiedInSecondsSinceEpoch forKey:an_DATEMODIFIED];
    [dictionary setValue:self.objecttype forKey:an_OBJECTTYPE];
    [dictionary setValue:self.sys_version forKey:an_SYSVERSION];
    
    NSData* unencodedTimestamp = [NSKeyedUnarchiver unarchiveObjectWithData:self.sys_timestamp];
    
    if (unencodedTimestamp != nil) {
        NSMutableDictionary* timestamp = [[[NSMutableDictionary alloc]init]autorelease];
        [timestamp setValue:unencodedTimestamp forKey:@"Bytes"];
        
        [dictionary setValue:timestamp forKey:an_SYSTIMESTAMP];
    }
    
    return dictionary;
    
}

#pragma mark - persistence methods

- (void) commitChangesToDatabase:(BOOL)postOnSuccess withPendingFlag:(BOOL)isPending{
    NSString* activityName = @"ServerManagedResource.save:";
    //topic description is edited, now we submit
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
   
    self.dateModified = [NSDate date];
    self.isPending = [NSNumber numberWithBool:isPending];
    
    NSError* error = nil;
    [appContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"Save failed with error %@", [error description]];
        [BLLog e:activityName withMessage:message];
    }
    else if (postOnSuccess){
        //notify the transfer manager to update this object
        [[WS_TransferManager getInstance] updateObjectInCloud:self.objectid withObjectType:self.objecttype];
    }

}
+ (void) refreshWithServerVersion:(ServerManagedResource*)resource{
    NSString* activityName = @"ServerManagedResource.refreshWithServerVersion:";
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    
    
    NSDate* currentDate = [NSDate date];
    
    if ([resource doesExistInStore]) {
        ServerManagedResource* existingObject = [DataLayer getObjectByID:resource.objectid withObjectType:resource.objecttype];
        [existingObject copyFrom:resource];
        existingObject.dateLastServerSync = currentDate;
        existingObject.isPending = [NSNumber numberWithBool:NO];
        
    }
    else {
        resource.dateLastServerSync = currentDate;
        resource.isPending = [NSNumber numberWithBool:NO];
        [appContext insertObject:resource];    
  
        
    }
    
    
    NSError* error = nil;
    [appContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"Save failed with error %@", [error description]];
        [BLLog e:activityName withMessage:message];
    }

    
}

-(void) deleteFromDatabase {
    NSString* activityName = @"ServerManagedResource.deleteFromDatabase";
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;
    NSError* error = nil;

    
    
    //first create a deletion log records in the system model
    NSManagedObjectContext *sysContext = appDelegate.systemObjectContext;
    sysContext = appDelegate.systemObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"deletedobject" inManagedObjectContext:sysContext];
    
    
    NSManagedObject *deletionRecord = [[NSManagedObject alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:sysContext];
    
    
    error = nil;
    [deletionRecord setValue:self.objectid forKey:an_OBJECTID];
    [deletionRecord setValue:self.objecttype forKey:an_OBJECTTYPE];
    [deletionRecord setValue:[NSDate date] forKey:an_DATEDELETED];
    
    [sysContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"could not insert deletion record for objectID: %@ due to %@",self.objectid, [error description]];
        [BLLog e:activityName withMessage:message];
    }
    //we need to notify the WS_Transfer manager to communicate the delete to the server
    
    [appContext deleteObject:self];
    
        [appContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"Delete failed with error %@",[error description]];
        [BLLog e:activityName withMessage:message];
    }
    
    //at this point the object is deleted
}
@end
