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
- (IBAction) onUserWritersLogButtonClicked:(id)sender;
@end

@interface BookLastPageViewController : BaseViewController < NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate > {
    id<BookLastPageViewControllerDelegate> m_delegate;
    
    CloudEnumerator* m_cloudDraftEnumerator;
    
    UIButton*       m_btn_homeButton;
    UIButton*       m_btn_tableOfContentsButton;
    UILabel*        m_lbl_statementLabel;
    UIButton*       m_btn_productionLogButton;
    UILabel*        m_lbl_numDrafts;
    
    NSNumber*       m_userID; //represents the ID of the user if we are tring to build a book just of a specific user's published pages
    UIButton*       m_btn_userWritersLogButton;
    UILabel*        m_lbl_userWritersLogSubtext;

}

@property (assign) id<BookLastPageViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic,retain) CloudEnumerator*              cloudDraftEnumerator;

@property (nonatomic,retain) IBOutlet UIButton*     btn_homeButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_tableOfContentsButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_statementLabel;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numDrafts;

@property (nonatomic,retain) NSNumber*              userID;
@property (nonatomic,retain) IBOutlet UIButton*     btn_userWritersLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_userWritersLogSubtext;

+ (BookLastPageViewController*)createInstance;
+ (BookLastPageViewController*)createInstanceWithUserID:(NSNumber*)userID;

@end
