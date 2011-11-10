//
//  EventManager.h
//  Platform
//
//  Created by Bobby Gill on 10/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kUSERLOGGEDIN,
    kUSERLOGGEDOUT,
    kUSERLOGINFAILED,
    kNEWCAPTIONVOTE,
    kNEWPHOTOVOTE,
    kNEWCAPTION,
    kDRAFTFINISHED,
    kDRAFTPUBLISHED,
    kSHOWPROGRESS,
    kHIDEPROGRESS
} SystemEvent;

@interface EventManager : NSObject {
    NSMutableSet* m_registeredHandlers;
}

@property (nonatomic,retain) NSMutableSet* registeredHandlers;

- (void) registerCallback:(Callback*)callback forSystemEvent:(SystemEvent)systemEventType;
- (void) registerCallbackForAllSystemEvents:(Callback*)callback;
- (void) raiseEvent:(SystemEvent)systemEventType withUserInfo:(NSDictionary*)userInfo;


- (void) raiseUserLoggedInEvent     :(NSDictionary*)userInfo;
- (void) raiseUserLoggedOutEvent    :(NSDictionary*)userInfo;
- (void) raiseUserLoginFailedEvent  :(NSDictionary*)userInfo;
- (void) raiseNewCaptionVoteEvent   :(NSDictionary*)userInfo;
- (void) raiseNewPhotoVoteEvent     :(NSDictionary*)userInfo;
- (void) raiseNewCaptionEvent       :(NSDictionary*)userInfo;
- (void) raiseShowProgressViewEvent :(NSString*)message 
                      withCustomView:(UIView*)view 
              withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds;
- (void) raiseHideProgressViewEvent;
+ (EventManager*)instance;
@end
