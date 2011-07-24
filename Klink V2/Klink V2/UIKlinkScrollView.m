//
//  UIKlinkScrollView.m
//  Klink V2
//
//  Created by Bobby Gill on 7/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIKlinkScrollView.h"


@implementation UIKlinkScrollView

- (id)initWithFrame:(CGRect)frame 
{
    return [super initWithFrame:frame];
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{	
    // If not dragging, send event to next responder
    if (!self.dragging) 
        [self.nextResponder touchesEnded: touches withEvent:event]; 
    else
        [super touchesEnded: touches withEvent: event];
}
@end
