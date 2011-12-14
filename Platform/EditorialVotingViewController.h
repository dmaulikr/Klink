//
//  EditorialVotingViewController.h
//  Platform
//
//  Created by Jasjeet Gill on 12/12/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "UIPagedViewSlider4.h"
#import "Poll.h"
@interface EditorialVotingViewController : BaseViewController <NSFetchedResultsControllerDelegate,UIPagedViewSlider2Delegate>
{
    
    UIPagedViewSlider2* m_pagedViewSlider;
    Poll*  m_poll;
    NSNumber* m_pollID;
    
}

@property (nonatomic, retain) IBOutlet UIPagedViewSlider2*   pagedViewSlider;
@property (nonatomic, retain) NSFetchedResultsController* frc_pollData;
@property (nonatomic, retain) NSNumber*             poll_ID;
@property (nonatomic, retain) Poll*                 poll;

+ (EditorialVotingViewController*) createInstanceForPoll:(NSNumber*)pollID;
@end
