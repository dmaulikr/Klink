//
//  HomeViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface HomeViewController : UIViewController {
    UIButton*   m_readButton;
    UIButton*   m_contributeButton;
}

@property (nonatomic,retain) IBOutlet UIButton* readButton;
@property (nonatomic,retain) IBOutlet UIButton* contributeButton;

- (IBAction) onReadButtonClicked:(id)sender;
- (IBAction) onContributeButtonClicked:(id)sender;
@end
