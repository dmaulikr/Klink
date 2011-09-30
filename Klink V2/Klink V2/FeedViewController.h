//
//  FeedViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 9/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlinkBaseViewController.h"
#import "FeedTypes.h"
#import "ImageDownloadProtocol.h"
#import "EGORefreshTableHeaderView.h"
#import "NotificationNames.h"
@interface FeedViewController : KlinkBaseViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, ImageDownloadCallback,EGORefreshTableHeaderDelegate> {
    UITableView*                m_feedTable;
    EGORefreshTableHeaderView*  m_refreshHeader;
    int                         m_feedType;
}

@property   (nonatomic,retain)  UITableView*                feedTable;
@property                       int                         feedType;
@property   (nonatomic,retain)  EGORefreshTableHeaderView*  refreshHeader;
@property   (nonatomic,retain)  NSFetchedResultsController* frc_feeds;


- (id) initWithFeedType:(int)feedType;
@end
