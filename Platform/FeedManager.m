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
#import "EventManager.h"
#import "ResourceContext.h"
#import "PlatformAppDelegate.h"
#import "Macros.h"
@implementation FeedManager
@synthesize frc_feed_captionvotes               = __frc_feed_captionvotes;
@synthesize frc_feed_photovotes                 = __frc_feed_photovotes;
@synthesize frc_feed_captions                   = __frc_feed_captions;
@synthesize numberOfNewPhotoVotesInFeed         = __numberOfNewPhotoVotesInFeed;
@synthesize numberOfNewCaptionVotesInFeed       = __numberOfNewCaptionVotesInFeed;
@synthesize feedEnumerator                      = __feedEnumerator;
@synthesize numberOfNewCaptionsInFeed           = __numberOfNewCaptionsInFeed;

static FeedManager* sharedManager;

+ (FeedManager*) instance {
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
    
    AuthenticationManager* authNManager = [AuthenticationManager instance];
    if ([authNManager contextForLoggedInUser] != nil) {
     
        NSNumber* loggedInUserID = [authNManager m_LoggedInUserID];
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
    NSString* activityName = @"FeedManager.frc_feed_captions";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]==NO) {
        __frc_feed_captions = nil;
        return nil;
    }
    
    if (__frc_feed_captions != nil) {
        return __frc_feed_captions;
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:FEED inManagedObjectContext:appContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_CAPTION_ADDED],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:RESOURCEID ascending:NO];
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
        LOG_FEED(1,@"%@Could not create fetched results controller due to %@",activityName,[error userInfo]);
	   
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_captions;

    
    
}

- (NSFetchedResultsController*)frc_feed_captionvotes {
    NSString* activityName = @"FeedManager.frc_feed_captionvotes";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]==NO) {
        __frc_feed_captionvotes = nil;
        return nil;
    }
    
    if (__frc_feed_captionvotes != nil) {
        return __frc_feed_captionvotes;
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext; 
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:FEED inManagedObjectContext:appContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_CAPTION_VOTE],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:RESOURCEID ascending:NO];
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
        
	    LOG_FEED(1,@"%@Could not create fetched results controller due to %@",activityName,[error userInfo]);
    }
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_captionvotes;
    
}

- (NSFetchedResultsController*)frc_feed_photovotes {
    NSString* activityName = @"FeedManager.frc_feed_photovotes";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]==NO) {
        __frc_feed_photovotes = nil;
        return nil;
    }
    
    if (__frc_feed_photovotes != nil) {
        return __frc_feed_photovotes;
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:FEED inManagedObjectContext:appContext];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_PHOTO_VOTE],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:RESOURCEID ascending:NO];
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
        
	    LOG_FEED(1,@"%@Could not create fetched results controller due to %@",activityName,[error userInfo]);	
    }
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_photovotes;
    
}

#pragma mark - Instance methods
- (void) refreshFeed  {
        
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
    EventManager* eventManager = [EventManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:RESOURCEID];
    [eventManager raiseNewCaptionVoteEvent:userInfo];
}

- (void) raiseSystemEventForNewPhotoVote:(Feed*)feed {
    EventManager* eventManager = [EventManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:RESOURCEID];
    [eventManager raiseNewPhotoVoteEvent:userInfo];
}

- (void) raiseSystemEventForCaption:(Feed*)feed {
     EventManager* eventManager = [EventManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:RESOURCEID];
    [eventManager raiseNewCaptionEvent:userInfo];
    
}

- (void) raiseSystemEventForFeedItemRead:(Feed*)feed {
    EventManager* eventManager = [EventManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:feed.objectid forKey:RESOURCEID];
    [eventManager raiseFeedItemReadEvent:userInfo];
  
}

#pragma mark - CloudCallbackDelegate
- (void) onEnumerateComplete {
    //called when an refresh for the feed has completed
    //raise a system event for feed refresh complete
    EventManager* eventManager = [EventManager instance];
    [eventManager raiseFeedRefreshedEvent:nil];
  
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
