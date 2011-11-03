//
//  PersonalLogViewController.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PersonalLogViewController : BaseViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource> {
    UILabel*        m_lbl_title;
    UITableView*    m_tbl_notifications;
}
@property (nonatomic,retain) IBOutlet UILabel*             lbl_title;
@property (nonatomic,retain) IBOutlet UITableView*         tbl_notifications;
@property (nonatomic,retain) NSFetchedResultsController*   frc_notifications;
//Static initializers
+ (PersonalLogViewController*)createInstance;
@end
