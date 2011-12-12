//
//  UIProgressHUDView.m
//  Platform
//
//  Created by Bobby Gill on 11/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProgressHUDView.h"


@implementation UIProgressHUDView
@synthesize backgroundView = m_backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
            }
    return self;
}

- (id) initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
            }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
   
    [super dealloc];
}

@end
