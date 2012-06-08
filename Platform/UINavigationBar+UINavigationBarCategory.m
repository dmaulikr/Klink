//
//  UINavigationBar+UINavigationBarCategory.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UINavigationBar+UINavigationBarCategory.h"

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    UIImage *img = [UIImage imageNamed:@"navbar.png"];
    [img drawInRect:rect];
}

@end
