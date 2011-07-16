//
//  TestSliderView.m
//  Klink V2
//
//  Created by Bobby Gill on 7/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "TestSliderView.h"


@implementation TestSliderView
@synthesize tv_DateCreated;
@synthesize tv_Other;
@synthesize tv_DisplayName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       NSArray* topLevelObjects =  [[NSBundle mainBundle] loadNibNamed:@"TestSliderView" owner:self options:nil];
        TestSliderView* sliderView = [topLevelObjects objectAtIndex:0]; 
        
        self = sliderView;
        sliderView.frame = frame;
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
