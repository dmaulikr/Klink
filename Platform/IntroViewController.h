//
//  IntroViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol IntroViewControllerDelegate
- (void) introReadButtonPressed;
- (void) introWriteButtonPressed;
@required
    
@end

@interface IntroViewController : BaseViewController {
    id<IntroViewControllerDelegate> m_delegate;
    
    UIButton* m_btn_read;
    UIButton* m_btn_write;
}

@property (assign) id<IntroViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIButton* btn_read;
@property (nonatomic, retain) IBOutlet UIButton* btn_write;

- (IBAction) onReadButtonPressed:(id)sender;
- (IBAction) onWriteButtonPressed:(id)sender;

+ (IntroViewController*)createInstance;

@end
