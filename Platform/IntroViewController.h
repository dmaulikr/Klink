//
//  IntroViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntroViewControllerDelegate

@required
    
@end

@interface IntroViewController : UIViewController {
    id<IntroViewControllerDelegate> m_delegate;
    
    UIButton* m_btn_read;
    UIButton* m_btn_write;
}

@property (nonatomic, retain) IBOutlet UIButton* btn_read;
@property (nonatomic, retain) IBOutlet UIButton* btn_write;

- (IBAction) onReadButtonPressed:(id)sender;
- (IBAction) onWriteButtonPressed:(id)sender;

+ (IntroViewController*)createInstance;

@end
