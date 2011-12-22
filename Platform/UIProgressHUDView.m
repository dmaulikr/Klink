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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
            }
    return self;
}

- (id) initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
            }
    return self;
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
    
    //if we detect that all requests have been completed
    if (self.progress == 1 || [request.statuscode intValue] == kFAILED) {
        //stop the maximum display timer as we will exit
        [self.timer invalidate];
        self.timer = nil;
        
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
    LOG_REQUEST(0, @"%@Progress bar has exceeded its maximum display timer setting, automatically closing progress bar and failing request",activityName);
    self.didSucceed = NO;
    [self performSelectorOnMainThread:@selector(hide:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}

- (void) show:(BOOL)animated {
    [super show:animated];
    //we set a timer to tell us when to hide the progress bar
    if (self.maximumDisplayTime != nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.maximumDisplayTime intValue] target:self selector:@selector(onMaximumDisplayTimerExpired) userInfo:nil repeats:NO];
    }
}

- (void) initializeWith:(NSArray *)requests {
    self.progress = 0;
    self.didSucceed = NO;
    self.requests = nil;
    self.requests = requests;
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
