//
//  UINotificationTableViewCell.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINotificationTableViewCell : UITableViewCell {
    NSNumber*           m_notificationID;
    UITableViewCell*    m_notificationTableViewCell;
    
    //UILabel*        m_lbl_notificationTitle;
    UILabel*        m_lbl_notificationMessage;
    UILabel*        m_lbl_notificationDate;
    UIImageView*    m_iv_notificationImage;
    UIImageView*    m_iv_notificationTypeImage;
}

@property (nonatomic,retain) NSNumber*                  notificationID;
@property (nonatomic,retain) IBOutlet UITableViewCell*  notificationTableViewCell;

//@property (nonatomic,retain) IBOutlet UILabel*          lbl_notificationTitle;
@property (nonatomic,retain) IBOutlet UILabel*          lbl_notificationMessage;
@property (nonatomic,retain) IBOutlet UILabel*          lbl_notificationDate;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_notificationImage;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_notificationTypeImage;

- (void) renderNotificationWithID:(NSNumber*)notificationID; 

+ (NSString*) cellIdentifier;

@end
