//
//  BookViewControllerPageView.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewControllerBase.h"

@interface BookViewControllerPageView : BookViewControllerBase < UIPageViewControllerDelegate, UIPageViewControllerDataSource > {
    
    UIPageViewController* m_pageController;
    
}

@property (strong, nonatomic) UIPageViewController* pageController;

+ (BookViewControllerPageView*) createInstance;
+ (BookViewControllerPageView*) createInstanceWithPageID:(NSNumber*)pageID;
@end
