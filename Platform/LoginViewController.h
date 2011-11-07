//
//  LoginViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "KlinkBaseViewController.h"
#import "FBConnect.h"
#import "SA_OAuthTwitterEngine.h"
#import "MBProgressHUD.h"

@class SA_OAuthTwitterEngine;

@interface LoginViewController : KlinkBaseViewController <SA_OAuthTwitterControllerDelegate, FBSessionDelegate,SA_OAuthTwitterEngineDelegate, FBRequestDelegate, MBProgressHUDDelegate> {
 
    MBProgressHUD*  m_progressIndicator;
    SEL             m_selPerformOnFinish;
    BOOL            m_doFacebookAuth;
    BOOL            m_doTwitterAuth;
    id              m_callbackTarget;
    BOOL            m_isBusy;
    BOOL            m_isProgressBarShowing;
}

@property (nonatomic,retain)    SA_OAuthTwitterEngine*  twitterEngine;
@property (nonatomic,retain)    id                      callbackTarget;
@property (nonatomic,retain)    MBProgressHUD*          progressIndicator;
@property                       BOOL                    isBusy;
@property                       BOOL                    isProgressBarShowing;

@property SEL   selPerformOnFinish;
@property BOOL  doFacebookAuth;
@property BOOL  doTwitterAuth;

- (id) init;
- (void) beginTwitterAuthentication;
- (void) beginFacebookAuthentication;
- (void) dismiss;
+ (id) controllerForTwitterLogin:(id)callbackTarget onFinishPerform:(SEL)performOnFinish;
+ (id) controllerForFacebookLogin:(id)callbackTarget onFinishPerform:(SEL)performOnFinish;
@end
