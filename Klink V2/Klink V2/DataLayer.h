//
//  DataLayer.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Klink_V2AppDelegate.h"
#import "BLLog.h"
#import "ApplicationSettings.h"
#import "AuthenticationManager.h"
@class ServerManagedResource;
@interface DataLayer : NSObject {
    long long lastIDGenerated;
}
@property (nonatomic) long long lastIDGenerated;

+ (DataLayer*) getInstance;

+ (id) getObjectByType:(NSString*)typeName withId:(NSNumber*)identifier;

+ (void) deleteObjectByType:(NSString*)typeName withId:(NSNumber*)identifier;

+ (id) getObjectByType:(NSString*)typeName withValueEqual:(NSString*)value forAttribute:(NSString*)attributeName;

+ (id) getObjectByID:(NSNumber*) identifier withObjectType:(NSString*)objectType;

+ (id) getObjectsByType:(NSString*)objectType sortBy:(NSString*)attributeName sortAscending:(BOOL)sortAscending;

+ (id) getObjectsByType:(NSString*)typeName withValueEqual:(NSString*)value forAttribute:(NSString*)attributeName;

+ (id) getNewestTheme;

//+ (void) commitResource:(ServerManagedResource*)resource calledBy:(id)executingObject ;

- (NSNumber*) getNextID;
//
//+ (void) saveAuthenticationContext:context forUser:userID;
@end
