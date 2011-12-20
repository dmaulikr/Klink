//
//  UICustomNavigationBar.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/19/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICustomNavigationBar : UINavigationBar <UINavigationBarDelegate> {
    UIImage *_backgroundImage;
}

@property (nonatomic, retain, setter=setBackgroundImage:) UIImage *backgroundImage;

- (void)setBackgroundImage:(UIImage *)image;

@end
