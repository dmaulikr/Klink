//
//  RequestSummaryViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 5/30/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UILeaderboard3Up.h"
#import "UIPointsProgressBar.h"
#import "BaseViewController.h"
#import "Leaderboard.h"
#import "UIScoreChangeView.h"

@interface RequestSummaryViewController : BaseViewController <CloudEnumeratorDelegate>
{
    UIView* m_v_leaderboardContainer;
    UIView* m_v_scoreChangeContainer;
    UIView* m_v_achievementsContainer;
    UIView* m_v_newAchievementContainer;
    UIView* m_v_noNewAchievementContainer;
    
    UILeaderboard3Up* m_v_leaderboard3Up;
    UIButton* m_btn_leaderboard3UpButton;
    UIPointsProgressBar* m_v_pointsProgressBar;
    UIScoreChangeView*  m_v_scoreChangeView;
    
    User*       m_user;
    NSNumber*   m_userID;
    Request*    m_request;
 
    
    UIImageView* m_iv_progressBarContainer;
    UIImageView* m_iv_progressDrafts;
    UIImageView* m_iv_progressPhotos;
    UIImageView* m_iv_progressCaptions;
    UIImageView* m_iv_progressPoints;
    
    UILabel* m_lbl_achievementTitle;
    UIImageView* m_iv_achievementImage;
    
    CloudEnumerator* m_friendsLeaderboardCloudEnumerator;
    Leaderboard*    m_friendsLeaderboard;
}

@property (atomic, retain) User* user;
@property (atomic, retain) NSNumber* userID;
@property (nonatomic,retain) Request* request;

@property (nonatomic, retain) IBOutlet UIPointsProgressBar* v_pointsProgressBar;
@property (nonatomic, retain) IBOutlet UIView*              v_leaderboardContainer;
@property (nonatomic, retain) IBOutlet UILeaderboard3Up*    v_leaderboard3Up;
@property (nonatomic, retain) IBOutlet UIScoreChangeView*   v_scoreChangeView;
@property (nonatomic, retain) IBOutlet UIButton*            btn_leaderboard3UpButton;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressBarContainer;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressDrafts;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPhotos;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressCaptions;
@property (nonatomic, retain) IBOutlet UIImageView* iv_progressPoints;
@property (nonatomic, retain) IBOutlet UIImageView* iv_achievementImage;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_achievementTitle;

@property (nonatomic, retain) IBOutlet UIView* v_scoreChangeContainer;
@property (nonatomic, retain) IBOutlet UIView* v_achievementsContainer;
@property (nonatomic, retain) IBOutlet UIView* v_newAchievementContainer;
@property (nonatomic, retain) IBOutlet UIView* v_noNewAchievementContainer;

@property (nonatomic, retain) CloudEnumerator*      friendsLeaderboardCloudEnumerator;
@property (nonatomic, retain) Leaderboard*          friendsLeaderboard;


- (void) onDoneButtonPressed:(id)sender;
- (IBAction) onLeaderboardButtonPressed:(id)sender;
+ (id) createForRequests:(NSArray*)requests;
@end
