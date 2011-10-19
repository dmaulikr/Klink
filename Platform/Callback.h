//
//  Event.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"

@interface Callback : NSObject {
   
    
    
    SEL m_selector;
    id  m_target;
    
    NSDictionary* m_context;
    
    
}

@property (nonatomic, retain) NSDictionary* context;

- (id) initWithTarget:(id)target withSelector:(SEL)selector withContext:(NSDictionary*)context;
- (id) initWithTarget:(id)target withSelector:(SEL)selector;
- (void) fire;
- (void) fireWithResponse:(Response*)response; 

@end
