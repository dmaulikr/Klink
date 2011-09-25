//
//  UIViewCategory.h
//  Klink V2
//
//  Created by Bobby Gill on 9/17/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (UIViewCategory)
- (void) removeAllSubviews;
- (void) setAnchorPoint:(CGPoint)newAnchorPoint;
@end
