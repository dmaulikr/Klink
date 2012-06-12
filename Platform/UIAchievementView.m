//
//  UIMallardView.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/11/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIAchievementView.h"

@implementation UIAchievementView
@synthesize view    = m_view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIAchievementView" owner:self options:nil];
        
        if (topLevelObjs == nil) {
            NSLog(@"Error, could not load UIAchievementView");
        }
        
        [self addSubview:self.view];
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

@end
