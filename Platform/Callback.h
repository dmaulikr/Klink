//
//  Event.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Callback : NSObject {
    NSString* m_notificationID;
    
    
    SEL m_selector;
    id  m_target;
}
- (id) initWithTarget:(id)target withSelector:(SEL)selector;
- (void) fire;

@end
