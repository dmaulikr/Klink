//
//  UIProductionLogTableViewCell.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/17/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"

@interface UIProductionLogTableViewCell : UITableViewCell < NSFetchedResultsControllerDelegate > {
    NSNumber*       m_pageID;
    UITableViewCell* m_productionLogTableViewCell;
    
    UIImageView*    m_iv_photo;
    UILabel*        m_lbl_draftTitle;
    UILabel*        m_lbl_deadline;
    //UILabel*        m_lbl_numPhotos;
    UIImageView*    m_iv_captionIcon;
    UILabel*        m_lbl_numCaptions;
    UIButton*       m_btn_unreadCaptionsBadge;
    
    NSNumber*       m_topVotedPhotoID;
    
    NSDate*         m_deadline;
    
    NSTimer*        m_deadlineTimer;
}

@property (nonatomic, retain) NSNumber*                     pageID;

@property (nonatomic, retain) IBOutlet UITableViewCell*     productionLogTableViewCell;
@property (nonatomic, retain) IBOutlet UIImageView*         iv_photo;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_draftTitle;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_deadline;
//@property (nonatomic, retain) IBOutlet UILabel*             lbl_numPhotos;
@property (nonatomic, retain) IBOutlet UIImageView*         iv_captionIcon;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_numCaptions;
@property (nonatomic, retain) IBOutlet UIButton*            btn_unreadCaptionsBadge;

@property (nonatomic, retain)          NSNumber*            topVotedPhotoID;

@property (nonatomic, retain)          NSDate*              deadline;

@property (nonatomic, retain)          NSTimer*             deadlineTimer;

@property (nonatomic, retain)          EventManager*        eventManager;

- (void) renderDraftWithID:(NSNumber*)pageID;
+ (NSString*) cellIdentifier;

@end
