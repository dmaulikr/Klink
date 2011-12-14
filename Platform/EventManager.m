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
#import "Photo.h"
#import "Page.h"
#import "Caption.h"


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
        NSMutableSet* set = [[NSMutableSet alloc]init];
        self.registeredHandlers = set;
        [set release];
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
   // NSString* activityName = @"EventManager.registerCallback:";
    if (![self isAlreadyRegistered:callback forSystemEvent:systemEventType]) {
        //register the callback
        [self.registeredHandlers addObject:[RegisteredEventHandler registeredEventHandlerFor:callback withEventType:systemEventType]];
     //   LOG_EVENTMANAGER(0, @"%@registered callback for system event %d",activityName,systemEventType);
    }
    
    
}



- (void) registerCallbackForAllSystemEvents:(Callback *)callback {
    [self registerCallback:callback forSystemEvent:kUSERLOGGEDIN];
    [self registerCallback:callback forSystemEvent:kUSERLOGGEDOUT];
    [self registerCallback:callback forSystemEvent:kUSERLOGINFAILED];
    [self registerCallback:callback forSystemEvent:kNEWCAPTIONVOTE];
    [self registerCallback:callback forSystemEvent:kNEWPHOTOVOTE];
    [self registerCallback:callback forSystemEvent:kNEWCAPTION];
    [self registerCallback:callback forSystemEvent:kNEWPHOTO];
    [self registerCallback:callback forSystemEvent:kNEWPAGE];
    //[self registerCallback:callback forSystemEvent:kINSERTEDOBJECTS];
    //[self registerCallback:callback forSystemEvent:kUPDATEDOBJECTS];
    //[self registerCallback:callback forSystemEvent:kDELETEDOBJECTS];    
    [self registerCallback:callback forSystemEvent:kSHOWPROGRESS];
    [self registerCallback:callback forSystemEvent:kHIDEPROGRESS];
    [self registerCallback:callback forSystemEvent:kAUTHENTICATIONFAILED];
    [self registerCallback:callback forSystemEvent:kUNKNOWNREQUESTFAILURE];
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

- (void) raiseAuthenticationFailedEvent:(NSDictionary *)userInfo {
    [self raiseEvent:kAUTHENTICATIONFAILED withUserInfo:userInfo];
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
- (void) raiseUnknownRequestFailureEvent {
    [self raiseEvent:kUNKNOWNREQUESTFAILURE withUserInfo:nil];
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
- (void) raiseNewPhotoEvent       :(NSDictionary*)userInfo {
    [self raiseEvent:kNEWPHOTO withUserInfo:userInfo];
}
- (void) raiseNewPageEvent: (NSDictionary*)userInfo {
    [self raiseEvent:kNEWPAGE withUserInfo:userInfo];
}

- (void) raiseShowProgressViewEvent:(NSString *)message withCustomView:(UIView *)view withMaximumDisplayTime:(NSNumber *)maximumTimeInSeconds {
  
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:message forKey:kMessage];
    [userInfo setValue:view forKey:kCustomView];
    [userInfo setValue:maximumTimeInSeconds forKey:kMaximumTimeInSeconds];
    [self raiseEvent:kSHOWPROGRESS withUserInfo:userInfo];
    [userInfo release];
}

- (void) raiseHideProgressViewEvent {
    [self raiseEvent:kHIDEPROGRESS withUserInfo:nil];
}

#define kCAPTION    @"caption"
#define kPHOTO      @"photo"
#define kPAGE       @"page"

- (void) raiseEventsForInsertedObjects:(NSSet*)insertedObjects {
     //will iterate through each newly inserted object and raise events corresponding to them
    NSString* activityName = @"EventManager.raiseEventsForInsertObject:";
    NSArray* insertedArray = [insertedObjects allObjects];
    NSDictionary* userInfo = nil;
    
    for (NSManagedObject* obj in insertedArray) {
        //we test for caption,photo, etc...
        
        if ([obj isKindOfClass:[Caption class]]) {
            //it is a caption object
            LOG_EVENTMANAGER(0, @"%@raising new caption event for new caption",activityName);
            userInfo = [NSDictionary dictionaryWithObject:obj forKey:kCAPTION];
            [self raiseNewCaptionEvent:userInfo];
        }
        else if ([obj isKindOfClass:[Photo class]]) {
            //it is a photo object
            LOG_EVENTMANAGER(0, @"%@raising new photo event for new photo",activityName);

            userInfo = [NSDictionary dictionaryWithObject:obj forKey:kPHOTO];
            [self raiseNewPhotoEvent:userInfo];

        }
        else if ([obj isKindOfClass:[Page class]]) {
            //it is a page object.
            LOG_EVENTMANAGER(0, @"%@raising new page event for new page",activityName);

            userInfo = [NSDictionary dictionaryWithObject:obj forKey:kPAGE];
            [self raiseNewPageEvent:userInfo];

        }
    }
    //[self raiseEvent:kINSERTEDOBJECTS withUserInfo:userInfo];
}

- (void) raiseEventsForUpdatedObjects:(NSSet*)updatedObjects {
    //iterates through updated objects and raises any pertinent application notifications
    NSString* activityName = @"EventManager.raiseEventsForInsertObject:";
    NSArray* insertedArray = [updatedObjects allObjects];
    NSDictionary* userInfo = nil;
    
    for (NSManagedObject* obj in insertedArray) {
        
        if ([obj isKindOfClass:[Caption class]]) {
            //it is a caption object
            NSDictionary* changedAttributes = [obj changedValues];
            if ([changedAttributes valueForKey:NUMBEROFVOTES] != nil) {
                //number of votes has been changed
                Caption* caption = (Caption*)obj;
                LOG_EVENTMANAGER(0, @"%@raising new caption vote event for caption %@",activityName,caption.objectid);
                
                userInfo = [NSDictionary dictionaryWithObject:obj forKey:kCAPTION];
                [self raiseNewCaptionVoteEvent:userInfo];
            }            
        }
        else if ([obj isKindOfClass:[Photo class]]) {
            //it is a photo object
            NSDictionary* changedAttributes = [obj changedValues];
            if ([changedAttributes valueForKey:NUMBEROFVOTES] != nil) {
                //number of votes has been changed
                Photo* photo = (Photo*)obj;
                LOG_EVENTMANAGER(0, @"%@raising new photo vote event for photo %@",activityName,photo.objectid);
                
                userInfo = [NSDictionary dictionaryWithObject:obj forKey:kPHOTO];
                [self raiseNewPhotoVoteEvent:userInfo];
            } 
        }
    }
    //[self raiseEvent:kUPDATEDOBJECTS withUserInfo:userInfo];
}

- (void) raiseEventsForDeletedObjects:(NSSet*)deletedObjects {
    
}
@end
