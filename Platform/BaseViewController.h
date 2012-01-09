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
#import "Request.h"
#import "UICustomAlertView.h"

@class ContributeViewController;
@class UICameraActionSheet;
@class ResourceContext;

@protocol ContributeViewControllerDelegate <NSObject>

- (void)submitChangesForController:(ContributeViewController*)controller;

@end
@interface BaseViewController : UIViewController < ContributeViewControllerDelegate, UIAlertViewDelegate > {

    
    UILoginView*            m_loginView;
}

@property (nonatomic, retain) FeedManager*              feedManager;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) EventManager*             eventManager;


@property (nonatomic, retain) User*                     loggedInUser;
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

- (void) showDeterminateProgressBar:(NSString*)message
                     withCustomView:(UIView*)view
             withMaximumDisplayTime:(NSNumber*)maximumTimeInSeconds; 
    

- (void) hideProgressBar;

- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
