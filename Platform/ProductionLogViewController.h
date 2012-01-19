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

@interface ProductionLogViewController : BaseViewController < UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,EGORefreshTableHeaderDelegate,CloudEnumeratorDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate > {
    
    UITableView* m_tbl_productionTableView;
    CloudEnumerator* m_cloudDraftEnumerator;
    UITableViewCell* m_productionTableViewCell;
    EGORefreshTableHeaderView* m_refreshHeader;
    UILabel* m_lbl_title;
    UILabel* m_lbl_numDraftsTotal;
    UILabel* m_lbl_numDraftsClosing;
    NSNumber* m_selectedDraftID;
    
    UIView*     m_v_typewriter;
    UIButton*   m_btn_profileButton;
    UIButton*   m_btn_newPageButton;
    UIButton*   m_btn_notificationsButton;
    BOOL        m_shouldOpenTypewriter;
    BOOL        m_shouldCloseTypewriter;
    
    UISwipeGestureRecognizer* m_swipeGesture;
    
}

@property (nonatomic, retain) IBOutlet UITableView*         tbl_productionTableView;
@property (nonatomic, retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic, retain) CloudEnumerator*              cloudDraftEnumerator;
@property (nonatomic, retain) IBOutlet UITableViewCell*     productionTableViewCell;
@property (nonatomic, retain) EGORefreshTableHeaderView*    refreshHeader;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_title;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_numDraftsTotal;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_numDraftsClosing;
@property (nonatomic, retain) NSNumber*                     selectedDraftID;

@property (strong, nonatomic) IBOutlet UIView*      v_typewriter;
@property (strong, nonatomic) IBOutlet UIButton*    btn_profileButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_newPageButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_notificationsButton;
@property (nonatomic)                  BOOL         shouldOpenTypewriter;
@property (nonatomic)                  BOOL         shouldCloseTypewriter;

@property (strong, nonatomic) UISwipeGestureRecognizer*  swipeGesture;

- (IBAction) onProfileButtonPressed:(id)sender;
- (IBAction) onPageButtonPressed:(id)sender;
- (IBAction) onNotificationsButtonClicked:(id)sender;


@end
