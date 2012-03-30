//
//  SettingsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "UICameraActionSheet.h"

@interface SettingsViewController : BaseViewController < UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIProgressHUDViewDelegate, UICameraActionSheetDelegate > {
    
    User*               m_user;
    NSNumber*           m_userID;
    
    UITableViewCell*    m_tc_changePictureTableViewCell;
    UITableViewCell*    m_tc_changeUsernameTableViewCell;
    UITableViewCell*    m_tc_logoutTableViewCell;
    UITableViewCell*    m_tc_emailTableViewCell;
    UITableViewCell*    m_tc_inviteTableViewCell;
    UITableViewCell*    m_tc_facebookSwitchTableViewCell;
    UILabel*            m_lbl_facebookTableViewCellLabel;
    UISwitch*           m_sw_seamlessFacebookSharing;
    
    UICameraActionSheet*    m_cameraActionSheet;
}

@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_changePictureTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_changeUsernameTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_logoutTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_emailTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_inviteTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell*     tc_facebookSwitchTableViewCell;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_facebookTableViewCellLabel;
@property (nonatomic, retain) IBOutlet UISwitch*            sw_seamlessFacebookSharing;

@property (atomic, retain)             User*                user;
@property (atomic, retain)             NSNumber*            userID;

@property (nonatomic, retain) UICameraActionSheet*      cameraActionSheet;

- (IBAction) onFacebookSeamlessSharingChanged:(id)sender;

+ (SettingsViewController*)createInstance;

@end
