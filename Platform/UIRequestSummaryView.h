//
//  UIRequestSummaryView.h
//  Platform
//
//  Created by Jasjeet Gill on 4/16/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIRequestSummaryView : UIView
{
    UIView* m_view;
    UILabel* m_lbl_scoreIncrement;
    UILabel* m_lbl_totalScore;
    UILabel* m_lbl_oldScore;
}

@property (nonatomic,retain) IBOutlet UIView* view;
@property (nonatomic,retain) IBOutlet UILabel* lbl_scoreIncrement;
@property (nonatomic,retain) IBOutlet UILabel* lbl_totalScore;
@property (nonatomic,retain) IBOutlet UILabel* lbl_oldScore;

- (void) renderCompletedRequests:(NSArray*)completedRequests;

@end
