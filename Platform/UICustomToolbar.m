//
//  UICustomToolbar.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/19/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICustomToolbar.h"

@implementation UICustomToolbar
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
    // We call super only when no image has been passed in and therefore we
    // want the default dreatment
    if (_backgroundImage == nil) {
        [super drawRect:rect];
    }
    else {
        [_backgroundImage drawInRect:rect];
    }
    
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIToolbarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics {
    [super setBackgroundImage:backgroundImage forToolbarPosition:topOrBottom barMetrics:barMetrics];
}

#pragma mark - Memory Management
- (void)dealloc {
    [_backgroundImage release];
    
    [super dealloc];
}


@end
