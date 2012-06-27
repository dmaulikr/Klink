//
//  EditorialVotingViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Poll.h"
#import "iCarousel.h"

@interface EditorialVotingViewController : BaseViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, iCarouselDataSource, iCarouselDelegate, UIProgressHUDViewDelegate>
{
    Poll*       m_poll;
    NSNumber*   m_pollID;
    
    iCarousel*  m_ic_coverFlowView;
    UILabel*    m_lbl_voteStatus;
    
    NSDate*     m_deadline;
    //BOOL        m_userJustVoted;
    
    UIView*         m_v_votingContainerView;
    UIImageView*    m_iv_votingDraftView;
    UIButton*       m_btn_cancelVote;
    UIButton*       m_btn_confirmVote;
    
    BOOL            m_tutorialIsVisible;
    
}

@property (nonatomic, retain) NSFetchedResultsController*   frc_pollData;
@property (nonatomic, retain) NSNumber*                     poll_ID;
@property (nonatomic, retain) Poll*                         poll;

@property (nonatomic, retain) IBOutlet iCarousel*           ic_coverFlowView;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_voteStatus;

@property (nonatomic, retain)          NSDate*              deadline;
//@property                              BOOL                 userJustVoted;

@property (nonatomic, retain) IBOutlet UIView*              v_votingContainerView;
@property (nonatomic, retain) IBOutlet UIImageView*         iv_votingDraftView;
@property (nonatomic, retain) IBOutlet UIButton*            btn_cancelVote;
@property (nonatomic, retain) IBOutlet UIButton*            btn_confirmVote;

@property                              BOOL                 tutorialIsVisible;

- (IBAction)voteButtonPressed:(id)sender;
- (IBAction)cancelVoteButtonPressed:(id)sender;
- (IBAction)onInfoButtonPressed:(id)sender;

+ (EditorialVotingViewController*) createInstanceForPoll:(NSNumber*)pollID;

@end
