//
//  PeopleListViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PeopleListViewController : BaseViewController < UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate > {

    //CloudEnumerator* m_cloudFollowEnumerator;
    CloudEnumerator* m_cloudFollowersEnumerator;
    CloudEnumerator* m_cloudFollowingEnumerator;
    
    NSNumber* m_userID;
    int m_listType;
    
    UITableView* m_tbl_peopleList;
    UIButton* m_btn_follow;
    
}

@property (nonatomic,retain) NSFetchedResultsController*    frc_follows;
//@property (nonatomic,retain) CloudEnumerator*               cloudFollowEnumerator;
@property (nonatomic,retain) CloudEnumerator*               cloudFollowersEnumerator;
@property (nonatomic,retain) CloudEnumerator*               cloudFollowingEnumerator;

@property (atomic, retain) NSNumber*                        userID;
@property                  int                              listType;

@property (nonatomic,retain) UIButton*                      btn_follow;
@property (nonatomic,retain) IBOutlet UITableView*          tbl_peopleList;

+ (PeopleListViewController*)createInstanceOfListType:(int)listType withUserID:(NSNumber*)userID;

@end
