//
//  UILoginView.h
//  Platform
//
//  Created by Bobby Gill on 11/9/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Callback.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "FBConnect.h"
@class BaseViewController;

@interface UILoginView : UIView <SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate, FBSessionDelegate, FBRequestDelegate>  {
    BaseViewController* m_parentViewController;
    BOOL                m_authenticateWithTwitter;
    BOOL                m_authenticateWithFacebook;
    Callback*           m_onSuccessCallback;
    Callback*           m_onFailCallback;
    FBRequest*          m_fbProfileRequest;
    FBRequest*          m_fbPictureRequest;
    
}
- (void) dismissWithResult:(BOOL)result;
- (void) checkStatusAndDismiss;
- (id)initWithFrame:(CGRect)frame withParent:(BaseViewController*)parentViewController;
- (void) authenticate:(BOOL)facebook 
          withTwitter:(BOOL)twitter 
     onSuccessCallback:(Callback*)onSuccessCallback
       onFailCallback:(Callback*)onFailureCallback;

@property (nonatomic,retain)    SA_OAuthTwitterEngine*  twitterEngine;
@property (nonatomic,retain)    BaseViewController*     parentViewController;
@property (nonatomic, retain)   FBRequest*              fbProfileRequest;
@property (nonatomic, retain)   FBRequest*              fbPictureRequest;

@property BOOL                                          authenticateWithTwitter;
@property BOOL                                          authenticateWithFacebook;
@property (nonatomic,retain)    Callback*               onSuccessCallback;
@property (nonatomic,retain)    Callback*               onFailCallback;
@end
