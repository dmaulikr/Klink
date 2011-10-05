//
//  KlinkBaseViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIProfileBar.h"
#import "UIProfileBar2.h"
#import "Photo.h"

@interface KlinkBaseViewController : UIViewController {
    IBOutlet UIProfileBar2* m_profileBar_landscape;
    IBOutlet UIProfileBar2* m_profileBar_portrait;
//    IBOutlet UIProfileBar2* m_profileBar2;
    UIView* m_v_landscape;
    UIView* m_v_portrait;
    
    int m_profileBar_landscape_height;
    int m_profileBar_portrait_height;
    
    Theme* m_currentTheme;
    BOOL m_shouldShowProfileBar;
    
}
@property (nonatomic,retain)            UIProfileBar2* profileBar;
//@property (nonatomic,retain)            UIProfileBar2* profileBar2;
@property (readonly)                    int profileBarHeight;
@property (nonatomic,retain) IBOutlet   UIView* v_landscape;
@property (nonatomic,retain) IBOutlet   UIView* v_portrait;
@property                               BOOL shouldShowProfileBar;
//@property                               BOOL shouldShowProfileBar2;
@property (nonatomic,retain)            NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain)            Theme* currentTheme;

- (void) onUserLoggedIn;
- (void) onUserLoggedOut;
- (void) onPhotoUploadComplete:(Photo*)photo;
- (void) onPhotoUploadStart:(Photo*)photo;
- (void) onFeedRefreshed:(NSNotification*)notification;
- (void) enumerateFeed;
- (void) didRotate:(NSNotification*)notification;
- (BOOL) deviceInPortraitOrientation;
@end
