//
//  UINotificationTableViewCell.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINotificationTableViewCell : UITableViewCell {
    NSNumber* m_notificationID;
    
    UIImageView* m_img_notificationImage;
    UILabel*     m_lbl_notificationTitle;
    UILabel*     m_lbl_notificationMessage;
}

@property (nonatomic,retain) NSNumber* notificationID;
@property (nonatomic,retain) UILabel* lbl_notificationTitle;
@property (nonatomic,retain) UILabel* lbl_notificationMessage;
@property (nonatomic,retain) UIImageView* img_notificationImage;

- (id)initWithNotificationID:(NSNumber*)notificationID 
                   withStyle:(UITableViewCellStyle)style 
             reuseIdentifier:(NSString *)reuseIdentifier;
- (void) renderNotificationWithID:(NSNumber*)notificationID; 

+ (NSString*) cellIdentifier;
@end
