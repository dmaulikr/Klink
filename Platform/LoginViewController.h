//
//  LoginViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 4/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController <SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate, FBSessionDelegate, FBRequestDelegate, UITextFieldDelegate>
{
    UIButton* m_btn_login;
    UIButton* m_btn_loginFacebook;
    UIButton* m_btn_loginTwitter;
    UIButton* m_btn_newUser;
    UITextField* m_tf_email;
    UITextField* m_tf_password;
    UILabel*    m_lbl_error;
    
    FBRequest*          m_fbProfileRequest;
    FBRequest*          m_fbPictureRequest;
    
    BOOL  m_shouldGetFacebook;
    BOOL  m_shouldGetTwitter;
    
    UITextField* m_tf_active;
    
    Callback* m_onFailCallback;
    Callback* m_onSuccessCallback;
}

@property (nonatomic, retain)   FBRequest*              fbProfileRequest;
@property (nonatomic, retain)   FBRequest*              fbPictureRequest;
@property (nonatomic,retain)    SA_OAuthTwitterEngine*  twitterEngine;
@property (nonatomic,retain) IBOutlet UIButton* btn_login;
@property (nonatomic,retain) IBOutlet UIButton* btn_loginFacebook;
@property (nonatomic,retain) IBOutlet UIButton* btn_loginTwitter;
@property (nonatomic,retain) IBOutlet UIButton* btn_newUser;
@property (nonatomic,retain) IBOutlet UITextField* tf_email;
@property (nonatomic,retain) IBOutlet UITextField* tf_password;
@property (nonatomic,retain) IBOutlet UILabel* lbl_error;
@property (nonatomic,retain)  UITextField* tf_active;
@property (nonatomic,retain) Callback* onSuccessCallback;
@property (nonatomic,retain) Callback* onFailureCallback;
@property BOOL shouldGetFacebook;
@property BOOL shouldGetTwitter;

- (IBAction) onLoginButtonPressed:(id)sender;
- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;
- (IBAction) onNewUserButtonPressed:(id)sender;
- (IBAction) hideKeyboard:(id)sender;

+ (LoginViewController*)createAuthenticationInstance:(BOOL)shouldGetFacebook 
                                    shouldGetTwitter:(BOOL)shouldGetTwitter
                                   onSuccessCallback:(Callback*)onSuccessCallback 
                                   onFailureCallback:(Callback*)onFailureCallback;


+ (LoginViewController*)createInstance:(BOOL)shouldGetFacebook 
                      shouldGetTwitter:(BOOL)shouldGetTwitter
                     onSuccessCallback:(Callback*)onSuccessCallback 
                     onFailureCallback:(Callback*)onFailureCallback;


@end
