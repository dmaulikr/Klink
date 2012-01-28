//
//  UITOCTableViewCell.m
//  Platform
//
//  Created by Jordan Gurrieri on 1/27/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "UITOCTableViewCell.h"
#import "Page.h"
#import "DateTimeHelper.h"

@implementation UITOCTableViewCell
@synthesize pageID                  = m_pageID;
@synthesize pageNumber              = m_pageNumber;
@synthesize tvc_TOCTableViewCell    = m_tvc_TOCTableViewCell;
@synthesize lbl_pageTitle           = m_lbl_pageTitle;
@synthesize lbl_pageDate            = m_lbl_pageDate;
@synthesize lbl_pageNumber          = m_lbl_pageNumber;


- (void) render {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (page != nil) {
        
        self.lbl_pageTitle.text =  page.displayname;
        
        NSDate* datePublished = [DateTimeHelper parseWebServiceDateDouble:page.datepublished];
        self.lbl_pageDate.text = [DateTimeHelper formatMediumDate:datePublished];
        
        self.lbl_pageNumber.text = [self.pageNumber stringValue];
        
    }
    [self setNeedsDisplay];
}

- (void) renderDraftWithID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber {
    self.pageID = pageID;
    self.pageNumber = pageNumber;
    
    //we also need to nil the other properties
    self.lbl_pageTitle.text = nil;
    self.lbl_pageDate.text = nil;
    self.lbl_pageNumber.text = nil;
    
    [self render];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"UITOCTableViewCell" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load UITOCTableViewCell file.\n");
        }
        
        [self.contentView addSubview:self.tvc_TOCTableViewCell];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Statics
+ (NSString*) cellIdentifier {
    return @"TOCcell";
}

@end
