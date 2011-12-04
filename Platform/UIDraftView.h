//
//  UIDraftView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"
#import "CloudEnumerator.h"
#import "EGORefreshTableHeaderView.h"


@interface UIDraftView : UIView <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, CloudEnumeratorDelegate> {
    NSNumber*               m_pageID;
    UIView*                 m_view;
    UILabel*                m_draftTitle;
    UITableView*            m_tbl_draftTableView;
    CloudEnumerator*        m_cloudPhotoEnumerator;
    EGORefreshTableHeaderView* m_refreshHeader;
    UITableViewCell*        m_draftTableViewCellLeft;
    
    UINavigationController* m_navigationController;
}

@property (nonatomic, retain) NSFetchedResultsController*    frc_photos;
@property (nonatomic, retain) NSNumber*                      pageID;
@property (nonatomic, retain) IBOutlet UIView*               view;
@property (nonatomic, retain) IBOutlet UILabel*              draftTitle;
@property (nonatomic, retain) IBOutlet UITableView*          tbl_draftTableView;
@property (nonatomic, retain) CloudEnumerator*               cloudPhotoEnumerator;
@property (nonatomic, retain) EGORefreshTableHeaderView*     refreshHeader;
@property (nonatomic, retain) IBOutlet UITableViewCell*      draftTableViewCellLeft;

@property (nonatomic,retain) UINavigationController*       navigationController;

- (void) renderDraftWithID:(NSNumber *)pageID;

//- (id)initWithFrame:(CGRect)frame withStyle:(UITableViewCellStyle)style withPageID:(NSNumber*)pageID;
//- (id)initWithFrame:(CGRect)frame withStyle:(UITableViewCellStyle)style;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFrame:(CGRect)frame;
//- (id)initWithCoder:(NSCoder *)aDecoder;

@end
