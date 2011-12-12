//
//  RegisteredEventHandler.m
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "RegisteredEventHandler.h"


@implementation RegisteredEventHandler
@synthesize eventID = m_eventID;
@synthesize callback = m_callback;

+ (RegisteredEventHandler*) registeredEventHandlerFor:(Callback *)callback withEventType:(int)systemEventType {
    RegisteredEventHandler* retVal = [[RegisteredEventHandler alloc]init];
    retVal.callback = callback;
    retVal.eventID = systemEventType;
    [retVal autorelease];
    return retVal;
}
@end
