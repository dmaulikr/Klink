//
//  UIProgressHUDView.h
//  Platform
//
//  Created by Bobby Gill on 11/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UIProgressHUDView : MBProgressHUD {
    UIView* m_backgroundView;
}

- (id) initWithView:(UIView *)view;
@property (nonatomic,retain) UIView*    backgroundView;
@end
