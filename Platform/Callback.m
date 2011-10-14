//
//  Event.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Callback.h"


@implementation Callback

- (id) initWithTarget:(id)target withSelector:(SEL)selector {
    self = [super init];
    if (self) {
        m_target = target;
        m_selector = selector;
        m_notificationID = nil;
    }
    return self;
}

- (void) fire {
    
}

@end
