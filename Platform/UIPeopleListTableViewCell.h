//
//  UIPeopleListTableViewCell.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPeopleListTableViewCell : UITableViewCell {
    NSNumber*           m_followID;
    int                 m_listType;
    
    UITableViewCell*    m_peopleListTableViewCell;
    UILabel*            m_lbl_username;
    UIImageView*        m_iv_profilePicture;
    UIButton*           m_btn_follow;
}

@property (nonatomic, retain) NSNumber*                 followID;
@property                    int                        listType;

@property (nonatomic, retain) IBOutlet UITableViewCell* peopleListTableViewCell;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_username;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_profilePicture;
@property (nonatomic, retain) IBOutlet UIButton*        btn_follow;

- (void) renderCellOfPeopleListType:(int)peopleListType withFollowID:(NSNumber*)followID;
- (void) renderProfilePic;

+ (NSString*) cellIdentifier;

@end
