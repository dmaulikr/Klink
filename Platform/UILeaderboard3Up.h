//
//  UILeaderboard3Up.h
//  Platform
//
//  Created by Jordan Gurrieri on 4/19/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILeaderboard3Up : UIView {
    UIView*     m_view;
    
    UILabel*    m_lbl_position1;
    UILabel*    m_lbl_position2;
    UILabel*    m_lbl_position3;
    
    UIImageView*    m_iv_profilePic1;
    UIImageView*    m_iv_profilePic2;
    UIImageView*    m_iv_profilePic3;
    
    UILabel*    m_lbl_username1;
    UILabel*    m_lbl_username2;
    UILabel*    m_lbl_username3;
    
    UILabel*    m_lbl_numPoints1;
    UILabel*    m_lbl_numPoints2;
    UILabel*    m_lbl_numPoints3;
    
    NSArray*    m_entries;
    NSNumber*   m_leaderboardID;
}

@property (nonatomic, retain) IBOutlet UIView*  view;

@property (nonatomic, retain) IBOutlet UILabel* lbl_position1;
@property (nonatomic, retain) IBOutlet UILabel* lbl_position2;
@property (nonatomic, retain) IBOutlet UILabel* lbl_position3;

@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePic1;
@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePic2;
@property (nonatomic, retain) IBOutlet UIImageView* iv_profilePic3;

@property (nonatomic, retain) IBOutlet UILabel* lbl_username1;
@property (nonatomic, retain) IBOutlet UILabel* lbl_username2;
@property (nonatomic, retain) IBOutlet UILabel* lbl_username3;

@property (nonatomic, retain) IBOutlet UILabel* lbl_numPoints1;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numPoints2;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numPoints3;

@property (nonatomic, retain) NSArray* entries;
@property (nonatomic, retain) NSNumber* leaderboardID;


- (void) renderLeaderboardWithEntries:(NSArray*)entries forLeaderboard:(NSNumber*)leaderboardID;

@end
