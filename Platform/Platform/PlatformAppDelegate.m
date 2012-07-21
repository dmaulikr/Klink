//
//  PlatformAppDelegate.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PlatformAppDelegate.h"

#import "SampleViewController.h"
#import "AuthenticationManager.h"
#import "ApplicationSettings.h"
#import "User.h"
#import "CloudEnumerator.h"
#import "CloudEnumeratorFactory.h"
#import "Macros.h"
#import "NotificationsViewController.h"
#import "BookViewControllerBase.h"
#import "BookViewControllerLeaves.h"
#import "Page.h"
#import "Photo.h"
#import "DateTimeHelper.h"
#import "Caption.h"
#import "Feed.h"
#import "UserDefaultSettings.h"
#import "PageState.h"
#import "ImageManager.h"
#import "ProductionLogViewController.h"
#import "FlurryAnalytics.h"

@implementation PlatformAppDelegate


@synthesize window=_window;
@synthesize deviceToken = m_deviceToken;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize progressView = __progressView;

@synthesize managedObjectModel=__managedObjectModel;

@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize navigationController=_navigationController;

@synthesize resourceContext = __resourceContext;

@synthesize authenticationManager = __authenticationManager;

@synthesize applicationSettingsManager = __applicationSettingsManager;

@synthesize facebook = __facebook;

#define     kFACEBOOKAPPID  @"315632228463614"

#pragma mark - Properties
- (UIProgressHUDView*)progressView {
    if (__progressView != nil) {
        return __progressView;
    }
    UIProgressHUDView* pv = [[UIProgressHUDView alloc]initWithWindow:self.window];
    __progressView = pv;
    
    
    return __progressView;
}

- (ApplicationSettingsManager*)applicationSettingsManager {
    if (__applicationSettingsManager != nil) {
        return __applicationSettingsManager;
    }
    __applicationSettingsManager = [ApplicationSettingsManager instance];
    return __applicationSettingsManager;
}

- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }

    __facebook = [[Facebook alloc]initWithAppId:kFACEBOOKAPPID];
    
    return __facebook;
    
}

- (AuthenticationManager*) authenticationManager {
    if (__authenticationManager != nil) {
        return __authenticationManager;
    }
    
    __authenticationManager = [AuthenticationManager instance];
    return __authenticationManager;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // obtain facebook instance ref
    return [self.facebook handleOpenURL:url];
    
}

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString* activityName = @"PlatformAppDelegate.applicationDidiFinishLoading:";
    // Override point for customization after application launch.
    
    // Flurry Analytics Setup
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAnalytics startSession:@"9X2WMNNCMDH7HNM7J697"];
    // Enable Flurry agent to automatically detect and log page views on the root navigation controller
    [FlurryAnalytics logAllPageViews:self.navigationController];
    
    //we trigger the instantiation of the authentication manager 
    //and other singletons
//    NSManagedObjectContext* context = self.managedObjectContext;
    [self.applicationSettingsManager settings];    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
   
    application.applicationSupportsShakeToEdit = NO;
    
    //register for push notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    
    backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
    /*// Launch the BookView home page
    BookViewControllerBase* bookViewController = [BookViewControllerBase createInstance];
    self.navigationController = [[[UINavigationController alloc]initWithRootViewController:bookViewController] autorelease];
    
    self.window.rootViewController = self.navigationController;
 
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];*/
    
    
    //let us make some checks beginning with the user object
    if ([authenticationManager isUserAuthenticated]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        
        //if the user is logged in, lets check to make sure we have a copy of their user object
        //check to see if the profile picture is empty, if so, lets grab it from fb
        User* currentUser = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID]; 
        
        if (currentUser == nil) {
            //if the user object isnt in the database, we need to fetch it from the web service
            CloudEnumerator* userEnumerator = [[CloudEnumeratorFactory instance]enumeratorForUser:authenticationManager.m_LoggedInUserID];
            
            LOG_SECURITY(0,@"%@Downloading missing user object for user %@ from the cloud",activityName,authenticationManager.m_LoggedInUserID);
            //execute the enumerator
            [userEnumerator enumerateUntilEnd:nil];
        }
        else 
        {
            //we perform a check to update the application version if necessary
            NSString* currentAppVersion = [ApplicationSettingsManager getApplicationVersion];
            
            if ([currentUser.app_version isEqualToString:@""] ||
                ![currentUser.app_version isEqualToString:currentAppVersion] ||
                currentUser.app_version == nil)
            {
                //we need to update the User object because the versions do not match
                currentUser.app_version = currentAppVersion;
                LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Updating user's app version number from %@ to %@",activityName,currentUser.app_version,currentAppVersion);
                [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
            }
        }

    }
    
    //CloudEnumerator* pageCloudEnumerator = [[CloudEnumeratorFactory instance]enumeratorForPages];
    //[pageCloudEnumerator enumerateUntilEnd:nil];
    
    
    // Check launch options to determine if we've opened the app from a remote notification
    if ([launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]) {
        // Yes, we opened the app from the user pressing a remote notification
        // Open the production log then open to the notification log
        ProductionLogViewController* productionLogVC = [ProductionLogViewController createInstance];
        productionLogVC.shouldOpenBookCover = YES;
        productionLogVC.shouldOpenNotifications = YES;
        
        self.navigationController = [[[UINavigationController alloc]initWithRootViewController:productionLogVC] autorelease];
    }
    else {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults boolForKey:setting_HASVIEWEDLATESTPUBLISHEDPAGE]) {
            // User has already viewed the latest published page. Open to production log.
            ProductionLogViewController* productionLogVC = [ProductionLogViewController createInstance];
            productionLogVC.shouldOpenBookCover = YES;
            
            self.navigationController = [[[UINavigationController alloc]initWithRootViewController:productionLogVC] autorelease];
        }
        else {
            // Launch the BookView to the last page
            BookViewControllerBase* bookViewController = [BookViewControllerBase createInstance];
            
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults boolForKey:setting_ISFIRSTRUN] == NO) {
                //this is the first time opening, so we show a welcome message
                bookViewController.shouldOpenToLastPage = NO;
                bookViewController.shouldOpenToTitlePage = YES;
            }
            else {
                bookViewController.shouldOpenToLastPage = YES;
                bookViewController.shouldOpenToTitlePage = NO;
            }
            
            self.navigationController = [[[UINavigationController alloc]initWithRootViewController:bookViewController] autorelease];
        }
    }
    
    
//    // Launch the BookView to the last page
//    BookViewControllerBase* bookViewController = [BookViewControllerBase createInstance];
//    
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([userDefaults boolForKey:setting_ISFIRSTRUN] == NO) {
//        //this is the first time opening, so we show a welcome message
//        bookViewController.shouldOpenToLastPage = NO;
//        bookViewController.shouldOpenToTitlePage = YES;
//    }
//    else {
//        bookViewController.shouldOpenToLastPage = YES;
//        bookViewController.shouldOpenToTitlePage = NO;
//    }
//    
//    self.navigationController = [[[UINavigationController alloc]initWithRootViewController:bookViewController] autorelease];
//    
//    ProductionLogViewController* productionLogVC = [ProductionLogViewController createInstance];
//    
//    self.navigationController = [[[UINavigationController alloc]initWithRootViewController:productionLogVC] autorelease];
    
    self.window.rootViewController = self.navigationController;
    
    self.window.backgroundColor = [UIColor blackColor];
    
    [self.window makeKeyAndVisible];
    
    //check if the application is launching with notifications queued up
    //if so need to move to the notification window
    if (launchOptions != nil) {
        LOG_SECURITY(0, @"%@Application launching with remote notification queued up, moving to download screen",activityName);
       
        
        //need to instruct the feedmanager to download
        
        //need to move to the view controller
    }
    
    

    
    [ABNotifier startNotifierWithAPIKey:@"4293ede2b3ea7ae6cede2af848a57a1a" environmentName:ABNotifierDevelopmentEnvironment useSSL:NO delegate:self];
    
    
     
    return YES;
}


- (void) deleteExpiredObjectsOlderThan:(NSNumber*)daysAfterExpiry 
{
    NSString* activityName = @"PlatformAppDelegate.deleteExpiredObjectsOlderThan:";
    if ([daysAfterExpiry intValue] > 0) 
    {
        //we need to calculate the date to query expired objects by
        NSDate* now = [NSDate date];
        NSNumber* daysToAdd = [NSNumber numberWithInt:([daysAfterExpiry intValue] * -1)];
        NSDate* queryDate = [DateTimeHelper addDays:daysToAdd toDate:now];
        NSNumber* doubleQueryDate = [NSNumber numberWithDouble:[queryDate timeIntervalSince1970]];
        LOG_APPLICATIONSETTINGSMANAGER(0, @"%@ Deleting expired pages older than %@",activityName,queryDate);
        //let us now find all the objects and delete them
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSMutableArray* imageURLSToDelete = [[NSMutableArray alloc]init ];
        
        //we delete starting fromt he oldest first
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATEDRAFTEXPIRES ascending:YES];
        NSArray* expiredPagesToDelete = [resourceContext resourcesWithType:PAGE withValueLessThan:[doubleQueryDate stringValue] forAttribute:DATEDRAFTEXPIRES sortBy:[NSArray arrayWithObject:sortDescriptor]];
        
        for (Page* expiredPageToDelete in expiredPagesToDelete) 
        {
            //we only delete non published pages
            if ([expiredPageToDelete.state intValue] != kPUBLISHED) {
                LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Deleting expired page with id:%@ and displayName:%@",activityName,expiredPageToDelete.objectid,expiredPageToDelete.displayname);
                NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:YES];
                //we get all captions and photos associated with this object
                NSArray* captions = [resourceContext resourcesWithType:CAPTION withValueEqual:[expiredPageToDelete.objectid stringValue] forAttribute:PAGEID sortBy:[NSArray arrayWithObject:sortDescriptor]];
                
                NSArray* photos = [resourceContext resourcesWithType:PHOTO withValueEqual:[expiredPageToDelete.objectid stringValue] forAttribute:THEMEID sortBy:[NSArray arrayWithObject:sortDescriptor]];
                
                //now we also delete all these objects
                for (Caption* caption in captions) 
                {
                    //delete this caption
                    LOG_APPLICATIONSETTINGSMANAGER(0, @"%@ Deleting Caption %@ associated with expired Page: %@",activityName,caption.objectid,expiredPageToDelete.objectid);
                    [resourceContext delete:caption.objectid withType:caption.objecttype];
                }
                
                for (Photo* photo in photos) 
                {
                    LOG_APPLICATIONSETTINGSMANAGER(0, @"%@ Deleting Photo %@ associated with expired Page: %@",activityName,photo.objectid,expiredPageToDelete.objectid);
                    [resourceContext delete:photo.objectid withType:photo.objecttype];
                    
                    //we add the image and photo urls for this page to the delete images array
                    [imageURLSToDelete addObject:photo.imageurl];
                    [imageURLSToDelete addObject:photo.thumbnailurl];
                }
                [resourceContext delete:expiredPageToDelete.objectid withType:expiredPageToDelete.objecttype];
            }
            
        }
        //now lets clean up old images from our application cache directory
        if ([imageURLSToDelete count] > 0) 
        {
            LOG_APPLICATIONSETTINGSMANAGER(0, @"%@ removing %d old image urls from our image ache",activityName,[imageURLSToDelete count]);
            ImageManager* imageManager = [ImageManager instance];
            
            for (NSString* path in imageURLSToDelete)
            {
                [imageManager deleteImage:path];
            }
        }
        
        //now lets also clean up old feed objects as well
        NSSortDescriptor* feedSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:YES];
        NSArray* expiredFeedObjectsToDelete = [resourceContext resourcesWithType:FEED withValueLessThan:[doubleQueryDate stringValue] forAttribute:DATEEXPIRE sortBy:[NSArray arrayWithObject:feedSortDescriptor]];
        
        for (Feed* expiredFeedObjectToDelete in expiredFeedObjectsToDelete) 
        {
            LOG_APPLICATIONSETTINGSMANAGER(0, @"%@ Deleting expired feed object %d",activityName,expiredFeedObjectToDelete.objectid);
            [resourceContext delete:expiredFeedObjectToDelete.objectid withType:FEED];
        }
        [imageURLSToDelete release];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
}


- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString* activityName = @"application.didFailToRegisterForRemoteNotificationsWithError:";
    LOG_SECURITY(1, @"%@Device failed to register for notifications:%@",activityName,[error userInfo]);
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString* activityName = @"application.didRegisterForRemoteNotificationsWithDeviceToken:";
    self.deviceToken = [[[[deviceToken description]
                                       stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                                     stringByReplacingOccurrencesOfString: @" " withString: @""];
    LOG_SECURITY(0, @"%@Device token is %@",activityName,self.deviceToken);
        
}

- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    // app was already in the foreground
    
    NSString* activityName = @"application.didReceiveRemoteNotification:";
    
    //we need to instruct the feedmanager to download notification with this particular id
    FeedManager* feedManager = [FeedManager instance];
    NSNumber* feedID = [userInfo objectForKey:OBJECTID];
    
//    if ( application.applicationState == UIApplicationStateActive ) {
//        // app was already in the foreground
//        // do not move the view controller, just update all the notification feeds
//        LOG_SECURITY(0, @"%@ received new remote notifcation, proceeding to download Feed ID: %@ from the cloud",activityName,feedID);
//        [feedManager refreshFeedOnFinish:nil];
//    }
//    else {
//        // app was just brought from background to foreground
//        // move to the navigation view controller
        
    
//*** Jordan's new code ***//
    if (application.applicationState == UIApplicationStateActive) {
        // app was already in the foreground
        // do not move the view controller, just update all the notification feeds
        LOG_SECURITY(0, @"%@ received new remote notifcation, proceeding to download Feed ID: %@ from the cloud",activityName,feedID);
        [feedManager refreshFeedOnFinish:nil];
    }
    else {
        // app was just brought from background to foreground
        // move to the navigation view controller
        // check first to see if the active view controller is the log
        UIViewController* topViewController = [self.navigationController topViewController];
        
        if ([topViewController isKindOfClass:ProductionLogViewController.class]) {
            //the top view controller is already the production log
            //we instruict the feed manager to enumerate and return result to the notification view controller
            ProductionLogViewController* prodLogVC = (ProductionLogViewController*)topViewController;
            
            // Open the notification log
            [prodLogVC onNotificationsButtonClicked:nil];
            
        }
        else if ([topViewController isKindOfClass:NotificationsViewController.class]) {
            //the top view controller is already the notification feed
            //we instruict the feed manager to enumerate and return result to the notification view controller
            NotificationsViewController* nvc = (NotificationsViewController*)topViewController;
            Callback* callback = [Callback callbackForTarget:nvc selector:@selector(onFeedFinishedRefresh:) fireOnMainThread:YES];
            LOG_SECURITY(0,@"%@ received new remote notification, querying for feeds",activityName);
            [feedManager refreshFeedOnFinish:callback];
            
        }
        else if ([topViewController isKindOfClass:ContributeViewController.class]) {
            // app is in the contribute view controller
            // do not move the notification view controller, just update all the notification feeds
            LOG_SECURITY(0, @"%@ received new remote notifcation, proceeding to download Feed ID: %@ from the cloud",activityName,feedID);
            [feedManager refreshFeedOnFinish:nil];
        }
        else {
            // We need to first load the productionLogVC as the root, and set the flag to notify that it should open the notification view immidiately
            ProductionLogViewController* productionLogVC = [ProductionLogViewController createInstance];
            productionLogVC.shouldOpenBookCover = YES;
            productionLogVC.shouldOpenNotifications = YES;
            
//            self.navigationController = [[[UINavigationController alloc]initWithRootViewController:productionLogVC] autorelease];
            [self.navigationController setViewControllers:[NSArray arrayWithObject:productionLogVC] animated:NO];
        }
    }
//*** Jordan's new code ***//
        
//        //check first to see if the active view controller is the log
//        UIViewController* topViewController = [self.navigationController topViewController];
//        if ([topViewController isKindOfClass:NotificationsViewController.class]) {
//            //the top view controller is already the notification feed
//            //we instruict the feed manager to enumerate and return result to the notification view controller
//            NotificationsViewController* nvc = (NotificationsViewController*)topViewController;
//            Callback* callback = [Callback callbackForTarget:nvc selector:@selector(onFeedFinishedRefresh:) fireOnMainThread:YES];
//            LOG_SECURITY(0,@"%@ received new remote notification, querying for feeds",activityName);
//            [feedManager refreshFeedOnFinish:callback];
//        
//        }
//        else if ([topViewController isKindOfClass:BookViewControllerLeaves.class]) 
//        {
//            //the book view controller is open
//            BookViewControllerLeaves* leaves = (BookViewControllerLeaves*)topViewController;
//            
//            if ([leaves.modalViewController isKindOfClass:UINavigationController.class]) 
//            {
//                
//                UINavigationController* navigationController = (UINavigationController*)leaves.modalViewController;
//                topViewController = navigationController.topViewController;
//                
//                if ([topViewController isKindOfClass:NotificationsViewController.class])
//                {
//                    //the book view is showing the notification window
//                    NotificationsViewController* nvc = (NotificationsViewController*)leaves.modalViewController;
//                    Callback* callback = [Callback callbackForTarget:nvc selector:@selector(onFeedFinishedRefresh:) fireOnMainThread:YES];
//                    LOG_SECURITY(0,@"%@ received new remote notification, querying for feeds",activityName);
//                    [feedManager refreshFeedOnFinish:callback];
//                }
//                else 
//                {
//                    //its on a different view controller
//                    NotificationsViewController*  nvc = [NotificationsViewController createInstanceAndRefreshFeedOnAppear];
//                    [navigationController pushViewController:nvc animated:YES];
//                    
//
//                }
//            }
//            else 
//            {
//                //its on a different view controller , then we need to push the notification view controller on it
//                
//                [leaves showNotificationViewController];
//            }
//        }
//        else {
//             LOG_SECURITY(0,@"%@ received new remote notification, pushing NotificationsViewController",activityName);
//            NotificationsViewController*  nvc = [NotificationsViewController createInstanceAndRefreshFeedOnAppear];
//            [self.navigationController pushViewController:nvc animated:YES];
//            
//        }
//        
//        
//    }
    
    //on complete we should adjust the badge number to reflect the current nmber of unseen notification in the database
}

- (void)onFeedFinishedRefreshing:(CallbackResult*)result {
    
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
    
    
    void (^block)(NSNumber*) = ^(NSNumber* number) {
        [self deleteExpiredObjectsOlderThan:number];
    };
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    NSNumber* localThreshold = [[NSNumber alloc]initWithInt:[settings.delete_objects_after intValue]];
    
   // NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc]init];
    dispatch_async(backgroundQueue, ^{block(localThreshold);});
    
    
        
    
//    [self performSelectorInBackground:@selector(deleteExpiredObjectsOlderThan:) withObject:settings.delete_expired_objects];
 //   [autorelease drain];
  //  [localThreshold release];
    //[self deleteExpiredObjectsOlderThan:settings.delete_expired_objects];
    
    EventManager* eventManager = [EventManager instance];
    [eventManager raiseApplicationWentToBackground];
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
    
    //we need to raise the event
    EventManager *eventManager = [EventManager instance];
    [eventManager raiseApplicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
        
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    //[__progressView release];
    [__resourceContext release];
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    
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

#pragma mark - Resource Context
- (ResourceContext*) resourceContext {
    return [ResourceContext instance];
}
#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
   NSString* activityName = @"PlatformAppDelegate.managedObjectContext:";
    
    if (__managedObjectContext != nil)
    {
       // LOG_SECURITY(0,@"%@Returning context at %p to thread, IsMainThread?: %d",activityName,__managedObjectContext,[thread isMainThread]);
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
                
        NSUndoManager* contextUndoManager = [[NSUndoManager alloc]init];
        [contextUndoManager setLevelsOfUndo:20];
        __managedObjectContext.undoManager = contextUndoManager;
        [contextUndoManager release];
       // [__managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    else
    {
        LOG_RESOURCECONTEXT(1, @"%@No persistent coordinator found",activityName);    
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PlatformDataModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Platform.sqlite"];
    
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

@end
