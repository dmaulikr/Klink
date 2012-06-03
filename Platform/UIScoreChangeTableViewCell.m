//
//  UIScoreChangeTableViewCell.m
//  Platform
//
//  Created by Jasjeet Gill on 5/31/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UIScoreChangeTableViewCell.h"

@implementation UIScoreChangeTableViewCell
@synthesize tableCellView       = m_tableCellView;
@synthesize lbl_score           = m_lbl_score;
@synthesize lbl_description     = m_lbl_description;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UIScoreChangeTableViewCell" owner:self options:nil];
        
        if (topLevelObjs == nil) {
            NSLog(@"Could not load UIScoreChangeTableViewCell");
        }
        
        [self.contentView addSubview:self.tableCellView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kFontSize   13
#define kCellWidth  228

- (void) renderScoreChange:(ScoreJustification *)scoreJustification
{
//    CGSize maximumLabelSize = CGSizeMake(200, 9999);
//    CGSize expectedLabelSize = [[attributeChange.scorejustifications objectAtIndex:0]sizeWithFont:self.lbl_description.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
//    
//    CGRect newFrame = self.lbl_description.frame;
//    newFrame.size.height = expectedLabelSize.height;
//    newFrame.size.width = expectedLabelSize.width;
//    self.lbl_description.frame = newFrame;
    
   
   
    NSString *text = scoreJustification.justification;
    UIFont *font = [UIFont fontWithName:@"American Typewriter" size:kFontSize];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(kCellWidth, 10000)];
    self.lbl_description.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.lbl_score.frame = CGRectMake(self.lbl_score.frame.origin.x,self.lbl_description.frame.origin.y,self.lbl_score.frame.size.width,size.height);
    
    self.lbl_score.text = [NSString stringWithFormat:@"+%@",scoreJustification.points];
    self.lbl_description.text = text;
    

}

@end
