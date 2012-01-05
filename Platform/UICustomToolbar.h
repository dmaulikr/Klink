//
//  UICustomToolbar.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/19/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UICustomToolbar : UIToolbar {
    UIImage *_backgroundImage;
}

@property (nonatomic, retain, setter=setBackgroundImage:) UIImage *backgroundImage;

// iOS 5 pass through to super
- (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIToolbarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;

// pre-iOS 5 method
- (void)setBackgroundImage:(UIImage *)image;

@end
