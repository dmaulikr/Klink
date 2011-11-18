//
//  BaseViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIViewCategory.h"
#import "UIProgressHUDView.h"

#import "AuthenticationManager.h"
#import "User.h"
#import "UILoginView.h"
#import "FeedManager.h"
#import "EventManager.h"
#import "CallbackResult.h"

@protocol ContributeViewControllerDelegate;
@class UICameraActionSheet;
@class ResourceContext;
@interface BaseViewController : UIViewController <ContributeViewControllerDelegate> {

    UIProgressHUDView*      m_progressView;
    UILoginView*            m_loginView;
}

@property (nonatomic, retain) FeedManager*              feedManager;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) EventManager*             eventManager;


@property (nonatomic, retain) User*                     loggedInUser;
@property (nonatomic, retain) UIProgressHUDView*        progressView;
@property (nonatomic, retain) UILoginView*              loginView;

- (void) authenticate:(BOOL)facebook 
          withTwitter:(BOOL)twitter 
     onFinishSelector:(SEL)sel 
       onTargetObject:(id)targetObject 
           withObject:(id)parameter;

- (void) onUserLoggedIn:(CallbackResult*)result;
- (void) onUserLoggedOut:(CallbackResult*)result;

- (void) showProgressBar: (NSString*)message 
          withCustomView:(UIView*)view 
  withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds; 


- (void) hideProgressBar;
@end
