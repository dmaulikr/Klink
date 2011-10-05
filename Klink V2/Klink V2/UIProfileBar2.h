//
//  UIProfileBar2.h
//  Klink V2
//
//  Created by Jordan Gurrieri on 10/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIProfileBar2 : UIView {
    UILabel* lbl_userName;
    UILabel* lbl_votes;
    UILabel* lbl_notifications;
    UIImageView* img_profilePic;
    UIButton* btn_cameraButton;
    UIViewController* m_viewController;
}

@property (nonatomic, retain) IBOutlet UILabel*     lbl_userName;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_votes;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_notifications;
@property (nonatomic, retain) IBOutlet UIImageView*     img_profilePic;
@property (nonatomic, retain) IBOutlet UIButton*    btn_cameraButton;
@property (nonatomic, retain) UIViewController*     viewController;

- (IBAction) onCameraButtonPressed:(id)sender;

@end
