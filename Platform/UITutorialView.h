//
//  UITutorialView.h
//  Platform
//
//  Created by Jordan Gurrieri on 6/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITutorialView : UIView {
    UIView* m_view;
}

@property (nonatomic,retain) IBOutlet UIView* view;

- (id)initWithFrame:(CGRect)frame withNibNamed:(NSString *)nibName;

@end
