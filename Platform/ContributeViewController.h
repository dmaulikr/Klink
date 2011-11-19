//
//  ContributeViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UICameraActionSheet.h"
@class ContributeViewController;
@protocol ContributeViewControllerDelegate <NSObject>

- (void)submitChangesForController:(ContributeViewController*)controller;

@end

@interface ContributeViewController : BaseViewController <UITextViewDelegate, UITextFieldDelegate, UICameraActionSheetDelegate> {
    id<ContributeViewControllerDelegate> m_delegate;
    
    UICameraActionSheet*    m_cameraActionSheet;
    UIScrollView*   m_scrollView;
    UITextView*     m_activeTextView;
    UITextField*    m_activeTextField;
    
    
    NSString*       m_configurationType;
    NSNumber*       m_pageID; //represents the ID of the page that a new photo can be added to
    NSNumber*       m_photoID; //represents the ID of the photo that a new caption can be added to
    
    UILabel*        m_lbl_draftTitle;
    NSString*       m_draftTitle;
    UITextField*    m_tf_newDraftTitle;
    UILabel*        m_lbl_titleRequired;
    
    UIButton*       m_btn_cameraButton; //handles when the photo is touched to launch the camera
    UIImageView*    m_iv_photo;
    UIImage*        m_img_photo;
    UIImage*        m_img_thumbnail;
    UILabel*        m_lbl_photoOptional;
    UILabel*        m_lbl_photoRequired;
    
    UITextView*     m_tv_caption;
    NSString*       m_caption;    
    UILabel*        m_lbl_captionOptional;
    UILabel*        m_lbl_captionRequired;
    
    UILabel*        m_lbl_deadline;
}

@property (nonatomic, assign) id<ContributeViewControllerDelegate> delegate;

@property (nonatomic, retain) UICameraActionSheet*      cameraActionSheet;

@property (nonatomic, retain) IBOutlet UIScrollView*    scrollView;
@property (nonatomic, retain) UITextView*               activeTextView;
@property (nonatomic, retain) UITextField*              activeTextField;

@property (nonatomic, retain) NSString*                 configurationType;
@property (nonatomic, retain) NSNumber*                 pageID;
@property (nonatomic, retain) NSNumber*                 photoID;

@property (nonatomic, retain) IBOutlet UILabel*         lbl_draftTitle;
@property (nonatomic, retain) NSString*                 draftTitle;
@property (nonatomic, retain) IBOutlet UITextField*     tf_newDraftTitle;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_titleRequired;

@property (nonatomic, retain) IBOutlet UIButton*        btn_cameraButton;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_photo;
@property (nonatomic, retain) UIImage*                  img_photo;
@property (nonatomic, retain) UIImage*                  img_thumbnail;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoOptional;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_photoRequired;

@property (nonatomic, retain) IBOutlet UITextView*      tv_caption;
@property (nonatomic, retain) NSString*                 caption;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionOptional;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_captionRequired;

@property (nonatomic, retain) IBOutlet UILabel*         lbl_deadline;


- (void)registerForKeyboardNotifications;
- (IBAction)backgroundClick:(id)sender;
- (IBAction)onCameraButtonPressed:(id)sender;
- (void)onCancelButtonPressed:(id)sender;

+ (ContributeViewController*) createInstanceForNewDraft;
+ (ContributeViewController*) createInstanceForNewPhotoWithPageID:(NSNumber*)pageID;
+ (ContributeViewController*) createInstanceForNewCaptionWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID;

@end
