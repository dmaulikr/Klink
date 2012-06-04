//
//  UIScoreChangeTableViewCell.h
//  Platform
//
//  Created by Jasjeet Gill on 5/31/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreJustification.h"


@interface UIScoreChangeTableViewCell : UITableViewCell
{
    UITableViewCell* m_tableCellView;

    UILabel* m_lbl_description;
    UILabel* m_lbl_score;
}

@property (nonatomic,retain) IBOutlet UITableViewCell* tableCellView;
@property (nonatomic,retain) IBOutlet UILabel* lbl_description;
@property (nonatomic,retain) IBOutlet UILabel* lbl_score;

- (void) renderScoreChange:(ScoreJustification*)scoreJustification;
@end
