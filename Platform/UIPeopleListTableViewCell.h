//
//  UIPeopleListTableViewCell.h
//  Platform
//
//  Created by Jordan Gurrieri on 3/23/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPeopleListTableViewCell : UITableViewCell {
    NSNumber*           m_userID;
    
    UITableViewCell*    m_peopleListTableViewCell;
    UILabel*            m_lbl_username;
    UIImageView*        m_iv_profilePicture;
    UIButton*           m_btn_follow;
}

@property (nonatomic, retain) NSNumber*                 userID;

@property (nonatomic, retain) IBOutlet UITableViewCell* peopleListTableViewCell;
@property (nonatomic, retain) IBOutlet UILabel*         lbl_username;
@property (nonatomic, retain) IBOutlet UIImageView*     iv_profilePicture;
@property (nonatomic, retain) IBOutlet UIButton*        btn_follow;

- (void) renderCellWithUserID:(NSNumber*)userID;

+ (NSString*) cellIdentifier;

@end
