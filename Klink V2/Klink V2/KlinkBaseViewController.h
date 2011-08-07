//
//  KlinkBaseViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIProfileBar.h"

@interface KlinkBaseViewController : UIViewController {
    IBOutlet UIProfileBar* m_profileBar_landscape;
    IBOutlet UIProfileBar* m_profileBar_portrait;
    UIView* m_v_landscape;
    UIView* m_v_portrait;
    
    int m_profileBar_landscape_height;
    int m_profileBar_portrait_height;
}
@property (nonatomic,retain)  UIProfileBar* profileBar;
@property (readonly) int profileBarHeight;
@property (nonatomic,retain) IBOutlet UIView* v_landscape;
@property (nonatomic,retain) IBOutlet UIView* v_portrait;


- (void) onUserLoggedIn;
- (void) onUserLoggedOut;
- (void) enumerateFeed;
- (void) didRotate:(NSNotification*)notification;

@end
