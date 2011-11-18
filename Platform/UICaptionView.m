//
//  UICaptionView.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/18/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICaptionView.h"

@implementation UICaptionView
@synthesize view = m_view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UICaptionView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UICaptionView file.\n");
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
