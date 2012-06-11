//
//  UIScoreChangeView.h
//  Platform
//
//  Created by Jasjeet Gill on 5/31/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"
#import "AttributeChange.h"


@interface UIScoreChangeView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    UIView*         m_view;
    UILabel*        m_lbl_totalScoreChange;
    UILabel*        m_lbl_topMessage;
    UITableView*    m_tbl_scoreChanges;
    UIImageView*    m_iv_coin;
    
    Request*            m_completedRequest;
    AttributeChange*    m_scoreChangeInRequest;
    NSArray*            m_scoreJustifications;
    NSArray*            m_otherPeopleScoreJustifications;
}

@property (nonatomic,retain) IBOutlet UIView*       view;
@property (nonatomic,retain) IBOutlet UITableView*  tbl_scoreChanges;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_totalScoreChange;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_topMessage;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_coin;

@property (nonatomic,retain) Request* completedRequest;
@property (nonatomic,retain) AttributeChange* scoreChangeInRequest;
@property (nonatomic,retain) NSArray*   scoreJustifications;
@property (nonatomic,retain) NSArray*   otherPeoplesScoreJustifications;


- (void) renderCompletedRequest:(Request*)request;
+ (NSArray*) reformatOtherPeoplesScoreJustifications:(NSArray*)otherPeoplesScoreChanges;
@end
