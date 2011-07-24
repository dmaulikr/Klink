//
//  Klink_V2AppDelegate.m
//  Klink V2
//
//  Created by Bobby Gill on 7/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Klink_V2AppDelegate.h"
#import "RootViewController.h"
#import "SampleViewController.h"
#import "SampleViewController2.h"
#import "HomeScreenController.h"
#import "ApplicationSettings.h"

@implementation Klink_V2AppDelegate

@synthesize facebook;

@synthesize systemObjectModel = __systemObjectModel;

@synthesize systemPersistentStoreCoordinator=__systemPersistentStoreCoordinator;

@synthesize systemObjectContext=__systemObjectContext;

@synthesize window=_window;

@synthesize managedObjectContext=__managedObjectContext;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize navigationController=_navigationController;

@synthesize wsEnumerationManager;

@synthesize authnManager;


#pragma mark - FBSession Delegate Handlers
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [self.facebook handleOpenURL:url]; 
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    facebook = [[Facebook alloc] initWithAppId:facebook_APPID];
    // Override point for customization after application launch.
    self.authnManager = [AuthenticationManager getInstance];
    self.wsEnumerationManager = [WS_EnumerationManager getInstance];
    self.window.rootViewController = self.navigationController;
    
    
    
    [self loginWithDummyAuthenticationContext];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)awakeFromNib
{
    HomeScreenController* viewController = (HomeScreenController*)[self.navigationController topViewController];
    viewController.managedObjectContext = self.managedObjectContext;
    
//    SampleViewController2* viewController = (SampleViewController2*)[self.navigationController topViewController];
//    viewController.managedObjectContext = self.managedObjectContext;
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
//    RootViewController *rootViewController = (RootViewController *)[self.navigationController topViewController];
//    rootViewController.managedObjectContext = self.managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Test_Project_2" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}
- (NSManagedObjectModel *)systemObjectModel
{
    if (__systemObjectModel != nil)
    {
        return __systemObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SystemDataModel" withExtension:@"momd"];
    __systemObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __systemObjectModel;
}

- (NSPersistentStoreCoordinator *)systemPersistentStoreCoordinator
{
    if (__systemPersistentStoreCoordinator != nil)
    {
        return __systemPersistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"System_Data.sqlite"];
    
    NSError *error = nil;
    __systemPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self systemObjectModel]];
    if (![__systemPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __systemPersistentStoreCoordinator;
}


- (NSManagedObjectContext *)systemObjectContext
{
    if (__systemObjectContext != nil)
    {
        return __systemObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self systemPersistentStoreCoordinator];
    if (coordinator != nil)
    {
        __systemObjectContext = [[NSManagedObjectContext alloc] init];
        [__systemObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __systemObjectContext;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Klink_V2.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*) getImageCacheStorageDirectory {
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count])
    {
        NSString *bundleName =
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
    }
    return path;
}

#pragma mark - Dummy login methods
- (void) loginWithDummyAuthenticationContext {
    AuthenticationManager* authenticationManager = [[AuthenticationManager getInstance]retain];
    //Create dummy authentication context
    NSMutableDictionary* authenticationContextDictionary = [[NSMutableDictionary alloc]init];
    NSTimeInterval currentDateInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *currentDate = [NSNumber numberWithDouble:currentDateInSeconds];
    
    [authenticationContextDictionary setObject:[NSNumber numberWithInt:1] forKey:an_USERID];
    [authenticationContextDictionary setObject:[currentDate stringValue] forKey:an_EXPIRY_DATE];
    [authenticationContextDictionary setObject:[NSString stringWithFormat:@"dicks"] forKey:an_TOKEN];
    

    AuthenticationContext* context = [[AuthenticationContext alloc]initFromDictionary:authenticationContextDictionary];
    
    //[authenticationManager loginUser:[NSNumber numberWithInt:1] withAuthenticationContext:context];
    [context release];
}

@end
