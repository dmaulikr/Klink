//
//  UICustomNavigationBar.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/19/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICustomNavigationBar.h"

@implementation UICustomNavigationBar
@synthesize backgroundImage = _backgroundImage;


#pragma mark - Accesors
- (void)setBackgroundImage:(UIImage *)image {
    [_backgroundImage release];
    _backgroundImage = [image retain];
    
    [self setNeedsDisplay];
}

#pragma mark - Initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Drawing
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // We call super only when no image has been passed
    // in and therefore we want the default treatment
    if (_backgroundImage == nil) {
        [super drawRect:rect];
    }
    else {
        [_backgroundImage drawInRect:rect];
    }
    
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [super setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    
    [self setBackgroundImage:backgroundImage];
     
}

#pragma mark - Memory Management
- (void)dealloc {
    [_backgroundImage release];
    
    [super dealloc];
}


@end
