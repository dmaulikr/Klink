//
//  UIMallardView.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/11/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAchievementView : UIView {
    NSNumber*       m_achievementID;
    
    UIView*         m_view;
    
    UIView*         m_v_background;
    UIImageView*    m_iv_achievement;
    UILabel*        m_lbl_title;
    UILabel*        m_lbl_description;
    
    UIButton*       m_btn_close;
}

@property (nonatomic,retain) NSNumber*              achievementID;

@property (nonatomic,retain) IBOutlet UIView*       view;

@property (nonatomic,retain) IBOutlet UIView*       v_background;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_achievement;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_title;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_description;

@property (nonatomic,retain) IBOutlet UIButton*     btn_close;

- (IBAction) onCloseButtonPressed:(id)sender;

- (void) renderAchievementsWithID:(NSNumber*)achievementID;

@end
