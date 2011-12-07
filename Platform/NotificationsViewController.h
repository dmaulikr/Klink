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
    EGORefreshTableHeaderView*  m_refreshHeader;
}

@property (nonatomic,retain) NSFetchedResultsController*   frc_notifications;
@property (nonatomic,retain) EGORefreshTableHeaderView*    refreshHeader;

+ (NotificationsViewController*)createInstance;

@end
