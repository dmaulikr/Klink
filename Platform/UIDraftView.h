//
//  UIDraftView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDraftView : UIView <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSNumber* m_pageID;
    UITableView* m_tbl_draftTableView;
    
    UITableViewCell* m_draftTableViewCellLeft;
    
    UINavigationController* m_navigationController;
}

@property (nonatomic,retain) NSNumber* pageID;
@property (nonatomic,retain) IBOutlet UITableView* tbl_draftTableView;
@property (nonatomic,retain) NSFetchedResultsController* frc_photos;

@property (nonatomic, retain) IBOutlet UITableViewCell* draftTableViewCellLeft;

@property (nonatomic, retain) UINavigationController* navigationController;

- (void) renderDraftWithID:(NSNumber *)pageID;

//- (id)initWithFrame:(CGRect)frame withStyle:(UITableViewCellStyle)style withPageID:(NSNumber*)pageID;
- (id)initWithFrame:(CGRect)frame withStyle:(UITableViewCellStyle)style;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
