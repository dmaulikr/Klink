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
    //UIImage *image = [UIImage imageNamed: @"NavigationBar_clear.png"];
    //[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [super drawRect:rect];
    
    [_backgroundImage drawInRect:rect];
    
}

#pragma mark - Memory Management
- (void)dealloc {
    [_backgroundImage release];
    
    [super dealloc];
}

#pragma mark - UINavigationController Delegate Methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}

@end
