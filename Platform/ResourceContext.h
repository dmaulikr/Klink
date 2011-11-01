//
//  ResourceContext.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Callback.h"
@class Resource;
@class Query;
@class EnumerationContext;

@interface ResourceContext : NSObject {
    
}
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;

- (void) save:(BOOL)saveToCloudAfter
onFinishCallback:(Callback*)callback;
- (void) insert:(Resource*)resource;

//enumeration methods
- (void) enumerate:(Query*)query
useEnumerationContext:(EnumerationContext*) enumerationContext
shouldEnumerateSinglePage:(BOOL) shouldEnumerateSinglePage 
    onFinishNotify:(Callback*) callback;


//authentication methods
- (void) getAuthenticatorToken:(NSNumber*)facebookID 
                      withName:(NSString*)displayName 
       withFacebookAccessToken:(NSString*)facebookAccessToken 
    withFacebookTokenExpiry:(NSDate*)date 
                onFinishNotify:(Callback*)callback;

- (BOOL) doesExistInLocalStore:(NSNumber*)resourceID;

//data access methods
- (Resource*) resourceWithType:(NSString*)typeName 
                        withID:(NSNumber*)resourceID;

- (Resource*) resourceWithType:(NSString*)typeName 
                withValueEqual:(NSString*)value 
                  forAttribute:(NSString*)attributeName 
                        sortBy:(NSString*)sortByAttribute 
                 sortAscending:(BOOL)sortAscending;

- (Resource*) singletonResourceWithType:(NSString*)typeName;
- (NSArray*)  resourcesWithType:(NSString*)typeName 
                 withValueEqual:(NSString*)value 
                   forAttribute:(NSString*)attribute 
                         sortBy:(NSString*)sortAttribute 
                  sortAscending:(BOOL)sortAscending;

//utility methods
- (void) markResourcesAsBeingSynchronized:(NSArray*)resources withResourceTypes:(NSArray*)resourceTypes;
- (void) markResourceAsBeingSynchronized:(NSNumber*)resourceID withResourceType:(NSString*)resourceType;

//static initializers
+ (id) instance;
@end
