//
//  EventManager.h
//  Platform
//
//  Created by Bobby Gill on 10/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventManager : NSObject {
    
}


- (void) raiseUserLoggedInEvent:(NSDictionary*)userInfo;
- (void) raiseUserLoggedOutEvent: (NSDictionary*)userInfo;
- (void) raiseUserLoginFailedEvent:(NSDictionary*)userInfo;
+ (EventManager*)instance;
@end
