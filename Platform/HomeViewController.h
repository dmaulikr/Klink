//
//  HomeViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "IntroViewController.h"

@class HomeViewController;

@protocol HomeViewControllerDelegate

@required
- (IBAction) onReadButtonClicked:(id)sender;
- (IBAction) onProductionLogButtonClicked:(id)sender;
- (IBAction) onWritersLogButtonClicked:(id)sender;
- (IBAction) onUserWritersLogButtonClicked:(id)sender;
@end

@interface HomeViewController : BaseViewController < NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, IntroViewControllerDelegate > {
    id<HomeViewControllerDelegate> m_delegate;
    
    CloudEnumerator* m_cloudDraftEnumerator;
    
    UIView*         m_v_defaultBookContainer;
    UIButton*       m_btn_readButton;
    UIButton*       m_btn_productionLogButton;
    UIButton*       m_btn_writersLogButton;
    UILabel*        m_lbl_numDrafts;
    UILabel*        m_lbl_writersLogSubtext;
    
    UIView*         m_v_userBookContainer;
    NSNumber*       m_userID; //represents the ID of the user if we are tring to build a book just of a specific user's published pages
    UILabel*        m_lbl_userSubtitle;
    UIImageView*    m_iv_profilePicture;
    UIButton*       m_btn_userReadButton;
    UIButton*       m_btn_userWritersLogButton;
    UILabel*        m_lbl_userWritersLogSubtext;
    
    UILabel*        m_lbl_numContributors;
    
}

@property (assign) id<HomeViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSFetchedResultsController*   frc_draft_pages;
@property (nonatomic,retain) CloudEnumerator*              cloudDraftEnumerator;

@property (nonatomic,retain) IBOutlet UIView*       v_defaultBookContainer;
@property (nonatomic,retain) IBOutlet UIButton*     btn_readButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_writersLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numDrafts;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_writersLogSubtext;

@property (nonatomic,retain) IBOutlet UIView*       v_userBookContainer;
@property (nonatomic,retain) NSNumber*              userID;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_userSubtitle;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_profilePicture;
@property (nonatomic,retain) IBOutlet UIButton*     btn_userReadButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_userWritersLogButton;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_userWritersLogSubtext;

@property (nonatomic,retain) IBOutlet UILabel*      lbl_numContributors;

- (IBAction)onInfoButtonPressed:(id)sender;

+ (HomeViewController*) createInstance;
+ (HomeViewController*) createInstanceWithUserID:(NSNumber*)userID;

@end
