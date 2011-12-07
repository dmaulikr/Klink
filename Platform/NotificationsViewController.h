//
//  NotificationsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface NotificationsViewController : BaseViewController < NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate > {
    UITableView* m_tbl_notificationsTableVIew;
    EGORefreshTableHeaderView*  m_refreshHeader;
    
    BOOL m_refreshNotificationFeedOnDownload;
}

@property (nonatomic,retain) IBOutlet UITableView*          tbl_notificationsTableView;
@property (nonatomic,retain) NSFetchedResultsController*    frc_notifications;
@property (nonatomic,retain) EGORefreshTableHeaderView*     refreshHeader;
@property                    BOOL                           refreshNotificationFeedOnDownload;

+ (NotificationsViewController*)createInstance;
+ (NotificationsViewController*)createInstanceAndRefreshFeedOnAppear; 

@end
