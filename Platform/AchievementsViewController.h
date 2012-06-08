//
//  AchievementsViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AchievementsViewController : UIViewController < UIScrollViewDelegate > {
    UIScrollView* m_sv_scrollView;
}

@property (nonatomic,retain) IBOutlet UIScrollView* sv_scrollView;

+ (AchievementsViewController*)createInstance;

@end
