//
//  CustomVie2.m
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CustomVie2.h"


@implementation CustomVie2
@synthesize label;
@synthesize view;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomVie2" owner:self options:nil];
        [self addSubview:view];
        self.frame = frame;
        
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomVie2" owner:self options:nil];
        [self addSubview:view];

    }
    return self;
}

- (id) init {
    if ((self = [super init])) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomVie2" owner:self options:nil];
        [self addSubview:view];
        
    }
    return self;
}

- (void) setIndexNumber:(NSString*)text {
    self.label.text =text;
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
