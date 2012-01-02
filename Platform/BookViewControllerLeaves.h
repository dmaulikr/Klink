//
//  BookViewControllerLeaves.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudEnumerator.h"
#import "MBProgressHUD.h"
#import "LeavesViewController.h"
#import "UIResourceLinkButton.h"

@interface BookViewControllerLeaves : LeavesViewController {
    UIImageView* m_iv_backgroundLeaves;
    UIResourceLinkButton* m_btn_writtenBy;
    UIResourceLinkButton* m_btn_illustratedBy;
}
@property (nonatomic,retain) UIResourceLinkButton* btn_writtenBy;
@property (nonatomic,retain) UIResourceLinkButton* btn_illustratedBy;
@property (nonatomic, retain) IBOutlet UIImageView* iv_backgroundLeaves;

+ (BookViewControllerLeaves*) createInstance;
+ (BookViewControllerLeaves*) createInstanceWithPageID:(NSNumber*)pageID;

@end
