//
//  IntroViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContributeViewController.h"

@protocol IntroViewControllerDelegate
- (void) introReadButtonPressed;
- (void) introWriteButtonPressed;
@required
    
@end

@interface IntroViewController : BaseViewController < ContributeViewControllerDelegate > {
    id<IntroViewControllerDelegate> m_delegate;
    
    UIButton*   m_btn_read;
    UIButton*   m_btn_write;
    
    BOOL        m_isReturningFromLogin;
    BOOL        m_isReturningFromContribute;
}

@property (assign) id<IntroViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIButton*    btn_read;
@property (nonatomic, retain) IBOutlet UIButton*    btn_write;

@property                              BOOL         isReturningFromLogin;
@property                              BOOL         isReturningFromContribute;

- (IBAction) onReadButtonPressed:(id)sender;
- (IBAction) onWriteButtonPressed:(id)sender;

+ (IntroViewController*)createInstance;

@end
