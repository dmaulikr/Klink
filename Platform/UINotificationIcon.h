//
//  UINotificationIcon.h
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINotificationIcon : UIView <NSFetchedResultsControllerDelegate> {
    UIButton*   m_btn_showNotifications;
    UILabel*    m_lbl_numberOfNotifications;
    UINavigationController* m_navigationViewController;
    
}

@property (nonatomic,retain) UIButton*                      btn_showNotifications;
@property (nonatomic,retain) UILabel*                       lbl_numberOfNotifications;
@property (nonatomic,retain) UINavigationController*        navigationViewController;
@property (nonatomic,retain) NSFetchedResultsController*    frc_notifications;

//Static initializers
+ (UINotificationIcon*) notificationIconForPageViewControllerToolbar;
@end
