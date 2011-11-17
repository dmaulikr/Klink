//
//  ProductionLogViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ProductionLogViewController : BaseViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    UITableView* m_tbl_productionTableView;
    
    UITableViewCell* m_productionTableViewCell;
    
    UINavigationController* m_navigationController;
}

@property (nonatomic,retain) IBOutlet UITableView* tbl_productionTableView;
@property (nonatomic,retain) NSFetchedResultsController* frc_drafts;

@property (nonatomic, retain) IBOutlet UITableViewCell* productionTableViewCell;

@property (nonatomic, retain) UINavigationController* navigationController;

@end
