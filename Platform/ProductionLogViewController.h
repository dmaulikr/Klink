//
//  ProductionLogViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface ProductionLogViewController : BaseViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,EGORefreshTableHeaderDelegate,CloudEnumeratorDelegate, UIAlertViewDelegate> {
    
    UITableView* m_tbl_productionTableView;
    CloudEnumerator* m_cloudDraftEnumerator;
    UITableViewCell* m_productionTableViewCell;
    EGORefreshTableHeaderView* m_refreshHeader;
    UILabel* m_lbl_title;
    UILabel* m_lbl_numDraftsTotal;
    UILabel* m_lbl_numDraftsClosing;
    
    UIButton
    
}

@property (nonatomic, retain) IBOutlet UITableView*         tbl_productionTableView;
@property (nonatomic, retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic, retain) CloudEnumerator*              cloudDraftEnumerator;
@property (nonatomic, retain) IBOutlet UITableViewCell*     productionTableViewCell;
@property (nonatomic, retain) EGORefreshTableHeaderView*    refreshHeader;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_title;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_numDraftsTotal;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_numDraftsClosing;


@end
