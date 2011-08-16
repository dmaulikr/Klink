//
//  Klink_V2AppDelegate.h
//  Klink V2
//
//  Created by Bobby Gill on 7/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenticationManager.h"
#import "WS_EnumerationManager.h"
#import "FBConnect.h"
@class AuthenticationManager;
@class WS_EnumerationManager;
@interface Klink_V2AppDelegate : NSObject <UIApplicationDelegate> {
    AuthenticationManager* authnManager;
    WS_EnumerationManager* wsEnumerationManager;
    Facebook *facebook;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain, readonly) NSManagedObjectContext *systemObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *systemObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *systemPersistentStoreCoordinator;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) AuthenticationManager *authnManager;
@property (nonatomic, retain) WS_EnumerationManager *wsEnumerationManager;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*) getImageCacheStorageDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) Facebook *facebook;
@end
