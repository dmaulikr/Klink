//
//  Event.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
@class CallbackResult;

@interface Callback : NSObject {
   
    
    
    SEL m_selector;
    id  m_target;
    BOOL m_fireOnMainThread;
    NSDictionary* m_context;
    
    
}

@property (nonatomic, retain) NSDictionary* context;
@property (nonatomic, retain) id            target;
@property                     BOOL          fireOnMainThread;

- (id) initWithTarget:(id)target withSelector:(SEL)selector withContext:(NSDictionary*)context;
- (id) initWithTarget:(id)target withSelector:(SEL)selector;
- (void) fire;
- (void) fireWithResponse:(Response*)response; 
- (void) fireWithResponse:(Response*)response withContext:(NSDictionary*)context;
- (void) fireWithUserInfo:(NSDictionary*)userInfo;
- (void) deliverResultToTarget:(CallbackResult*)result; 


//static initializers
+ (Callback*) callbackForTarget:(id)target selector:(SEL)selector fireOnMainThread:(BOOL)fireOnMainThread;
@end
