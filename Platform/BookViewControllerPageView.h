//
//  BookViewControllerPageView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewControllerBase.h"
#import "BookPageViewController.h"
#import "HomeViewController.h"
#import "BookLastPageViewController.h"

@interface BookViewControllerPageView : BookViewControllerBase < UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, BookPageViewControllerDelegate, HomeViewControllerDelegate, BookLastPageViewControllerDelegate > {
    
    UIPageViewController* m_pageController;
    
    UITapGestureRecognizer* m_tapGesture;
    //UISwipeGestureRecognizer* m_swipeGesture;
    
}

@property (strong, nonatomic) UIPageViewController* pageController;

@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
//@property (strong, nonatomic) UISwipeGestureRecognizer* swipeGesture;

+ (BookViewControllerPageView*) createInstance;
+ (BookViewControllerPageView*) createInstanceWithPageID:(NSNumber*)pageID;

@end
