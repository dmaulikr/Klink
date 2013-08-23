//
//  PlatformAppDelegate.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceContext.h"
#import "AuthenticationManager.h"
#import "ApplicationSettingsManager.h"


#import "UIProgressHUDView.h"


@interface PlatformAppDelegate : NSObject <UIApplicationDelegate> {
    NSString* m_deviceToken;
    BOOL m_isCleaningUpStore;
    
    //we use this queue for delete operations
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSString* deviceToken;
@property (nonatomic, retain) ResourceContext* resourceContext;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) ApplicationSettingsManager*   applicationSettingsManager;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString*) getImageCacheStorageDirectory;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain)           Facebook    *facebook;
@property (nonatomic, retain) UIProgressHUDView*    progressView;
@property BOOL isCleaningUpStore;
@end
