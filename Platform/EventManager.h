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
    kNEWPHOTO,
    kNEWPAGE,
    //kINSERTEDOBJECTS,
    //kUPDATEDOBJECTS,
    //kDELETEDOBJECTS,
    kDRAFTFINISHED,
    kDRAFTPUBLISHED,
    kSHOWPROGRESS,
    kHIDEPROGRESS,
    kAUTHENTICATIONFAILED,
    kUNKNOWNREQUESTFAILURE
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
- (void) raiseAuthenticationFailedEvent:(NSDictionary*)userInfo;
- (void) raiseUnknownRequestFailureEvent;

- (void) raiseNewCaptionVoteEvent   :(NSDictionary*)userInfo;
- (void) raiseNewPhotoVoteEvent     :(NSDictionary*)userInfo;
- (void) raiseNewPhotoEvent         :(NSDictionary*)userInfo;
- (void) raiseNewCaptionEvent       :(NSDictionary*)userInfo;
- (void) raiseNewPageEvent          :(NSDictionary*)userInfo;

- (void) raiseShowProgressViewEvent :(NSString*)message 
                      withCustomView:(UIView*)view 
              withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds;
- (void) raiseHideProgressViewEvent;

- (void) raiseEventsForInsertedObjects:(NSSet*)insertedObjects;
- (void) raiseEventsForUpdatedObjects:(NSSet*)updatedObjects;
- (void) raiseEventsForDeletedObjects:(NSSet*)deletedObjects;

+ (EventManager*)instance;
@end
