//
//  ResourceContext.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Callback.h"
@protocol RequestProgressDelegate;
@class Resource;
@class Query;
@class EnumerationContext;


@interface ResourceContext : NSObject {

    NSMutableDictionary* m_managedObjectContexts;
    NSLock*  m_lock;
  
}

@property (nonatomic,retain) NSLock* managedObjectContextsLock;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain) NSMutableDictionary* managedObjectContexts;

- (NSArray*) save:(BOOL)saveToCloudAfter
onFinishCallback:(Callback*)callback
trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;


- (void) clean;
- (void) insert:(Resource*)resource;
- (void) delete:(NSNumber*)objectID withType:(NSString*)type;

//enumeration methods
- (void) enumerate:(Query*)query
useEnumerationContext:(EnumerationContext*) enumerationContext
shouldEnumerateSinglePage:(BOOL) shouldEnumerateSinglePage 
    onFinishNotify:(Callback*) callback;


//authentication methods
- (void) getAuthenticatorToken:(NSNumber*)facebookID 
                      withName:(NSString*)displayName
                     withEmail:(NSString*)email
       withFacebookAccessToken:(NSString*)facebookAccessToken 
    withFacebookTokenExpiry:(NSDate*)date
               withDeviceToken:(NSString*)deviceToken
                onFinishNotify:(Callback*)callback;

- (void) createUserAndGetAuthenticatorTokenWithEmail:(NSString*)email 
                                        withPassword:(NSString*)password 
                                     withDisplayName:(NSString*)displayName
                                        withUsername:(NSString*)username 
                                     withDeviceToken:(NSString*)deviceToken 
                                      onFinishNotify:(Callback*)callback
                                   trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;


- (void) getAuthenticatorTokenWithEmail:(NSString*)email 
                              withPassword:(NSString*)password 
                           withDeviceToken:(NSString*)deviceToken 
                            onFinishNotify:(Callback*)callback;

- (void) getAuthenticatorTokenWithTwitter:(NSNumber*)twitterID 
                           withTwitterName:(NSString*)twitterName 
                        withAccessToken:(NSString*)twitterAccessToken 
                         withAccessTokenSecret:(NSString*)twitterAccessTokenSecret
                           withExpiryDate:(NSString*)twitterTokenExpiry 
                          withDeviceToken:(NSString*)deviceToken
                           onFinishNotify:(Callback*)callback;

- (void) updateAuthenticatorWithTwitter:(NSString*)twitterUserID 
                      withAccessToken:(NSString*)twitterAccessToken
                withAccessTokenSecret:(NSString*)twitterAccessTokenSecret
                       withExpiryDate:(NSString*)twitterTokenExpiry
                       onFinishNotify:(Callback*)callback;


- (void) updateAuthenticatorWithFacebook:(NSString*)facebookID 
                        withAccessToken:(NSString*)facebookAccessToken
                         withExpiryDate:(NSDate*)facebookAccessTokenExpiry
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

- (Resource*) resourceWithType:(NSString*)typeName 
               withValuesEqual:(NSArray*)valuesArray 
                 forAttributes:(NSArray*)attributeNameArray 
                        sortBy:(NSArray*)sortDescriptorArray;

- (Resource*) singletonResourceWithType:(NSString*)typeName;

- (NSArray*)  resourcesWithType:(NSString*)typeName 
                 withValueEqual:(NSString*)value 
                   forAttribute:(NSString*)attribute 
                         sortBy:(NSArray*)sortDescriptorArray;

- (NSArray*)  resourcesWithType:(NSString*)typeName 
           withValueLessThan:(NSString*)value 
                   forAttribute:(NSString*)attributeName 
                         sortBy:(NSArray*)sortDescriptorArray;

- (NSArray*) resourcesWithType:(NSString*)typeName 
               withValuesEqual:(NSArray*)values 
                 forAttributes:(NSArray*)attributeNames 
                        sortBy:(NSArray*)sortDescriptors;

//- (NSArray*)  resourcesWithType:(NSString*)typeName 
//                 withValueEqual:(NSString*)value 
//                   forAttribute:(NSString*)attribute 
//                         sortBy:(NSString*)sortAttribute 
//                  sortAscending:(BOOL)sortAscending;





//utility methods
- (void) markResourcesAsBeingSynchronized:(NSArray*)resources withResourceTypes:(NSArray*)resourceTypes;
- (void) markResourceAsBeingSynchronized:(NSNumber*)resourceID withResourceType:(NSString*)resourceType;

//static initializers
+ (id) instance;
@end
