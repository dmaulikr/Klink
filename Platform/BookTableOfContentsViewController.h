//
//  BookTableOfContentsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 1/27/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@class BookTableOfContentsViewController;

@interface BookTableOfContentsViewController : BaseViewController < NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource > {
    UITableView* m_tbl_tOCTableView;
    
    UIButton* m_btn_tableOfContentsButton;
}

@property (nonatomic,retain) NSFetchedResultsController*    frc_published_pages;

@property (nonatomic, retain) IBOutlet UITableView*         tbl_tOCTableView;
@property (nonatomic, retain) IBOutlet UIButton*            btn_tableOfContentsButton;

- (IBAction) onTOCButtonPressed:(id)sender;

+ (BookTableOfContentsViewController*)createInstance;

@end
