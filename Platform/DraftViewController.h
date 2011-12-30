//
//  DraftViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EventManager.h"
#import "CloudEnumerator.h"
#import "EGORefreshTableHeaderView.h"

@interface DraftViewController : BaseViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, CloudEnumeratorDelegate, UIAlertViewDelegate> {
    NSNumber*               m_pageID;
    UIView*                 m_view;
    UILabel*                m_lbl_draftTitle;
    UILabel*                m_lbl_deadline;
    NSDate*                 m_deadline;

    UITableView*            m_tbl_draftTableView;

    CloudEnumerator*        m_photoCloudEnumerator;
    CloudEnumerator*        m_captionCloudEnumerator;
    EGORefreshTableHeaderView* m_refreshHeader;
}

@property (nonatomic, retain) NSFetchedResultsController*    frc_photos;
@property (nonatomic, retain) NSNumber*                      pageID;
@property (nonatomic, retain) IBOutlet UILabel*              lbl_draftTitle;
@property (nonatomic, retain) IBOutlet UILabel*              lbl_deadline;
@property (nonatomic, retain)          NSDate*               deadline;
@property (nonatomic, retain) IBOutlet UITableView*          tbl_draftTableView;
@property (nonatomic, retain) CloudEnumerator*               photoCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*               captionCloudEnumerator;
@property (nonatomic, retain) EGORefreshTableHeaderView*     refreshHeader;

+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID;
+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID withCaptionID:(NSNumber*)captionID;

@end
