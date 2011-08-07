//
//  UICaptionLabel.m
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UICaptionLabel.h"


@implementation UICaptionLabel
@synthesize tv_caption;
@synthesize tv_metadata;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UICaptionLabel" owner:self options:nil];
        
        UIView* profileBar = [bundle objectAtIndex:0];
        profileBar.frame = frame;
        [self addSubview:profileBar];
        
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UICaptionLabel" owner:self options:nil];
        
        UIView* profileBar = [bundle objectAtIndex:0];
        [self addSubview:profileBar];
        
        
        
        
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
