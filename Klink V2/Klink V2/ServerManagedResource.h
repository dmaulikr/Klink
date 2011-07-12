//
//  ServerManagedResource.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "IWireSerializable.h"
#import "Klink_V2AppDelegate.h"
#import "TypeNames.h"
#import "AttributeNames.h"
#import "DateTimeHelper.h"
#import "NotificationNames.h"
#import "TypeNames.h"
#import "WS_TransferManager.h"
@class UserStatistics;
@class User;
@class Caption;
@class Photo;
@class Theme;
@interface ServerManagedResource : NSManagedObject <IWireSerializable> {
    
@private
}
@property (nonatomic, retain) NSNumber * objectid;
@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain)  NSNumber* isPending;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString* objecttype;
@property (nonatomic, retain) NSDate* dateLastServerSync;
@property (nonatomic, retain) NSData* sys_timestamp;
@property (nonatomic, retain) NSNumber* sys_version;

- (BOOL) doesExistInStore;
- (void) copyFrom:(id)newObject;
+ (id) from:(NSDictionary*)jsonObject;
- (id) getCreateNotificationName;
- (id) getUpdateNotificationName;
- (id) init;
- (id) toJSON;


- (void) commitChangesToDatabase:(BOOL)postOnSuccess withPendingFlag:(BOOL)isPending;
+ (void) refreshWithServerVersion:(id)serverVersion;
-(void) deleteFromDatabase;
@end
