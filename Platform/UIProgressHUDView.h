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
- (BOOL) progressViewShouldFinishOnSuccess:(UIProgressHUDView*)progressView; 
- (BOOL) progressViewShouldFinishOnFailure:(UIProgressHUDView*)progressView didFailOnRequest:(Request*)request;
- (BOOL) progressViewShouldFinishOnFailure:(UIProgressHUDView*)progressView didFailOnTimer:(NSTimer*)timer;
- (void) progressViewHeartbeat:(UIProgressHUDView*)progressView timeElapsedInSeconds:(NSNumber*)elapsedTimeInSeconds ;



@end


@interface UIProgressHUDView : MBProgressHUD <RequestProgressDelegate>  {
    UIView*     m_backgroundView;
    NSArray*    m_requests;
    BOOL        m_didSucceed;
    NSNumber*   m_maximumDisplayTime;
    NSTimer*    m_timer;
    NSTimer*    m_animationTimer;
    NSTimer*    m_heartbeatTimer;
    id<UIProgressHUDViewDelegate> m_delegate;
    NSNumber*   m_requestProgress;
    NSNumber*   m_heartbeatSeconds;
    NSDate*     m_dateProgressViewShown;
    
    int         m_wheelRotationTime;
    
    int         m_indexOfProgressMessageCurrentlyShown;
    NSArray*    m_progressMessages;
    NSString*   m_onSuccessMessage;
    NSString*   m_onFailureMessage;

}

- (id) initWithView:(UIView *)view;
- (void) renderComplete;

- (void) show:(BOOL)animated 
withMaximumDisplayTime:(NSNumber*)maximumTimeToDisplay 
showProgressMessages:(NSArray*)progressMessages 
onSuccessShow:(NSString*)successMessage 
onFailureShow:(NSString*)failureMessage;


- (void) show:(BOOL)animated 
withMaximumDisplayTime:(NSNumber*)maximumTimeToDisplay 
withHeartbeatInterval:(NSNumber*)secondsPerBeat 
showProgressMessages:(NSArray*)progressMessages 
onSuccessShow:(NSString*)successMessage 
onFailureShow:(NSString*)failureMessage;;

- (float) percentageComplete;
- (void) extendDisplayTimerBy:(NSNumber*)secondsToAdd;

@property (nonatomic,retain) UIView*    backgroundView;
@property (nonatomic,retain) NSArray*   requests;
@property                    BOOL       didSucceed;
@property (nonatomic,retain) NSNumber*   maximumDisplayTime;
@property                    int        wheelRotationTime;
@property (nonatomic,retain) NSTimer*   timer;
@property (nonatomic,retain) NSTimer*   animationTimer;
@property (nonatomic,retain) NSNumber*  requestProgress;
@property (assign)           id<UIProgressHUDViewDelegate> delegate;
@property (nonatomic,retain) NSTimer*   heartbeatTimer;
@property (nonatomic,retain) NSNumber*  heartbeatSeconds;
@property (nonatomic, retain) NSDate*   dateProgressViewShown;
@property (nonatomic, retain) NSArray*  progressMessages;
@property (nonatomic, retain) NSString* onSuccessMessage;
@property (nonatomic, retain) NSString* onFailureMessage;
@property                     int       indexOfProgressMessageCurrentlyShown;

@end
