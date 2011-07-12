//
//  UIViewSliderDelegate.h
//  Klink V2
//
//  Created by Bobby Gill on 7/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIViewSlider;

@protocol UIViewSliderDelegate <NSObject>
@optional
- (UIView*)viewSlider:(UIViewSlider *)viewSlider cellForRowAtIndex:(int)index;
@end
