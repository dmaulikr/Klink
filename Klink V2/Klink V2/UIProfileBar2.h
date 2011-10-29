//
//  UIProfileBar2.h
//  Klink V2
//
//  Created by Jordan Gurrieri on 10/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIProfileBar2 : UIView <NSFetchedResultsControllerDelegate> {
    UILabel* lbl_userName;
    UILabel* lbl_votes;
    UILabel* lbl_captions;
    UILabel* lbl_newVotes;
    UIImageView* iv_newVotesBadgeSingleDigit;
    UIImageView* iv_newVotesBadgeDoubleDigit;
    UILabel* lbl_newCaptions;
    UIImageView* iv_newCaptionsBadgeSingleDigit;
    UIImageView* iv_newCaptionsBadgeDoubleDigit;
    UIImageView* img_profilePic;
    UIButton* btn_cameraButton;
    UIViewController* m_viewController;
}

@property (nonatomic, retain) IBOutlet UILabel*     lbl_userName;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_votes;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_captions;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_newVotes;
@property (nonatomic, retain) IBOutlet UIImageView* iv_newVotesBadgeSingleDigit;
@property (nonatomic, retain) IBOutlet UIImageView* iv_newVotesBadgeDoubleDigit;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_newCaptions;
@property (nonatomic, retain) IBOutlet UIImageView* iv_newCaptionsBadgeSingleDigit;
@property (nonatomic, retain) IBOutlet UIImageView* iv_newCaptionsBadgeDoubleDigit;
@property (nonatomic, retain) IBOutlet UIImageView* img_profilePic;
@property (nonatomic, retain) IBOutlet UIButton*    btn_cameraButton;
@property (nonatomic, retain) UIViewController*     viewController;
@property (nonatomic, retain) NSFetchedResultsController* frc_loggedInUser;

- (void)updateLabels;
- (void)animateNewCaption;
- (IBAction) onCameraButtonPressed:(id)sender;

@end
