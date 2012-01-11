//
//  UIProgressHUDView.m
//  Platform
//
//  Created by Bobby Gill on 11/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProgressHUDView.h"
#import "Request.h"
#import "Macros.h"
#import "PlatformAppDelegate.h"

@implementation UIProgressHUDView
@synthesize backgroundView = m_backgroundView;
@synthesize requests = m_requests;
@synthesize didSucceed = m_didSucceed;
@synthesize maximumDisplayTime = m_maximumDisplayTime;
@synthesize timer = m_timer;
@synthesize animationTimer = m_animationTimer;

#pragma mark - Property Definitions
- (id) delegate {
    return m_delegate;
}


-(void)setDelegate:(id<UIProgressHUDViewDelegate>)del
{
    [super setDelegate:del];
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.animationType = MBProgressHUDAnimationZoom;
            }
    return self;
}

- (id) initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
            }
    return self;
}


- (void) extendMaximumDisplayTime:(NSNumber*)secondsToExtend 
{
    //now we have the maximumdisplay timer, we need to invalidate that timer
    //and now reset the timer to be the additional time given to us by the delegate
    if (self.timer != nil)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
    //we add this time now to the maximumdisplaytimer
    self.maximumDisplayTime = [NSNumber numberWithFloat:([self.maximumDisplayTime floatValue] + [secondsToExtend floatValue])];
    
    //we need to update the progress indicator
    self.progress = (self.progress * [self.maximumDisplayTime floatValue])/100.0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.maximumDisplayTime intValue] target:self selector:@selector(onMaximumDisplayTimerExpired) userInfo:nil repeats:NO];
    
}

#pragma RequestProcessDelegate
- (void) request:(Request *)request setProgress:(float)progress {
    NSString* activityName = @"UIProgressHUDView.setProgress:";
    
    //we get the progress from this request, and then we do a  average across all the requests
    //set for this progress indicator
    float denominator = [self.requests count];
    float numerator = 0;
    
    for (Request* request in self.requests) {
        numerator += request.progress;
    }
    
    float p = (numerator / denominator)*100;
    LOG_REQUEST(0, @"%@ Outstanding submission is %f % complete (%f/%f)",activityName,p,numerator,denominator );
    

    self.progress = (numerator / denominator);
    
    
    //intercept failure
    //if it fails, if there is an enumerator defined
    //we need to add time to the timer
    //execute the enumeration
    //add it to th4 self.requests
    //recompute progress
    //wait for completion of that request
    //we need to reset the timer so that it doesnt go off
    //use the enumeration handler to get the success/failure of it
    BOOL shouldCloseProgressBar = NO;
    if ([request.statuscode intValue] == kFAILED &&
        [self.delegate respondsToSelector:@selector(secondsToExtendProgressView:onFailedRequest:)])
    {
        //delegate extension method defined
        NSNumber* secondsMoreToWaitToFail = [self.delegate secondsToExtendProgressView:self onFailedRequest:request];
        
        if (secondsMoreToWaitToFail != nil &&
            [secondsMoreToWaitToFail floatValue] != 0) 
        {
            LOG_REQUEST(0, @"%@Progress bar timed out, but delegate instructed it to extend its timeout by an additional %d seconds",activityName,[secondsMoreToWaitToFail floatValue]);
            [self extendMaximumDisplayTime:secondsMoreToWaitToFail];            
            //at this point we should not close the progress bar    
            shouldCloseProgressBar = NO;
        }
        else {
            //we should continue normally and close the progress bar
            shouldCloseProgressBar = YES;
        }

    }
    else if ([request.statuscode intValue] == kFAILED) 
    {
        //we should close the progress bar
        shouldCloseProgressBar = YES;
    }
    
    
    //if we detect that all requests have been completed
    if (self.progress >= 1 || shouldCloseProgressBar) 
    {

        //stop the maximum display timer as we will exit
        [self.timer invalidate];
        self.timer = nil;
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        
        //if they have all been successful
        BOOL isSuccess = YES;
        Request* failedRequest = nil;
        
        if ([request.statuscode intValue] != kFAILED) {
            for (Request* request in self.requests) {
                if ([request.statuscode intValue] == kFAILED) {
                    isSuccess = NO;
                    failedRequest = request;
                    break;
                }
            }
        }
        else {
            failedRequest = request;
            isSuccess = NO;
        }
                
        [self.customView removeFromSuperview];
        
        if (isSuccess) {
            //show a checkmark
            
            UIImageView* iv  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            self.customView = iv;
            [iv release];
            
            self.mode = MBProgressHUDModeCustomView;
            self.labelText = @"Success!";
            self.didSucceed = YES;
            
            
        }
        else {
            //show a failed mark
            //TODO: need a white 37x x 37x "X" to denote failure
            UIImageView* iv  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-pics2@2x.png"]];
            self.customView = iv;
            [iv release];

            self.mode = MBProgressHUDModeCustomView;
            self.labelText = @"Failed!";
            self.didSucceed = NO;
            
            self.detailsLabelText = failedRequest.errormessage;
            

        }
        
        //now we pause for 5 seconds before we dismiss
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimerExpireHide) userInfo:nil repeats:NO];
        //[self performSelectorOnMainThread:@selector(hide:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        
    }
}

- (void) onMaximumDisplayTimerExpired {
    NSString* activityName = @"UIProgressHUDView.onMaximumDisplayTimerExpired";
    
    //called when the progress bar needs to be hidden because it has exceeded its display quota
    //we assume the call ahs failed if the progress bar ends up stuck
    
    
    //we check to see if we should extend the timer
    BOOL shouldFail = YES;
    
    if ([self.delegate respondsToSelector:@selector(secondsToExtendProgressView:onTimerExpiry:)]) 
    {
        //we ask the delegate if we should fail the request on maximum time expiry
        NSNumber* secondsMoreToWaitToFail = [self.delegate secondsToExtendProgressView:self onTimerExpiry:self.timer];
        
        if (secondsMoreToWaitToFail != nil &&
            [secondsMoreToWaitToFail floatValue] != 0) 
        {
            LOG_REQUEST(0, @"%@Progress bar timed out, but delegate instructed it to extend its timeout by an additional %d seconds",activityName,[secondsMoreToWaitToFail floatValue]);
            //now we extend the timer
            [self extendMaximumDisplayTime:secondsMoreToWaitToFail];
            shouldFail = NO;
        }
        else {
            shouldFail = YES;
        }
        
        
    }
    
    
    if (shouldFail)
    {
        
        LOG_REQUEST(0, @"%@Progress bar has exceeded its maximum display timer setting, automatically closing progress bar and failing request",activityName);
        self.didSucceed = NO;
        UIImageView* iv  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-pics2@2x.png"]];
        self.customView = iv;
        [iv release];
        
        self.mode = MBProgressHUDModeCustomView;
        self.labelText = @"Failed!";
        self.didSucceed = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimerExpireHide) userInfo:nil repeats:NO];
    }
}

- (void) show:(BOOL)animated withMaximumDisplayTime:(NSNumber *)maximumTimeToDisplay 
{
    [super show:animated];
    self.maximumDisplayTime = maximumTimeToDisplay;
    
    //we set a timer to tell us when to hide the progress bar
    if (self.maximumDisplayTime != nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.maximumDisplayTime intValue] target:self selector:@selector(onMaximumDisplayTimerExpired) userInfo:nil repeats:NO];
        
        //also if this is only a single member request, we start an animation timer
        //to simulate the progression using the maximum time as an upper bound
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onAnimationTimerTick) userInfo:nil repeats:YES];
    }
}

- (void) initializeWith:(NSArray *)requests {
    self.progress = 0;
    self.didSucceed = NO;
    self.requests = nil;
    self.requests = requests;
}

- (void) onAnimationTimerTick {
    //we increment the progress
    float incrementAmount = 1.0f / [self.maximumDisplayTime floatValue];
    self.progress = self.progress + incrementAmount;
}

- (void) onTimerExpireHide {
    [self performSelectorOnMainThread:@selector(hide:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
   
    [super dealloc];
}

@end
