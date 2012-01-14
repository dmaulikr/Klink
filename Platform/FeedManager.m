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
#import "CloudEnumerator.h"
#import "CloudEnumeratorFactory.h"

@implementation FeedManager
@synthesize feedEnumerator = __feedEnumerator;
@synthesize onRefreshCallback = m_onRefreshCallback;

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
     [__feedEnumerator release];
    
    [super dealloc];
   
}


#pragma mark - Properties

- (CloudEnumerator*) feedEnumerator {
    if (__feedEnumerator != nil) {
        return __feedEnumerator;
    }
    
    AuthenticationManager* authNManager = [AuthenticationManager instance];
    if ([authNManager isUserAuthenticated]) {
     
        NSNumber* loggedInUserID = [authNManager m_LoggedInUserID];
        __feedEnumerator = [[CloudEnumerator enumeratorForFeeds:loggedInUserID]retain];
             
        __feedEnumerator.delegate = self;
        
    }
    
    return __feedEnumerator;
}

#pragma mark - Instance methods
- (BOOL) tryRefreshFeedOnFinish:(Callback*) callback 
{
    NSString* activityName = @"FeedManager.tryRefreshFeedOnFinish:";
    
    //this method makes a 'smart' attempt at refreshing the feed, only doing so
    //if the enumerator settings permit it too, to avoid to many calls ont he wire
    //optionally if there is no draft query being executed, and we are authenticated, then we then refresh the notification feed
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    FeedManager* feedManager = [FeedManager instance];
    if ([authenticationManager isUserAuthenticated] == YES &&
        [feedManager.feedEnumerator canEnumerate])
    {
       
        LOG_FEEDMANAGER(0, @"%@Refreshing user's feed from cloud",activityName);
        [feedManager refreshFeedOnFinish:callback];
        return YES;
    }
    else 
    {
        LOG_FEEDMANAGER(0, @"%@Skipping user feed refresh, enumerator not ready",activityName);
        return NO;
    }

}
- (void) refreshFeedOnFinish:(Callback *)callback  {
    NSString* activityName = @"FeedManager.refreshFeedOnFinish:";
    //we nil out the current feed enumerator so we are able to create a new instance
    //which will query from the start of the feed again
    self.feedEnumerator = nil;
    
    self.onRefreshCallback = callback;
    
    //enumerate feed until the end
    LOG_FEEDMANAGER(0, @"%@Beginning to enumerate entire contents of user's feed",activityName);
      
   [self.feedEnumerator enumerateUntilEnd:nil];
    
    
}


- (BOOL) isRefreshingFeed {
    if (self.feedEnumerator != nil) {
        return self.feedEnumerator.isLoading;
    }
    else {
        return NO;
    }
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



#pragma mark - CloudCallbackDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    NSString* activityName = @"FeedManager.onEnumerateComplete:";
    //called when an refresh for the feed has completed
    //raise a system event for feed refresh complete
    LOG_FEEDMANAGER(0,@"%@Finished enumerating user's notification feed",activityName);
    if (self.onRefreshCallback != nil) {
        [self.onRefreshCallback fire];
    }
  
}


@end
