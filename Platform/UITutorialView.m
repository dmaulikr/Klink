//
//  UITutorialView.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UITutorialView.h"

@implementation UITutorialView
@synthesize view = m_view;

- (id)initWithFrame:(CGRect)frame withNibNamed:(NSString *)nibName
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        if (topLevelObjs == nil) {
            NSLog(@"Error, could not load %@", nibName);
        }
        
        [self addSubview:self.view];
        
        // Create gesture recognizer for the view to handle a single tap
        UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)] autorelease];
        
        // Set required taps and number of touches
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the view
        [self.view addGestureRecognizer:oneFingerTap];
        
        // Enable gesture events on the achievement image view
        [self.view setUserInteractionEnabled:YES];
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

#pragma mark - UI Gesture Handlers
- (void)dismissView:(UITapGestureRecognizer *)gestureRecognizer {
    [self removeFromSuperview];
    
}

@end
