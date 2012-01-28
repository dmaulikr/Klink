//
//  BookLastPageViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 1/26/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class HomeViewController;

@protocol BookLastPageViewControllerDelegate

@required
- (IBAction) onHomeButtonPressed:(id)sender;
- (IBAction) onProductionLogButtonClicked:(id)sender;
- (IBAction) onTableOfContentsButtonPressed:(id)sender;
@end

@interface BookLastPageViewController : BaseViewController < NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate > {
    id<BookLastPageViewControllerDelegate> m_delegate;
    
    CloudEnumerator* m_cloudDraftEnumerator;
    
    UIButton*       m_btn_homeButton;
    UIButton*       m_btn_tableOfContentsButton;
    UIButton*       m_btn_productionLogButton;
    UILabel*        m_lbl_numDrafts;

}

@property (assign) id<BookLastPageViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic,retain) CloudEnumerator*              cloudDraftEnumerator;

@property (nonatomic,retain) IBOutlet UIButton*     btn_homeButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_tableOfContentsButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numDrafts;

+ (BookLastPageViewController*)createInstance;

@end
