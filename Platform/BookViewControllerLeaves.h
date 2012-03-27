//
//  BookViewControllerLeaves.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudEnumerator.h"
#import "BookPageViewController.h"
#import "HomeViewController.h"
#import "MBProgressHUD.h"
#import "LeavesViewController.h"
#import "UIResourceLinkButton.h"
#import "BookLastPageViewController.h"

@interface BookViewControllerLeaves : LeavesViewController < BookPageViewControllerDelegate, HomeViewControllerDelegate, LeavesViewDataSource, LeavesViewDelegate, BookLastPageViewControllerDelegate > {
    
    NSTimer*        m_controlVisibilityTimer;
    BOOL            m_controlsHidden;
    
    UIResourceLinkButton* m_btn_writtenBy;
    UIResourceLinkButton* m_btn_illustratedBy;
    
    UIButton*   m_btn_readButton;
    UIButton*   m_btn_productionLogButton;
    UIButton*   m_btn_writersLogButton;
    
    UIButton*   m_btn_userReadButton;
    UIButton*   m_btn_userWritersLogButton;
    UIButton*   m_btn_userWritersLogButtonLastPage;
    
    UIButton*   m_btn_homeButton;
    UIButton*   m_btn_tableOfContentsButton;
    UIButton*   m_btn_zoomOutPhoto;
    UIButton*   m_btn_facebookButton;
    UIButton*   m_btn_twitterButton;
}

@property (nonatomic,retain) NSTimer*               controlVisibilityTimer;

@property (nonatomic,retain) UIResourceLinkButton*  btn_writtenBy;
@property (nonatomic,retain) UIResourceLinkButton*  btn_illustratedBy;

@property (nonatomic,retain) IBOutlet UIButton*     btn_readButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_productionLogButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_writersLogButton;

@property (nonatomic,retain) IBOutlet UIButton*     btn_userReadButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_userWritersLogButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_userWritersLogButtonLastPage;

@property (strong, nonatomic) IBOutlet UIButton*    btn_homeButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_tableOfContentsButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_zoomOutPhoto;
@property (strong, nonatomic) IBOutlet UIButton*    btn_facebookButton;
@property (strong, nonatomic) IBOutlet UIButton*    btn_twitterButton;

- (void) showNotificationViewController;

+ (BookViewControllerLeaves*) createInstance;
+ (BookViewControllerLeaves*) createInstanceWithPageID:(NSNumber*)pageID;

@end
