//
//  SignUpViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 4/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface SignUpViewController : BaseViewController <UIProgressHUDViewDelegate,UITextFieldDelegate>
{
    UIScrollView    *m_sv_scrollView;
    
    UITextField* m_tf_email;
    UITextField* m_tf_username;
    UITextField* m_tf_password;
    UITextField* m_tf_password2;
    UITextField* m_tf_displayName;
    
    UITextField* m_tf_active;
    
    UIButton* m_btn_join;
    
    UILabel* m_lbl_error;
    UILabel *m_lbl_intro;
    
}

@property (nonatomic,retain) IBOutlet UIScrollView *sv_scrollView;
@property (nonatomic,retain) IBOutlet UITextField* tf_email;
@property (nonatomic,retain) IBOutlet UITextField* tf_username;
@property (nonatomic,retain) IBOutlet UITextField* tf_password;
@property (nonatomic,retain) IBOutlet UITextField* tf_password2;
@property (nonatomic,retain) IBOutlet UIButton*    btn_join;
@property (nonatomic,retain) IBOutlet UILabel*     lbl_error;
@property (nonatomic,retain) IBOutlet UILabel*     lbl_intro;
@property (nonatomic,retain) IBOutlet UITextField* tf_displayName;
@property (nonatomic,retain) UITextField*          tf_active;


- (IBAction) onJoinPressed:(id)sender;

+(SignUpViewController*)createInstance;
    @end
