//
//  UINotificationTableViewCell.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIResourceLinkButton.h"

@interface UINotificationTableViewCell : UITableViewCell {
    NSNumber*           m_notificationID;
    
    UITableViewCell*    m_notificationTableViewCell;
    UIResourceLinkButton* m_resourceLinkButton;
    UILabel*        m_lbl_notificationMessage;
    UILabel*        m_lbl_notificationDate;
    UIImageView*    m_iv_notificationImage;
    UIImageView*    m_iv_notificationTypeImage;
    UIImageView*    m_iv_notificationBadge;
    
    id m_target;
    SEL m_selector;
}

@property (nonatomic,retain) NSNumber*                  notificationID;

@property (nonatomic,retain) IBOutlet UITableViewCell*  notificationTableViewCell;
@property (nonatomic,retain) IBOutlet UIResourceLinkButton* resourceLinkButton;
@property (nonatomic,retain) IBOutlet UILabel*          lbl_notificationMessage;
@property (nonatomic,retain) IBOutlet UILabel*          lbl_notificationDate;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_notificationImage;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_notificationTypeImage;
@property (nonatomic,retain) IBOutlet UIImageView*      iv_notificationBadge;

@property (nonatomic,retain) id                         target;
@property                    SEL                        selector;

- (IBAction) onUsernameButtonPress:(id)sender;
- (void) renderNotificationWithID:(NSNumber*)notificationID linkClickTarget:(id)target linkClickSelector:(SEL)selector; 

+ (NSString*) cellIdentifier;

@end
