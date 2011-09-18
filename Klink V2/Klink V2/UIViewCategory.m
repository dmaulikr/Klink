//
//  UIViewCategory.m
//  Klink V2
//
//  Created by Bobby Gill on 9/17/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIViewCategory.h"


@implementation UIView (UIViewCategory)

- (void) removeAllSubviews {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
@end
