//
//  UIImageView+UIImageViewCategory.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/14/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (UIImageViewCategory)

-(CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView;

@end
