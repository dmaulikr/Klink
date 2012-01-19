//
//  HomeViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class HomeViewController;

@protocol HomeViewControllerDelegate

@required
- (IBAction) onReadButtonClicked:(id)sender;
- (IBAction) onProductionLogButtonClicked:(id)sender;
- (IBAction) onWritersLogButtonClicked:(id)sender;
@end

@interface HomeViewController : BaseViewController < NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate > {
    id<HomeViewControllerDelegate> m_delegate;
    
    CloudEnumerator* m_cloudDraftEnumerator;
    UIButton*       m_btn_readButton;
    UIButton*       m_btn_productionLogButton;
    UIButton*       m_btn_writersLogButton;
    
    UILabel*        m_lbl_numDrafts;
    UILabel*        m_lbl_writersLogSubtext;
    UILabel*        m_lbl_numContributors;
    
}

@property (assign) id<HomeViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic,retain) CloudEnumerator*              cloudDraftEnumerator;
@property (nonatomic,retain) IBOutlet UIButton*     btn_readButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_writersLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numDrafts;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_writersLogSubtext;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numContributors;

+ (HomeViewController*) createInstance;

@end
