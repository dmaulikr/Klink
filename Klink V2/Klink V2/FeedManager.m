//
//  FeedManager.m
//  Klink V2
//
//  Created by Bobby Gill on 9/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FeedManager.h"
#import "AuthenticationManager.h"
#import "ApplicationSettings.h"
#import "FeedTypes.h"
#import "Feed.h"
#import "NotificationNames.h"

@implementation FeedManager
@synthesize frc_feed_captionvotes               = __frc_feed_captionvotes;
@synthesize frc_feed_photovotes                 = __frc_feed_photovotes;
@synthesize frc_feed_captions                   = __frc_feed_captions;
@synthesize numberOfNewPhotoVotesInFeed         = __numberOfNewPhotoVotesInFeed;
@synthesize numberOfNewCaptionVotesInFeed       = __numberOfNewCaptionVotesInFeed;
@synthesize feedEnumerator                      = __feedEnumerator;
@synthesize numberOfNewCaptionsInFeed           = __numberOfNewCaptionsInFeed;

static FeedManager* sharedManager;

+ (FeedManager*) getInstance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[FeedManager alloc]init];
        }
        return sharedManager;
    }

}

- (void) dealloc {
    [super dealloc];
    [__feedEnumerator release];
}


#pragma mark - Properties

- (CloudEnumerator*) feedEnumerator {
    if (__feedEnumerator != nil) {
        return __feedEnumerator;
    }
    
    AuthenticationManager* authNManager = [AuthenticationManager getInstance];
    if ([authNManager getAuthenticationContext] != nil) {
     
        NSNumber* loggedInUserID = [authNManager getLoggedInUserID];
        __feedEnumerator = [[CloudEnumerator enumeratorForFeeds:loggedInUserID]retain];
        __feedEnumerator.delegate = self;
        
    }
    
    return __feedEnumerator;
}
- (NSNumber*) numberOfNewCaptionsInFeed {
    if (self.frc_feed_captions != nil) {
        return [NSNumber numberWithInt:[[self.frc_feed_captions fetchedObjects]count]];
    }
    else {
        return [NSNumber numberWithInt:0];
    }
}

- (NSNumber*) numberOfNewPhotoVotesInFeed {
    if (self.frc_feed_photovotes != nil) {
        return [NSNumber numberWithInt:[[self.frc_feed_photovotes fetchedObjects]count]];
    }
    else {
        return [NSNumber numberWithInt:0];
    }
}

- (NSNumber*) numberOfNewCaptionVotesInFeed {
    if (self.frc_feed_captionvotes != nil) {
        return [NSNumber numberWithInt:[[self.frc_feed_captionvotes fetchedObjects]count]];
    }
    else {
        return [NSNumber numberWithInt:0];
    }
}

- (NSFetchedResultsController*)frc_feed_captions {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_feed_captions = nil;
        return nil;
    }
    
    if (__frc_feed_captions != nil) {
        return __frc_feed_captions;
    }
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND user_hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_CAPTION_ADDED],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feed_captions = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_captions;

    
    
}

- (NSFetchedResultsController*)frc_feed_captionvotes {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_feed_captionvotes = nil;
        return nil;
    }
    
    if (__frc_feed_captionvotes != nil) {
        return __frc_feed_captionvotes;
    }
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND user_hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_CAPTION_VOTE],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feed_captionvotes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_captionvotes;
    
}

- (NSFetchedResultsController*)frc_feed_photovotes {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_feed_photovotes = nil;
        return nil;
    }
    
    if (__frc_feed_photovotes != nil) {
        return __frc_feed_photovotes;
    }
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND user_hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_PHOTO_VOTE],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feed_photovotes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_photovotes;
    
}

#pragma mark - Instance methods
- (void) refreshFeed  {
    NSString* activityName = @"FeedManager.updateFeed:";
    
    //we nil out the current feed enumerator so we are able to create a new instance
    //which will query from the start of the feed again
    self.feedEnumerator = nil;
    
    //enumerate feed until the end
    [self.feedEnumerator enumerateUntilEnd];
    
    
}

- (BOOL) isRefreshingFeed {
    return self.feedEnumerator.isLoading;
}

#pragma mark - Initializers
- (id) init {
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

#pragma mark - System Event raisers
- (void) raiseSystemEventForNewCaptionVote:(Feed*)feed {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:an_OBJECTID];
    [notificationCenter postNotificationName:n_NEW_FEED_CAPTION_VOTE object:self userInfo:userInfo];
}

- (void) raiseSystemEventForNewPhotoVote:(Feed*)feed {
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:an_OBJECTID];
    [notificationCenter postNotificationName:n_NEW_FEED_PHOTO_VOTE object:self userInfo:userInfo];
}

- (void) raiseSystemEventForCaption:(Feed*)feed {
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:an_OBJECTID];
    [notificationCenter postNotificationName:n_NEW_FEED_CAPTION object:self userInfo:userInfo];

}

- (void) raiseSystemEventForFeedItemRead:(Feed*)feed {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:an_OBJECTID];
    [notificationCenter postNotificationName:n_FEED_ITEM_CLEARED object:self userInfo:userInfo];
}

#pragma mark - CloudCallbackDelegate
- (void) onEnumerateComplete {
    //called when an refresh for the feed has completed
    //raise a system event for feed refresh complete
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:n_FEED_REFRESHED object:self userInfo:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    if (controller == self.frc_feed_captionvotes) {
        if (type == NSFetchedResultsChangeInsert) {
            Feed* feed = (Feed*)anObject;
            //raise a new system event for the feed object being created
            [self raiseSystemEventForNewCaptionVote:feed];
        }
    }
    else if (controller == self.frc_feed_photovotes) {
        if (type == NSFetchedResultsChangeInsert) {
            //raise a new system event for the feed object being created
            Feed* feed = (Feed*)anObject;
            [self raiseSystemEventForNewPhotoVote:feed];
         
        }
    }
    else if (controller == self.frc_feed_captions) {
        if (type == NSFetchedResultsChangeInsert) {
            //raise a new system event for the feed object being created
            Feed* feed = (Feed*)anObject;
            [self raiseSystemEventForCaption:feed];

        }
    
    }
    
    if (type == NSFetchedResultsChangeDelete) {
        //feed item has been read
        Feed* feed = (Feed*)anObject;
    
        [self raiseSystemEventForFeedItemRead:feed];
    }

    
    
    
}
@end
