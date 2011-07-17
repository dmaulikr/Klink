//
//  UIProfileBar.m
//  Klink V2
//
//  Created by Bobby Gill on 7/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProfileBar.h"


@implementation UIProfileBar
@synthesize lbl_rank;
@synthesize lbl_votes;
@synthesize lbl_captions;

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UIProfileBar" owner:self options:nil];
        
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
