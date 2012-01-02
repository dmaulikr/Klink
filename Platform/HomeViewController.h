//
//  HomeViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContributeViewController.h"

@class CloudEnumerator;
@interface HomeViewController : BaseViewController  {
    UIButton*       m_btn_readButton;
    UIButton*       m_btn_productionLogButton;
    UIButton*       m_btn_writersLogButton;
    UIImageView*    m_iv_bookCover;
    UILabel*        m_lbl_numContributors;
//    UIButton*   m_contributeButton;
//    UIButton*   m_newDraftButton;
//    UIButton*   m_loginButton;
//    UIButton*   m_loginTwitterButton;
}

@property (nonatomic,retain) IBOutlet UIButton*     btn_readButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_writersLogButton;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_bookCover;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_numContributors;
//@property (nonatomic,retain) IBOutlet UIButton* contributeButton;
//@property (nonatomic,retain) IBOutlet UIButton* newDraftButton;
//@property (nonatomic,retain) IBOutlet UIButton* loginButton;
//@property (nonatomic,retain) IBOutlet UIButton* loginTwitterButton;

- (IBAction) onReadButtonClicked:(id)sender;
- (IBAction) onProductionLogButtonClicked:(id)sender;
- (IBAction) onWritersLogButtonClicked:(id)sender;
//- (IBAction) onContributeButtonClicked:(id)sender;
//- (IBAction) onNewDraftButtonClicked:(id)sender;
//- (IBAction) onLoginButtonClicked:(id)sender;

+ (HomeViewController*) createInstance;
@end
