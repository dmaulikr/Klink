//
//  BookViewControllerBase.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/22/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CloudEnumerator.h"
#import "MBProgressHUD.h"

@interface BookViewControllerBase : BaseViewController < NSFetchedResultsControllerDelegate,MBProgressHUDDelegate, CloudEnumeratorDelegate > {
    
    NSNumber*           m_pageID; //represents the ID of the page which the view controller is currently displaying
    CloudEnumerator*    m_pageCloudEnumerator;
    CloudEnumerator*    m_captionCloudEnumerator;
    
    NSTimer*            m_controlVisibilityTimer;
    BOOL                m_controlsHidden;
    
    UIBarButtonItem*    m_tb_facebookButton;
    UIBarButtonItem*    m_tb_twitterButton;
    UIBarButtonItem*    m_tb_bookmarkButton;
    UIBarButtonItem*    m_tb_notificationButton;
    
    UIImageView*        m_iv_background;
}

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSFetchedResultsController*    frc_published_pages;
@property (nonatomic,retain) CloudEnumerator*               pageCloudEnumerator;
@property (nonatomic,retain) CloudEnumerator*               captionCloudEnumerator;
@property (nonatomic,retain) NSTimer*                       controlVisibilityTimer;

// Toolbar Buttons
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_facebookButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_twitterButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_bookmarkButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_notificationButton;

@property (nonatomic,retain) IBOutlet UIImageView*          iv_background;


- (int) indexOfPageWithID:(NSNumber*)pageid;
- (void) onEnumerateComplete:(NSDictionary*)userInfo;


+ (BookViewControllerBase*) createInstance;
+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber*)pageID;
@end
