//
//  BookViewControllerPageView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewControllerBase.h"

@interface BookViewControllerPageView : BookViewControllerBase < UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate > {
    
    UIPageViewController* m_pageController;
    
    UIButton* m_invisibleReadButton;
    UIButton* m_invisibleProductionLogButton;
    UIButton* m_invisibleWritersLogButton;
    
    UIView* m_v_tapWritersLogView;
    
}

@property (strong, nonatomic) UIPageViewController* pageController;

@property (strong, nonatomic) UIButton* invisibleReadButton;
@property (strong, nonatomic) UIButton* invisibleProductionLogButton;
@property (strong, nonatomic) UIButton* invisibleWritersLogButton;

@property (strong, nonatomic) UIView* v_tapWritersLogView;

+ (BookViewControllerPageView*) createInstance;
+ (BookViewControllerPageView*) createInstanceWithPageID:(NSNumber*)pageID;
@end
