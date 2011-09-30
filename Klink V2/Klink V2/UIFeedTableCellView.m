//
//  UIFeedTableCellView.m
//  Klink V2
//
//  Created by Bobby Gill on 9/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIFeedTableCellView.h"


@implementation UIFeedTableCellView
@synthesize dateLabel;
@synthesize titleLabel;
@synthesize imageView;
@synthesize feedItem;
@synthesize fromLabel;

- (void) commontInit:(NSString*) reuseIdentifier {
    CGRect frameForImageView = CGRectMake(20, 20, 120, 120);
    self.imageView = [[UIImageView alloc]initWithFrame:frameForImageView];
    
    CGRect frameForTitleLabel = CGRectMake(148, 20, 132, 86);
    self.titleLabel = [[UILabel alloc]initWithFrame:frameForTitleLabel];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    
                                          
    
    CGRect frameForDateLabel = CGRectMake(148, 109, 132, 31);
    self.dateLabel = [[UILabel alloc]initWithFrame:frameForDateLabel];
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.dateLabel];
    reuseIdentifier = reuseIdentifier;
    
   
}

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commontInit:reuseIdentifier];
    }   
    
    return self;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self commontInit:reuseIdentifier];
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
    [self.imageView release];
    [self.dateLabel release];
    [self.titleLabel release];
    [self.fromLabel release];
}

@end
