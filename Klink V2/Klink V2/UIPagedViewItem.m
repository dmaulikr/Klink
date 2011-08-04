//
//  UIPagedViewItem.m
//  Klink V2
//
//  Created by Bobby Gill on 8/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPagedViewItem.h"


@implementation UIPagedViewItem 
@synthesize index = m_index;
@synthesize view;

- (void) setMaxMinZoomScalesForCurrentBounds {
    if ([self.view respondsToSelector:@selector(setMaxMinZoomScalesForCurrentBounds:)]) {
        [self.view setMaxMinZoomScalesForCurrentBounds];
    }
}
@end
