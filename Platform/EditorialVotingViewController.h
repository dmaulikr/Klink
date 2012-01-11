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
    UIButton*   m_btn_voteButton;
    UILabel*    m_lbl_voteStatus;
    
    NSDate*     m_deadline;
    BOOL        m_userJustVoted;
    
}

@property (nonatomic, retain) NSFetchedResultsController*   frc_pollData;
@property (nonatomic, retain) NSNumber*                     poll_ID;
@property (nonatomic, retain) Poll*                         poll;

@property (nonatomic, retain) IBOutlet iCarousel*           ic_coverFlowView;
@property (nonatomic, retain) IBOutlet UIButton*            btn_voteButton;
@property (nonatomic, retain) IBOutlet UILabel*             lbl_voteStatus;

@property (nonatomic, retain)          NSDate*              deadline;
@property                              BOOL                 userJustVoted;

- (IBAction)voteButtonPressed:(id)sender;

+ (EditorialVotingViewController*) createInstanceForPoll:(NSNumber*)pollID;

@end
