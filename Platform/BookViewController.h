//
//  BookViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CloudEnumerator.h"

@interface BookViewController : BaseViewController < NSFetchedResultsControllerDelegate, UIPageViewControllerDataSource > {
    UIPageViewController* m_pageController;
    NSArray* m_pageContent;
    
    NSNumber*           m_pageID; //represents the ID of the page which the view controller is currently displaying
    CloudEnumerator*    m_pageCloudEnumerator;
    
    NSTimer*            m_controlVisibilityTimer;
    
}

@property (strong, nonatomic) UIPageViewController* pageController;
@property (strong, nonatomic) NSArray*              pageContent;

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSFetchedResultsController*    frc_published_pages;
@property (nonatomic,retain) CloudEnumerator*               pageCloudEnumerator;

@property (nonatomic,retain) NSTimer*                       controlVisibilityTimer;

+ (BookViewController*) createInstance;

@end
