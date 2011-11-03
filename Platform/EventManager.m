//
//  EventManager.m
//  Platform
//
//  Created by Bobby Gill on 10/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EventManager.h"
#import "RegisteredEventHandler.h"
#import "Callback.h"
#import "Macros.h"

@implementation EventManager
@synthesize registeredHandlers = m_registeredHandlers;

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

- (NSArray*) sortedHandlers {
    NSSortDescriptor* sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"eventID" ascending:NO];
    NSArray* retVal = [self.registeredHandlers sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescription]];
    return retVal;
}

- (id) init {
    self = [super init];
    if (self) {
        self.registeredHandlers = [[NSMutableSet alloc]init];
    }
    return self;
}

- (BOOL) isAlreadyRegistered:(Callback*)callback forSystemEvent:(int)systemEventType {
    BOOL retVal = NO;
    NSArray* handlersList = [self sortedHandlers];

    for (RegisteredEventHandler* handler in handlersList) {
        if (handler.eventID == systemEventType && handler.callback == callback) {
            return YES;
        }
        
        if (handler.eventID < systemEventType) {
            break;
        }
    }
    return retVal;
}

- (void) registerCallback:(Callback*)callback forSystemEvent:(SystemEvent)systemEventType {
    NSString* activityName = @"EventManager.registerCallback:";
    if (![self isAlreadyRegistered:callback forSystemEvent:systemEventType]) {
        //register the callback
        [self.registeredHandlers addObject:[RegisteredEventHandler registeredEventHandlerFor:callback withEventType:systemEventType]];
        LOG_EVENTMANAGER(0, @"%@registered callback for system event %d",activityName,systemEventType);
    }
    
    
}

- (void) registerCallbackForAllSystemEvents:(Callback *)callback {
    [self registerCallback:callback forSystemEvent:kUSERLOGGEDIN];
    [self registerCallback:callback forSystemEvent:kUSERLOGGEDOUT];
    [self registerCallback:callback forSystemEvent:kUSERLOGINFAILED];
    [self registerCallback:callback forSystemEvent:kNEWCAPTIONVOTE];
    [self registerCallback:callback forSystemEvent:kNEWPHOTOVOTE];
    [self registerCallback:callback forSystemEvent:kNEWCAPTION];
}

- (NSArray*)registeredHandlersForEventType:(int)systemEventType {
    NSMutableArray* retVal = [[[NSMutableArray alloc]init ]autorelease];
    NSArray* handlers = [self sortedHandlers];
    
    for (RegisteredEventHandler* handler in handlers) {
        if (handler.eventID == systemEventType) {
            [retVal addObject:handler];
        }
    }
    return retVal;
}

- (void) raiseEvent:(SystemEvent)systemEventType withUserInfo:(NSDictionary*)userInfo {
    NSString* activityName = @"EventManager.raiseEvent:";
    NSArray* handlers = [self registeredHandlersForEventType:systemEventType];
    NSMutableSet* handlersToRemove = [[NSMutableSet alloc]init];
    
    LOG_EVENTMANAGER(0, @"%@Raising system event %d for all registered handlers",activityName,systemEventType);
    for (RegisteredEventHandler* handler in handlers) {
        if (handler.callback != nil) {
            id target = handler.callback.target;
            if (target != nil) {
                
                [handler.callback fireWithUserInfo:userInfo];
            }
            else {
                [handlersToRemove addObject:handler];
            }
        }
        else {
            //de-register the handler
            [handlersToRemove addObject:handler];
        }
    }
    
    [self.registeredHandlers minusSet:handlersToRemove];
    [handlersToRemove release];
}
- (void) raiseUserLoggedInEvent:(NSDictionary*)userInfo {
    [self raiseEvent:kUSERLOGGEDIN withUserInfo:userInfo];
}


- (void) raiseUserLoggedOutEvent:(NSDictionary*)userInfo {
    [self raiseEvent:kUSERLOGGEDOUT withUserInfo:userInfo];
}

- (void) raiseUserLoginFailedEvent:(NSDictionary*)userInfo {
    [self raiseEvent:kUSERLOGINFAILED withUserInfo:userInfo];  
}

- (void) raiseNewCaptionVoteEvent   :(NSDictionary*)userInfo {
    [self raiseEvent:kNEWCAPTIONVOTE withUserInfo:userInfo];
}
- (void) raiseNewPhotoVoteEvent     :(NSDictionary*)userInfo {
     [self raiseEvent:kNEWPHOTOVOTE withUserInfo:userInfo];
}
- (void) raiseNewCaptionEvent       :(NSDictionary*)userInfo {
     [self raiseEvent:kNEWCAPTION withUserInfo:userInfo];
}

@end
