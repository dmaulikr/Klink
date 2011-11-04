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
    if ([authNManager isUserAuthenticated]) {
     
        NSNumber* loggedInUserID = [authNManager m_LoggedInUserID];
        __feedEnumerator = [[[CloudEnumeratorFactory instance] enumeratorForFeeds:loggedInUserID]retain];        
        __feedEnumerator.delegate = self;
        
    }
    
    return __feedEnumerator;
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



#pragma mark - CloudCallbackDelegate
- (void) onEnumerateComplete {
    //called when an refresh for the feed has completed
    //raise a system event for feed refresh complete

  
}


@end
