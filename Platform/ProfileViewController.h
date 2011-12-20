//
//  ProfileViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ProfileViewController : BaseViewController {
    UILabel* m_lbl_username;
    UILabel* m_lbl_employeeStartDate;
    UILabel* m_lbl_currentLevel;
    UILabel* m_lbl_currentLevelDate;
    UILabel* m_lbl_numPages;
    UILabel* m_lbl_numVotes;
    UILabel* m_lbl_numSubmissions;
    UILabel* m_lbl_pagesLabel;
    UILabel* m_lbl_votesLabel;
    UILabel* m_lbl_submissionsLabel;
    UILabel* m_lbl_submissionsLast7DaysLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* lbl_username;
@property (nonatomic, retain) IBOutlet UILabel* lbl_employeeStartDate;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_currentLevelDate;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numPages;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numSubmissions;
@property (nonatomic, retain) IBOutlet UILabel* lbl_pagesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_votesLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_submissionsLabel;
@property (nonatomic, retain) IBOutlet UILabel* lbl_submissionsLast7DaysLabel;

+ (ProfileViewController*)createInstance;

@end
