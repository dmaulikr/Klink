//
//  Event.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Callback.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "CallbackResult.h"
#import "Attributes.h"

@implementation Callback
@synthesize context = m_context;
@synthesize target = m_target;
- (id) initWithTarget:(id)target withSelector:(SEL)selector withContext:(id)context {
    self = [super init];
    if (self) {
        m_target = [target retain];
        m_selector = selector;
       
        m_context = [context retain];
        
    }
    return self;
}
- (id) initWithTarget:(id)target withSelector:(SEL)selector {
    return [self initWithTarget:target withSelector:selector withContext:nil];
}

- (void) fireWithResult:(CallbackResult*)callbackResult {
    if (m_target != nil &&
        [m_target respondsToSelector:m_selector]) {
        [m_target performSelectorInBackground:m_selector withObject:callbackResult];
    }
}

- (void) fire {
    
    CallbackResult* callbackResult = [CallbackResult resultForCallback:self];
    [self fireWithResult:callbackResult];
    
    
}

- (void) fireWithResponse:(Response*)response {
    CallbackResult* callbackResult = [CallbackResult resultForCallback:self];
    callbackResult.response = response;
    [self fireWithResult:callbackResult];
    
}

- (void) fireWithUserInfo:(NSDictionary*)userInfo {
    CallbackResult* callbackResult = [CallbackResult resultForCallback:self];
    callbackResult.response = userInfo;
    [self fireWithResult:callbackResult];
}

@end
