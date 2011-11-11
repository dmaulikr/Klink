//
//  ContributeViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface ContributeViewController : BaseViewController <UITextViewDelegate> {
    UIScrollView*   m_scrollView;
    UITextView*     m_activeTextView;
    UITextField*    m_activeTextField;
    
    NSString*       m_configurationType;
    
    UILabel*        m_lbl_draftTitle;
    NSString*       m_draftTitle;
    UITextField*    m_tf_newDraftTitle;
    UILabel*        m_lbl_titleRequired;
//    BOOL            m_titleRequired;
    
    UIImageView*    m_iv_photo;
    UIImage*        m_img_photo;
    UILabel*        m_lbl_photoOptional;
    UILabel*        m_lbl_photoRequired;
//    BOOL            m_photoRequired;
    
    UITextView*     m_tv_caption;
    UILabel*        m_lbl_captionOptional;
    UILabel*        m_lbl_captionRequired;
//    BOOL            m_captionRequired;
    
    UILabel*        m_lbl_deadline;
}

@property (nonatomic, retain) IBOutlet UIScrollView*    scrollView;
@property (nonatomic, retain) UITextView*               activeTextView;
@property (nonatomic, retain) UITextField*              activeTextField;

@property (nonatomic, retain) NSString*                 configurationType;

@property (nonatomic, retain) IBOutlet UILabel*         lbl_draftTitle;
@property (nonatomic, retain) NSString*                 draftTitle;
@property (nonatomic, retain) IBOutlet UITextField*     tf_newDraftTitle;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_titleRequired;
//@property (nonatomic, retain) BOOL                      titleRequired;

@property (nonatomic, retain) IBOutlet UIImageView*     iv_photo;
@property (nonatomic, retain) UIImage*                  img_photo;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoOptional;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoRequired;
//@property (nonatomic, retain) BOOL                      photoOptional;

@property (nonatomic, retain) IBOutlet UITextView*      tv_caption;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionOptional;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionRequired;
//@property (nonatomic, retain) BOOL                      captionRequired;

@property (nonatomic, retain) IBOutlet UILabel*         lbl_deadline;


- (void)registerForKeyboardNotifications;
- (IBAction)backgroundClick:(id)sender;

+ (ContributeViewController*) createInstance;

@end
