//
//  RegisteredEventHandler.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callback.h"

@interface RegisteredEventHandler : NSObject {
    int         m_eventID;
    Callback*   m_callback;
}

@property (nonatomic,retain) Callback*  callback;
@property                    int        eventID;


//static initializers
+ (RegisteredEventHandler*)  registeredEventHandlerFor:(Callback*)callback withEventType:(int)systemEventType;
@end
