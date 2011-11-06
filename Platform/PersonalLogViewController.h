//
//  PersonalLogViewController.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"


@interface PersonalLogViewController : BaseViewController <UITableViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource,EGORefreshTableHeaderDelegate> {
    UILabel*        m_lbl_title;
    UITableView*    m_tbl_notifications;
    UILabel*        m_lbl_currentLevel;
    UILabel*        m_lbl_since;
    UILabel*        m_lbl_numcaptionslw;
    UILabel*        m_lbl_numphotoslw;
    EGORefreshTableHeaderView*  m_refreshHeader;
}
@property (nonatomic,retain) IBOutlet UILabel*             lbl_title;
@property (nonatomic,retain) IBOutlet UITableView*         tbl_notifications;
@property (nonatomic,retain) NSFetchedResultsController*   frc_notifications;
@property (nonatomic,retain) IBOutlet UILabel*             lbl_currentLevel;
@property (nonatomic,retain) IBOutlet UILabel*             lbl_since;
@property (nonatomic,retain) IBOutlet UILabel*             lbl_numcaptionslw;
@property (nonatomic,retain) IBOutlet UILabel*             lbl_numphotoslw;
@property (nonatomic,retain) EGORefreshTableHeaderView*     refreshHeader;
//Static initializers
+ (PersonalLogViewController*)createInstance;
@end
