//
//  PhotoNoteCell.m
//  Test Project 2
//
//  Created by Bobby Gill on 7/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PhotoNoteCell.h"


@implementation PhotoNoteCell
@synthesize lbl_Subtitle;
@synthesize lbl_Title;
@synthesize img_Image;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)identifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
