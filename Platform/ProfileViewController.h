//
//  ProfileViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"

@interface ProfileViewController : BaseViewController < MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate > {
    UILabel* m_lbl_username;
    UILabel* m_lbl_employeeStartDate;
    UILabel* m_lbl_currentLevel;
    UILabel* m_lbl_currentLevelDate;
    UILabel* m_lbl_numPages;
    UILabel* m_lbl_numVotes;
    UILabel* m_lbl_numSubmissions;
    UILabel* m_lbl_pagesLabel;
    UILabel* m_lbl_votesLabel;
    UILabel* m_lbl_submissionsLabel;
    UILabel* m_lbl_submissionsLast7DaysLabel;
    UILabel* m_lbl_editorMinimumLabel;
    UILabel* m_lbl_userBestLabel;
    UILabel* m_lbl_draftsLast7Days;
    UILabel* m_lbl_photosLast7Days;
    UILabel* m_lbl_captionsLast7Days;
    UILabel* m_lbl_totalLast7Days;
    UILabel* m_lbl_draftsLabel;
    UILabel* m_lbl_photosLabel;
    UILabel* m_lbl_captionsLabel;
    UILabel* m_lbl_totalLabel;
    
    UIImageView* m_iv_progressBarContainer;
    UIImageView* m_iv_progressDrafts;
    UIImageView* m_iv_progressPhotos;
    UIImageView* m_iv_progressCaptions;
    UIImageView* m_iv_editorMinimumLine;
    UIImageView* m_iv_userBestLine;
    
    UIView* m_v_userSettingsContainer;
    UISwitch* m_sw_seamlessFacebookSharing;
    //UISwitch* m_sw_facebookLogin;
    //UISwitch* m_sw_twitterLogin;
    User*   m_user;
    NSNumber* m_userID;
}

@property (nonatomic, retain) IBOutlet UILabel* lbl_username;
@property (nonatomic, retain) IBOutlet UILabel* lbl_employeeStartDate;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevelDate;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numPages;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numSubmissions;
@property (nonatomic, retain) IBOutlet UILabel* lbl_pagesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_votesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_submissionsLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_submissionsLast7DaysLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_editorMinimumLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_userBestLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_draftsLast7Days;
@property (nonatomic, retain) IBOutlet UILabel* lbl_photosLast7Days;
@property (nonatomic, retain) IBOutlet UILabel* lbl_captionsLast7Days;
@property (nonatomic, retain) IBOutlet UILabel* lbl_totalLast7Days;
@property (nonatomic, retain) IBOutlet UILabel* lbl_draftsLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_photosLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_captionsLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_totalLabel;
@property (nonatomic, retain) User* user;
@property (nonatomic, retain) NSNumber* userID;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressBarContainer;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressDrafts;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPhotos;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressCaptions;
@property (nonatomic, retain) IBOutlet UIImageView* iv_editorMinimumLine;
@property (nonatomic, retain) IBOutlet UIImageView* iv_userBestLine;
@property (nonatomic, retain) IBOutlet UIView*      v_userSettingsContainer;
@property (nonatomic, retain) IBOutlet UISwitch*    sw_seamlessFacebookSharing;
//@property (nonatomic, retain) IBOutlet UISwitch*    sw_facebookLogin;
//@property (nonatomic, retain) IBOutlet UISwitch*    sw_twitterLogin;

//- (IBAction) onFacebookLoginChanged:(id)sender;
//- (IBAction) onTwitterLoginChanged:(id)sender;
- (IBAction) onFacebookSeamlessSharingChanged:(id)sender;

+ (ProfileViewController*)createInstance;
+ (ProfileViewController*)createInstanceForUser:(NSNumber*)userID;
@end
