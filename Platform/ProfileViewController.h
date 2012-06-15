//
//  ProfileViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "UICameraActionSheet.h"
#import "UILeaderboard3Up.h"
#import "UIPointsProgressBar.h"
#import "Leaderboard.h"

@interface ProfileViewController : BaseViewController < UIProgressHUDViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CloudEnumeratorDelegate, UICameraActionSheetDelegate > {
    
    UIImageView* m_iv_profilePicture;
    UIButton* m_btn_changeProfilePicture;
    UICameraActionSheet* m_cameraActionSheet;
    
    UILabel* m_lbl_username;
    UILabel* m_lbl_currentLevel;
    UILabel* m_lbl_currentLevelDate;
    
    UIButton* m_btn_numPages;
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
    UILabel* m_lbl_pointsLast7Days;
    
    UIImageView* m_iv_progressBarContainer;
    UIImageView* m_iv_progressDrafts;
    UIImageView* m_iv_progressPhotos;
    UIImageView* m_iv_progressCaptions;
    UIImageView* m_iv_progressPoints;
    UIImageView* m_iv_editorMinimumLine;
    UIImageView* m_iv_userBestLine;
    
    UIPointsProgressBar* m_v_pointsProgressBar;
    
    UIView* m_v_leaderboardContainer;
    UILeaderboard3Up* m_v_leaderboard3Up;
    UIButton* m_btn_leaderboard3UpButton;
    
    UIButton* m_btn_follow;
    
    User*       m_user;
    NSNumber*   m_userID;
    
    Leaderboard*    m_allLeaderboard;
    Leaderboard*    m_friendsLeaderboard;
    Leaderboard*    m_pairsLeaderboard;
    
    CloudEnumerator* m_profileCloudEnumerator;
    CloudEnumerator* m_allLeaderboardCloudEnumerator;
    CloudEnumerator* m_friendsLeaderboardCloudEnumerator;
    CloudEnumerator* m_pairsLeaderboardCloudEnumerator;
}

@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePicture;
@property (nonatomic, retain) IBOutlet UIButton* btn_changeProfilePicture;
@property (nonatomic, retain) UICameraActionSheet*      cameraActionSheet;

@property (nonatomic, retain) IBOutlet UILabel* lbl_username;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevelDate;

@property (nonatomic, retain) IBOutlet UIButton* btn_numPages;
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
@property (nonatomic, retain) IBOutlet UILabel* lbl_pointsLast7Days;

@property (atomic, retain) User* user;
@property (atomic, retain) NSNumber* userID;

@property (nonatomic, retain) IBOutlet UIImageView* iv_progressBarContainer;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressDrafts;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPhotos;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressCaptions;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPoints;
@property (nonatomic, retain) IBOutlet UIImageView* iv_editorMinimumLine;
@property (nonatomic, retain) IBOutlet UIImageView* iv_userBestLine;

@property (nonatomic, retain) IBOutlet UIPointsProgressBar* v_pointsProgressBar;

@property (nonatomic, retain) IBOutlet UIView*              v_leaderboardContainer;
@property (nonatomic, retain) IBOutlet UILeaderboard3Up*    v_leaderboard3Up;
@property (nonatomic, retain) IBOutlet UIButton*            btn_leaderboard3UpButton;

@property (nonatomic, retain) IBOutlet UIButton*    btn_follow;

@property (nonatomic, retain) Leaderboard*          allLeaderboard;
@property (nonatomic, retain) Leaderboard*          friendsLeaderboard;
@property (nonatomic, retain) Leaderboard*          pairsLeaderboard;

@property (nonatomic, retain) CloudEnumerator*      profileCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*      allLeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*      friendsLeaderboardCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*      pairsLeaderboardCloudEnumerator;

- (IBAction) onLeaderboardButtonPressed:(id)sender;
- (IBAction) onChangeProfilePictureButtonPressed:(id)sender;
- (IBAction) onPublishedButtonPressed:(id)sender;
- (IBAction) onFollowersButtonPressed:(id)sender;
- (IBAction) onFollowingButtonPressed:(id)sender;
- (IBAction) onFollowButtonPressed:(id)sender;
- (IBAction)onInfoButtonPressed:(id)sender;


- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl*)segmentedControl;

+ (ProfileViewController*)createInstance;
+ (ProfileViewController*)createInstanceForUser:(NSNumber*)userID;

@end
