//
//  ProfileViewController4.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"

@interface ProfileViewController4 : BaseViewController < UIProgressHUDViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CloudEnumeratorDelegate > {
    
    UIImageView* m_iv_profilePicture;
    UILabel* m_lbl_username;
    //UILabel* m_lbl_employeeStartDate;
    UILabel* m_lbl_currentLevel;
    UILabel* m_lbl_currentLevelDate;
    
    UILabel* m_lbl_numPages;
    //UILabel* m_lbl_numVotes;
    //UILabel* m_lbl_numSubmissions;
    UILabel* m_lbl_numFollowers;
    UILabel* m_lbl_numFollowing;
    UILabel* m_lbl_pagesLabel;
    UILabel* m_lbl_votesLabel;
    UILabel* m_lbl_submissionsLabel;
    
    UIButton* m_btn_numPages;
    //UIButton* m_btn_numVotes;
    //UIButton* m_btn_numSubmissions;
    UIButton* m_btn_numFollowers;
    UIButton* m_btn_numFollowing;
    UIButton* m_btn_pagesLabel;
    UIButton* m_btn_followersLabel;
    UIButton* m_btn_followingLabel;
    
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
    
    UIView* m_v_leaderboardContainer;
    //UISwitch* m_sw_seamlessFacebookSharing;
    //UISwitch* m_sw_facebookLogin;
    //UISwitch* m_sw_twitterLogin;
    User*   m_user;
    NSNumber* m_userID;
    
    CloudEnumerator* m_profileCloudEnumerator;
}

@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePicture;
@property (nonatomic, retain) IBOutlet UILabel* lbl_username;
//@property (nonatomic, retain) IBOutlet UILabel* lbl_employeeStartDate;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevelDate;

@property (nonatomic, retain) IBOutlet UILabel* lbl_numPages;
//@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
//@property (nonatomic, retain) IBOutlet UILabel* lbl_numSubmissions;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numFollowers;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numFollowing;
@property (nonatomic, retain) IBOutlet UILabel* lbl_pagesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_votesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_submissionsLabel;

@property (nonatomic, retain) IBOutlet UIButton* btn_numPages;
//@property (nonatomic, retain) IBOutlet UIButton* btn_numVotes;
//@property (nonatomic, retain) IBOutlet UIButton* btn_numSubmissions;
@property (nonatomic, retain) IBOutlet UIButton* btn_numFollowers;
@property (nonatomic, retain) IBOutlet UIButton* btn_numFollowing;
@property (nonatomic, retain) IBOutlet UIButton* btn_pagesLabel;
@property (nonatomic, retain) IBOutlet UIButton* btn_followersLabel;
@property (nonatomic, retain) IBOutlet UIButton* btn_followingLabel;


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
@property (atomic, retain) User* user;
@property (atomic, retain) NSNumber* userID;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressBarContainer;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressDrafts;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPhotos;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressCaptions;
@property (nonatomic, retain) IBOutlet UIImageView* iv_editorMinimumLine;
@property (nonatomic, retain) IBOutlet UIImageView* iv_userBestLine;
@property (nonatomic, retain) IBOutlet UIView*      v_leaderboardContainer;
//@property (nonatomic, retain) IBOutlet UISwitch*    sw_seamlessFacebookSharing;
@property (nonatomic, retain) CloudEnumerator*      profileCloudEnumerator;


//- (IBAction) onFacebookSeamlessSharingChanged:(id)sender;
- (IBAction) onFollowersButtonPressed:(id)sender;
- (IBAction) onFollowingButtonPressed:(id)sender;

+ (ProfileViewController4*)createInstance;
+ (ProfileViewController4*)createInstanceForUser:(NSNumber*)userID;

@end
