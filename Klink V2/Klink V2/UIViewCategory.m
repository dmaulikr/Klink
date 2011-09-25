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

- (void) setAnchorPoint:(CGPoint)newAnchorPoint {
    self.layer.anchorPoint = newAnchorPoint;
    CGPoint position = self.layer.position;
	CGPoint anchorPoint = self.layer.anchorPoint;
	CGRect bounds = self.bounds;
	// 0.5, 0.5 is the default anchorPoint; calculate the difference
	// and multiply by the bounds of the view
	position.x = (0.5 * bounds.size.width) + (anchorPoint.x - 0.5) * bounds.size.width;
	position.y = (0.5 * bounds.size.height) + (anchorPoint.y - 0.5) * bounds.size.height;
	self.layer.position = position;   
}
@end
