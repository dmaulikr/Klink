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
#import "ApplicationSettingsDefaults.h"

@implementation UIProgressHUDView
@synthesize requestProgress = m_requestProgress;
@synthesize backgroundView = m_backgroundView;
@synthesize requests = m_requests;
@synthesize didSucceed = m_didSucceed;
@synthesize maximumDisplayTime = m_maximumDisplayTime;
@synthesize timer = m_timer;
@synthesize animationTimer = m_animationTimer;
@synthesize heartbeatTimer = m_heartbeatTimer;
@synthesize heartbeatSeconds = m_heartbeatSeconds;
@synthesize dateProgressViewShown = m_dateProgressViewShown;
@synthesize wheelRotationTime = m_wheelRotationTime;
@synthesize progressMessages = m_progressMessages;
@synthesize onSuccessMessage = m_onSuccessMessage;
@synthesize onFailureMessage = m_onFailureMessage;
@synthesize indexOfProgressMessageCurrentlyShown = m_indexOfProgressMessageCurrentlyShown;

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


- (void) animateFillOfProgress 
{

}

- (void) extendDisplayTimerBy:(NSNumber *)secondsToAdd 
{
    NSString* activityName = @"UIProgressHUDView.extendDisplayTimerBy:";
    //this method will take the seconds given, and add it to the displayTimer
    //and re-adjust the progress pie being shown to accurately reflect the new
    //progress
    if ([secondsToAdd floatValue] > 0) 
    {
        LOG_PROGRESSVIEW(0, @"%@Adding %@ seconds to progress view life",activityName,secondsToAdd);
        double secondsleftOnTimer = 0;
        if (self.timer != nil)
        {
            //need to get time remaining on the timer
            double timeOfNextFireInSeconds =  [self.timer.fireDate timeIntervalSince1970];
            double timeNowInSeconds = [[NSDate date]timeIntervalSince1970];
            
            secondsleftOnTimer = timeOfNextFireInSeconds - timeNowInSeconds;
            LOG_PROGRESSVIEW(0, @"%@ %f seconds remaining on timer",activityName,secondsleftOnTimer);
            [self.timer invalidate];
            self.timer = nil;
        }
        
        //the new timer value
        self.maximumDisplayTime = [NSNumber numberWithDouble:(secondsleftOnTimer+[secondsToAdd doubleValue])];        
        
        //adjust the progress meter
        float oldProgressValue = self.progress;
        
        self.progress = self.progress * ((float)self.wheelRotationTime/100);
        
        if (self.progress > 1) 
        {
            self.progress = self.progress -1;
        }
        //self.progress = self.progress * ([self.maximumDisplayTime floatValue]/100);
        
        
        LOG_PROGRESSVIEW(0, @"%@Adjusting progress meter from %f to %f",activityName,oldProgressValue,self.progress);
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.maximumDisplayTime intValue] target:self selector:@selector(onMaximumDisplayTimerExpired) userInfo:nil repeats:NO];
    }
    else {
        //error condition
    }
}

//Returns a % indicating the Requests which have completed
- (float) percentageComplete 
{
    //we get the progress from this request, and then we do a  average across all the requests
    //set for this progress indicator
    float denominator = [self.requests count];
    float numerator = 0;
    
    for (Request* request in self.requests) {
        numerator += request.progress;
    }
    
    float p = (numerator / denominator)*100;
    return p;
}

- (void) renderSuccessfulCompletion 
{
    UIImageView* iv  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    
    //CGRect iv_frame = iv.frame;
    
    self.customView = iv;
    [iv release];
    
    
    
    self.mode = MBProgressHUDModeCustomView;
    self.labelText = self.onSuccessMessage;
    self.didSucceed = YES;
    [self addSubview:self.customView];

}

- (void) renderFailedCompletion 
{
    UIImageView* iv  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"37x-bug.png"]];
    
    //CGRect iv_frame = iv.frame;
    
    self.customView = iv;
    [iv release];
    
    self.mode = MBProgressHUDModeCustomView;
    self.labelText = self.onFailureMessage;
    self.didSucceed = NO;
    [self addSubview:self.customView];
 
}

#pragma RequestProcessDelegate
- (void) request:(Request *)request setProgress:(float)progress {
    NSString* activityName = @"UIProgressHUDView.setProgress:";

    BOOL shouldCloseProgressBar = NO;

    
    float p = [self percentageComplete];
    self.requestProgress = [NSNumber numberWithFloat:p];
    
    LOG_PROGRESSVIEW(0, @"%@ Outstanding submission is %f % complete",activityName,p);
    
    
    if (p >= 100 && 
        [request.statuscode intValue] != kFAILED)
    {
        //request succeeded and we are now complete according ot our Request array
        if ([self.delegate respondsToSelector:@selector(progressViewShouldFinishOnSuccess:)]) 
        {
            //we call the delegate
            shouldCloseProgressBar = [self.delegate progressViewShouldFinishOnSuccess:self];
        }
        else 
        {
            //default behavior is to close on success
            shouldCloseProgressBar = YES;
        }
        
        LOG_PROGRESSVIEW(0, @"%@Detected all Requests are complete, shouldCloseProgressBar=%d",activityName,shouldCloseProgressBar);
    }
    else if ([request.statuscode intValue] == kFAILED)
    {
       //request failed
        if ([self.delegate respondsToSelector:@selector(progressViewShouldFinishOnFailure:didFailOnRequest:)]) 
        {
            //we call the delegate
            shouldCloseProgressBar = [self.delegate progressViewShouldFinishOnFailure:self didFailOnRequest:request];
        }
        else {
            shouldCloseProgressBar = YES;
        }
        LOG_PROGRESSVIEW(0, @"%@Last request failed, shouldCloseProgressBar=%d",activityName,shouldCloseProgressBar);
    }
    
    //now we check to see if we should close the progress view
    if (shouldCloseProgressBar) 
    {
        //yes we should begin the shutdown procedure
        //stop the maximum display timer as we will exit
        [self.timer invalidate];
        self.timer = nil;
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        
        
        
        //now we need to animate the filling of the rest of the pie
        if ([request.statuscode intValue] != kFAILED)
        {
            //we know we are closing on success, so let us animate the rest of the pie
            self.progress = 1;
        }
        
        
        
        //[self.customView removeFromSuperview];
        [self renderComplete];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimerExpireHide) userInfo:nil repeats:NO];


    }

}

- (void) renderComplete 
{
    NSString* activityName = @"UIProgressHUDView.renderComplete:";
    //we need to determine whether we are ending on success or failure here
    
    [self.timer invalidate];
    [self.heartbeatTimer invalidate];
    [self.animationTimer invalidate];
    self.dateProgressViewShown = nil;
    self.timer = nil;
    self.heartbeatTimer = nil;
    self.animationTimer = nil;
    
    
    BOOL haveAllRequestsFinishedSuccessfully = YES;
       
    for (Request* request in self.requests) 
    {
        if ([request.statuscode intValue] != kCOMPLETED) 
        {
            haveAllRequestsFinishedSuccessfully = NO;
            break;
        }
    }
        
    //[self.customView removeFromSuperview];
        
    if (haveAllRequestsFinishedSuccessfully) 
    {
        //since all requests completed successfully we render the success view
        [self renderSuccessfulCompletion];
        self.didSucceed = YES;
        LOG_PROGRESSVIEW(0, @"%@Ending progress view in success state",activityName);           
        
    }
    else 
    {
        //render the failure view           
        [self renderFailedCompletion];
        self.didSucceed = NO;
        LOG_PROGRESSVIEW(0, @"%@Ending progress view in failed state",activityName);
        
    }
  
    
    
   

}


- (void) onHeartbeatTick 
{
    //we call into the delegate to tell to check our status
    if ([self.delegate respondsToSelector:@selector(progressViewHeartbeat:timeElapsedInSeconds:)]) 
    {
        double currentTimeInSeconds = [[NSDate date] timeIntervalSince1970];
        double dateStartedInSeconds = [self.dateProgressViewShown timeIntervalSince1970];
        double timeElapsed = currentTimeInSeconds  - dateStartedInSeconds;
        
        //we also switch the currently displayed text depending on what is currently being shown
        self.indexOfProgressMessageCurrentlyShown = (self.indexOfProgressMessageCurrentlyShown + 1) % [self.progressMessages count];
        
        NSString* newProgressMessage = [self.progressMessages objectAtIndex:self.indexOfProgressMessageCurrentlyShown];
        //lets display the new progress image
        self.labelText = newProgressMessage;
        
        [self.delegate progressViewHeartbeat:self timeElapsedInSeconds:[NSNumber numberWithDouble:timeElapsed]];
    }
}

- (void) onMaximumDisplayTimerExpired {
    NSString* activityName = @"UIProgressHUDView.onMaximumDisplayTimerExpired";
    
    //called when the progress bar needs to be hidden because it has exceeded its display quota
    //we assume the call ahs failed if the progress bar ends up stuck
    
    
    //we check to see if we should extend the timer
    BOOL shouldFinish = YES;
    
    if ([self.delegate respondsToSelector:@selector(progressViewShouldFinishOnFailure:didFailOnTimer:)])
    {
        shouldFinish = [self.delegate progressViewShouldFinishOnFailure:self didFailOnTimer:self.timer];
    }
    
    LOG_PROGRESSVIEW(0, @"%@Lifetime timer expired on progress view, shouldFinish:%d",activityName,shouldFinish);
    
    if (shouldFinish) 
    {
      //  [self.customView removeFromSuperview];
        [self renderFailedCompletion];
        self.didSucceed = NO;
        LOG_PROGRESSVIEW(0,@"%@Closing progress view due to timer expiry",activityName);
        
        //[self renderComplete];
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimerExpireHide) userInfo:nil repeats:NO];


    }

}


- (void) show:(BOOL)animated 
withMaximumDisplayTime:(NSNumber *)maximumTimeToDisplay 
showProgressMessages:(NSArray *)progressMessages 
onSuccessShow:(NSString *)successMessage 
onFailureShow:(NSString *)failureMessage
{
    [super show:animated];
    self.dateProgressViewShown = [NSDate date];
    self.maximumDisplayTime = maximumTimeToDisplay;
    self.onFailureMessage = failureMessage;
    self.onSuccessMessage = successMessage;
    self.progressMessages = progressMessages;
    self.indexOfProgressMessageCurrentlyShown = 0;
    
    if ([self.progressMessages count] > 0)
    {
        self.labelText = [self.progressMessages objectAtIndex:0];
    }
    
    //we set the wheel spin time based on a client only setting
    self.wheelRotationTime = progress_WHEELSPINTIME;
    
    self.dateProgressViewShown = [NSDate date];
    
    //we set a timer to tell us when to hide the progress bar
    if (self.maximumDisplayTime != nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.maximumDisplayTime intValue] target:self selector:@selector(onMaximumDisplayTimerExpired) userInfo:nil repeats:NO];
        
       
        
    }
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onAnimationTimerTick) userInfo:nil repeats:YES];

}
- (void) show:(BOOL)animated withMaximumDisplayTime:(NSNumber *)maximumTimeToDisplay 
withHeartbeatInterval:(NSNumber *)secondsPerBeat showProgressMessages:(NSArray *)progressMessages onSuccessShow:(NSString *)successMessage onFailureShow:(NSString *)failureMessage
{
    [self show:animated withMaximumDisplayTime:maximumTimeToDisplay showProgressMessages:progressMessages onSuccessShow:successMessage onFailureShow:failureMessage];
    self.heartbeatSeconds = secondsPerBeat;
    //we only define this if there is a delegate present
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(progressViewHeartbeat:timeElapsedInSeconds:)])
    {
        self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:[secondsPerBeat intValue] target:self selector:@selector(onHeartbeatTick) userInfo:nil repeats:YES];
    }
}

- (void) initializeWith:(NSArray *)requests 
{
    self.dateProgressViewShown = nil;
    self.progress = 0;
    self.didSucceed = NO;
    self.requests = nil;
    self.requests = requests;
}

- (void) onAnimationTimerTick {
    //we increment the progress
    
    float incrementAmount = 1.0f / (float)self.wheelRotationTime;
    float newProgressValue = self.progress + incrementAmount;
    
    
    if (newProgressValue > 1) 
    {
        newProgressValue = newProgressValue - 1;
    }
    
    self.progress = newProgressValue;
    
}


- (void) onTimerExpireHide {

    
    
     [self performSelectorOnMainThread:@selector(hide:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
   // [self performSelectorOnMainThread:@selector(hide:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
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
    self.dateProgressViewShown = nil;
    self.animationTimer = nil;
    self.timer = nil;
    self.heartbeatTimer = nil;
    [super dealloc];
}

@end
