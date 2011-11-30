//
//  ProductionLogViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ProductionLogViewController : BaseViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    UITableView* m_tbl_productionTableView;
    
    UITableViewCell* m_productionTableViewCell;
    
    UILabel* m_lbl_numDraftsTotal;
    UILabel* m_lbl_numDraftsClosing;
}

@property (nonatomic, retain) IBOutlet UITableView* tbl_productionTableView;
@property (nonatomic, retain) NSFetchedResultsController* frc_draft_pages;

@property (nonatomic, retain) IBOutlet UITableViewCell* productionTableViewCell;

@property (nonatomic, retain) IBOutlet UILabel* lbl_numDraftsTotal;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numDraftsClosing;

@end
