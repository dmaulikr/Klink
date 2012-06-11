//
//  AchievementsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AchievementsViewController : BaseViewController < UIScrollViewDelegate, CloudEnumeratorDelegate, NSFetchedResultsControllerDelegate > {
    NSNumber*       m_userID;
    
    CloudEnumerator* m_achivementCloudEnumerator;
    
    UIScrollView*   m_sv_scrollView;
}

@property (nonatomic, retain) NSFetchedResultsController* frc_achievements;
@property (atomic, retain) NSNumber* userID;
@property (nonatomic, retain) CloudEnumerator* achievementCloudEnumerator;

@property (nonatomic, retain) IBOutlet UIScrollView* sv_scrollView;

+ (AchievementsViewController*)createInstance;
+ (AchievementsViewController*)createInstanceForUserWithID:(NSNumber *)userID;

@end
