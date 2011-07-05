//
//  NoteViewCell.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NoteViewCell.h"


@implementation NoteViewCell
@synthesize lbl_Title;
@synthesize lbl_thought;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}
@end
