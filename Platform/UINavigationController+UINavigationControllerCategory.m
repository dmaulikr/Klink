//
//  UINavigationController+UINavigationControllerCategory.m
//  Platform
//
//  Created by Jordan Gurrieri on 10/25/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UINavigationController+UINavigationControllerCategory.h"

@implementation UINavigationController (UINavigationControllerCategory)

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

@end
