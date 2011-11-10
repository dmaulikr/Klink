//
//  DraftViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPagedViewSlider4.h"
#import "CloudEnumerator.h"

@interface DraftViewController : BaseViewController <NSFetchedResultsControllerDelegate, UIPagedViewSlider2Delegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSNumber*           m_pageID; //represents the ID of the page which the view controller is currently displaying
    UIPagedViewSlider2* m_pagedViewSlider; //will use to flip between pages
    CloudEnumerator*    m_pageCloudEnumerator;    
}

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSFetchedResultsController*    frc_draft_pages;
@property (nonatomic,retain) UIPagedViewSlider2*            pagedViewSlider;
@property (nonatomic,retain) CloudEnumerator*               pageCloudEnumerator;

+ (DraftViewController*) createInstance;

@end
