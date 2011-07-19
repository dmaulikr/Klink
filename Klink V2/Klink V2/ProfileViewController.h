//
//  ProfileViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/18/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIProfileBar.h"
#import "User.h"

@interface ProfileViewController : UIViewController {
    UIProfileBar* pb_ProfileBar;
    UIImageView* img_ProfilePicture;
    UIButton* btn_Pictures;
    UIButton* btn_Captions;
    
    User* user;
}

@property (nonatomic,retain) IBOutlet UIProfileBar* pb_ProfileBar;
@property (nonatomic,retain) IBOutlet UIImageView* img_ProfilePicture;
@property (nonatomic,retain) IBOutlet UIButton* btn_Pictures;
@property (nonatomic,retain) IBOutlet UIButton* btn_Captions;
@property (nonatomic,retain) User* user;
-(IBAction)btn_Pictures_Clicked:(id)sender;
-(IBAction)btn_Captions_Clicked:(id)sender;
@end
