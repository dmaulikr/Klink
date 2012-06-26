//
//  AchievementsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface AchievementsViewController : BaseViewController < UIScrollViewDelegate, CloudEnumeratorDelegate, NSFetchedResultsControllerDelegate, UIProgressHUDViewDelegate > {
    NSNumber*       m_userID;
    NSNumber*       m_loadedAchievementID;
    
    CloudEnumerator* m_achivementCloudEnumerator;
    
    UIScrollView*   m_sv_scrollView;
    
    UIImageView*    m_iv_profilePicture;
}

@property (nonatomic, retain) NSFetchedResultsController* frc_achievements;
@property (atomic, retain) NSNumber* userID;
@property (atomic, retain) NSNumber* loadedAchievementID;
@property (nonatomic, retain) CloudEnumerator* achievementCloudEnumerator;

@property (nonatomic, retain) IBOutlet UIScrollView*    sv_scrollView;

@property (nonatomic, retain)          UIImageView*     iv_profilePicture;

- (IBAction)onInfoButtonPressed:(id)sender;
+ (AchievementsViewController*)createInstance;
+ (AchievementsViewController*)createInstanceForUserWithID:(NSNumber *)userID;
+ (AchievementsViewController*)createInstanceForUserWithID:(NSNumber *)userID preloadedWithAchievementIDorNil:(NSNumber *)achievementID;

@end
