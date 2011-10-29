//
//  EventManager.m
//  Platform
//
//  Created by Bobby Gill on 10/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EventManager.h"


@implementation EventManager
static EventManager* sharedInstance;

+ (EventManager*) instance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[EventManager allocWithZone:NULL]init
                              ];
        }
        return sharedInstance;
    }
}

- (void) raiseUserLoggedInEvent:(NSDictionary*)userInfo {
    //TODO: implement system eventing mechanism
}


- (void) raiseUserLoggedOutEvent:(NSDictionary*)userInfo {
    //TODO: implement system log off eventing mechanism
}

- (void) raiseUserLoginFailedEvent:(NSDictionary*)userInfo {
    
}

- (void) raiseNewCaptionVoteEvent   :(NSDictionary*)userInfo {
    
}
- (void) raiseNewPhotoVoteEvent     :(NSDictionary*)userInfo {
    
}
- (void) raiseNewCaptionEvent       :(NSDictionary*)userInfo {
    
}
- (void) raiseFeedItemReadEvent     :(NSDictionary*)userInfo {
    
}

- (void) raiseFeedRefreshedEvent:(NSDictionary *)userInfo {
    
}
@end
