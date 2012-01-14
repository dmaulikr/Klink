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
@synthesize fireOnMainThread = m_fireOnMainThread;

- (id) initWithTarget:(id)target withSelector:(SEL)selector withContext:(id)context {
    self = [super init];
    if (self) {
        m_target = [target retain];
        m_selector = selector;
        m_fireOnMainThread = NO;
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
        
        if (self.fireOnMainThread) {
            [m_target performSelectorOnMainThread:m_selector withObject:callbackResult waitUntilDone:NO];
        }
        else
        {
            //we call our deliver result to target method so we can set up the apporpriate auto release pool
            [self performSelectorInBackground:@selector(deliverResultToTarget:) withObject:callbackResult];
           // [m_target performSelectorInBackground:m_selector withObject:callbackResult];
        }
    }
}

- (void) deliverResultToTarget:(CallbackResult*)result {
    
    NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc]init];
    
    [m_target performSelector:m_selector withObject:result];
    
   

    [autorelease drain];
    
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

- (void) fireWithResponse:(Response *)response withContext:(NSDictionary *)context {
    CallbackResult* callbackResult = [CallbackResult resultForCallback:self];
    callbackResult.response = response;
    callbackResult.context = context;
    [self fireWithResult:callbackResult];

    
}

- (void) fireWithUserInfo:(NSDictionary*)userInfo {
    CallbackResult* callbackResult = [CallbackResult resultForCallback:self];
    callbackResult.response = userInfo;
    [self fireWithResult:callbackResult];
}

#pragma mark - Static Initializers
+ (Callback*) callbackForTarget:(id)target selector:(SEL)selector fireOnMainThread:(BOOL)fireOnMainThread
{
    Callback* callback = [[Callback alloc]initWithTarget:target withSelector:selector];
    callback.fireOnMainThread = fireOnMainThread;
    [callback autorelease];
    
    return callback;
}

@end
