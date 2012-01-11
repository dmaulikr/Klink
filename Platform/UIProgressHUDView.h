//
//  UIProgressHUDView.h
//  Platform
//
//  Created by Bobby Gill on 11/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "Request.h"
#import "CloudEnumerator.h"

@class UIProgressHUDView;

@protocol UIProgressHUDViewDelegate <MBProgressHUDDelegate>

@optional
- (NSNumber*) secondsToExtendProgressView:(UIProgressHUDView*)progressView 
               onFailedRequest:(Request*)failedRequest; 
- (NSNumber*) secondsToExtendProgressView:(UIProgressHUDView*)progressView 
           onTimerExpiry:(NSTimer*)timer;
@end


@interface UIProgressHUDView : MBProgressHUD <RequestProgressDelegate>  {
    UIView* m_backgroundView;
    NSArray* m_requests;
    BOOL m_didSucceed;
    NSNumber* m_maximumDisplayTime;
    NSTimer* m_timer;
    NSTimer* m_animationTimer;
    id<UIProgressHUDViewDelegate> m_delegate;

}

- (id) initWithView:(UIView *)view;
- (void) show:(BOOL)animated withMaximumDisplayTime:(NSNumber*)maximumTimeToDisplay;

@property (nonatomic,retain) UIView*    backgroundView;
@property (nonatomic,retain) NSArray*   requests;
@property                    BOOL       didSucceed;
@property (nonatomic,retain) NSNumber*   maximumDisplayTime;
@property (nonatomic,retain) NSTimer*   timer;
@property (nonatomic,retain) NSTimer*   animationTimer;
@property (assign) id<UIProgressHUDViewDelegate> delegate;

@end
