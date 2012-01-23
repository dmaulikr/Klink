//
//  DraftViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EventManager.h"
#import "CloudEnumerator.h"
#import "EGORefreshTableHeaderView.h"

@interface DraftViewController : BaseViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, CloudEnumeratorDelegate, UIAlertViewDelegate> {
    NSNumber*               m_pageID;
    UIView*                 m_view;
    UILabel*                m_lbl_draftTitle;
    UILabel*                m_lbl_deadline;
    UILabel*                m_lbl_deadlineNavBar;
    NSDate*                 m_deadline;

    UITableView*            m_tbl_draftTableView;

    CloudEnumerator*        m_photoCloudEnumerator;
    CloudEnumerator*        m_captionCloudEnumerator;
    EGORefreshTableHeaderView* m_refreshHeader;
    
    UIView*     m_v_typewriter;
    UIButton*   m_btn_profileButton;
    UIButton*   m_btn_newPageButton;
    UIButton*   m_btn_notificationsButton;
    UIButton*   m_btn_notificationBadge;
    BOOL        m_shouldOpenTypewriter;
    BOOL        m_shouldCloseTypewriter;
    
    UIButton*   m_btn_backButton;
    
}

@property (nonatomic, retain) NSFetchedResultsController*    frc_photos;
@property (nonatomic, retain) NSFetchedResultsController*    frc_captions;
@property (nonatomic, retain) NSNumber*                      pageID;
@property (nonatomic, retain) IBOutlet UILabel*              lbl_draftTitle;
@property (nonatomic, retain) IBOutlet UILabel*              lbl_deadline;
@property (nonatomic, retain)          UILabel*              lbl_deadlineNavBar;
@property (nonatomic, retain)          NSDate*               deadline;
@property (nonatomic, retain) IBOutlet UITableView*          tbl_draftTableView;
@property (nonatomic, retain) CloudEnumerator*               photoCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*               captionCloudEnumerator;
@property (nonatomic, retain) EGORefreshTableHeaderView*     refreshHeader;

@property (strong, nonatomic) IBOutlet UIView*      v_typewriter;
@property (strong, nonatomic) IBOutlet UIButton*    btn_profileButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_cameraButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_notificationsButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_notificationBadge;
@property (nonatomic)                  BOOL         shouldOpenTypewriter;
@property (nonatomic)                  BOOL         shouldCloseTypewriter;

@property (nonatomic,retain) IBOutlet UIButton*     btn_backButton;

+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID;
+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID;

- (IBAction) onBackButtonPressed:(id)sender;
- (IBAction) onProfileButtonPressed:(id)sender;
- (IBAction) onCameraButtonPressed:(id)sender;
- (IBAction) onNotificationsButtonClicked:(id)sender;

@end
