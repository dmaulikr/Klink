//
//  UIProfileBar.h
//  Klink V2
//
//  Created by Bobby Gill on 7/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIProfileBar : UIView <NSFetchedResultsControllerDelegate>{
    UILabel* lbl_votes;
    UILabel* lbl_rank;
    UILabel* lbl_captions;
    UILabel* lbl_new_votes;
    UILabel* lbl_new_captions;
}

@property (nonatomic, retain) IBOutlet UILabel* lbl_votes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_rank;
@property (nonatomic, retain) IBOutlet UILabel* lbl_captions;
@property (nonatomic, retain) IBOutlet UILabel* lbl_new_votes;
@property (nonatomic, retain) IBOutlet UILabel* lbl_new_captions;
@property (nonatomic, retain) NSFetchedResultsController* frc_loggedInUser;
@property (nonatomic, retain) NSFetchedResultsController* frc_feed_photovotes;
@property (nonatomic, retain) NSFetchedResultsController* frc_feed_captionvotes;
@end
