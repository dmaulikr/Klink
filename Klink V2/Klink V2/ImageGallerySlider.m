//
//  ImageGallerySlider.m
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ImageGallerySlider.h"


@implementation ImageGallerySlider

@synthesize imageView1;
@synthesize imageView2;
@synthesize imageView3;
@synthesize imageView4;
@synthesize imageView5;
@synthesize view;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSBundle mainBundle] loadNibNamed:@"ImageGallerySlider" owner:self options:nil];
        [self addSubview:view];
        
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
