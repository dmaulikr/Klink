//
//  ProductionLogViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "UIProductionLogTableViewCell.h"

@interface ProductionLogViewController : BaseViewController < UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,EGORefreshTableHeaderDelegate,CloudEnumeratorDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate > {
    
    UITableView* m_tbl_productionTableView;
    CloudEnumerator* m_cloudDraftEnumerator;
    UIProductionLogTableViewCell* m_productionTableViewCell;
    EGORefreshTableHeaderView* m_refreshHeader;
    UILabel* m_lbl_title;
    NSNumber* m_selectedDraftID;
    
    UIView*     m_v_typewriter;
    UIButton*   m_btn_profileButton;
    UIButton*   m_btn_newPageButton;
    UIButton*   m_btn_notificationsButton;
    UIButton*   m_btn_notificationBadge;
    BOOL        m_shouldOpenTypewriter;
    BOOL        m_shouldCloseTypewriter;
    
    UIButton*   m_btn_homeButton;
    
}

@property (nonatomic, retain) IBOutlet UITableView*         tbl_productionTableView;
@property (nonatomic, retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic, retain) CloudEnumerator*              cloudDraftEnumerator;
@property (nonatomic, retain) IBOutlet UIProductionLogTableViewCell*     productionTableViewCell;
@property (nonatomic, retain) EGORefreshTableHeaderView*    refreshHeader;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_title;
@property (nonatomic, retain) NSNumber*                     selectedDraftID;

@property (strong, nonatomic) IBOutlet UIView*      v_typewriter;
@property (strong, nonatomic) IBOutlet UIButton*    btn_profileButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_newPageButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_notificationsButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_notificationBadge;
@property (nonatomic)                  BOOL         shouldOpenTypewriter;
@property (nonatomic)                  BOOL         shouldCloseTypewriter;

@property (nonatomic,retain) IBOutlet UIButton*     btn_homeButton;


- (IBAction) onHomeButtonPressed:(id)sender;
- (IBAction) onProfileButtonPressed:(id)sender;
- (IBAction) onPageButtonPressed:(id)sender;
- (IBAction) onNotificationsButtonClicked:(id)sender;
- (void) resetRefreshTableHeaderToNormalPosition;
+ (ProductionLogViewController*)createInstance;

@end
