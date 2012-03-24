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

    CloudEnumerator* m_cloudFollowEnumerator;
    
    NSNumber* m_userID;
    int m_listType;
    
    UIButton* m_btn_follow;
    
}

@property (nonatomic,retain) NSFetchedResultsController*    frc_follows;
@property (nonatomic,retain) CloudEnumerator*               cloudFollowEnumerator;

@property (atomic, retain) NSNumber*                        userID;
@property                  int                              listType;

@property (nonatomic,retain) UIButton*                      btn_follow;

+ (PeopleListViewController*)createInstanceOfListType:(int)listType withUserID:(NSNumber*)userID;

@end
