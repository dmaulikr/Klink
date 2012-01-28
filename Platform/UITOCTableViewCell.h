//
//  UITOCTableViewCell.h
//  Platform
//
//  Created by Jordan Gurrieri on 1/27/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITOCTableViewCell : UITableViewCell {
    NSNumber*           m_pageID;
    NSNumber*           m_pageNumber;
    
    UITableViewCell*    m_tvc_TOCTableViewCell;
    
    UILabel*        m_lbl_pageTitle;
    UILabel*        m_lbl_pageDate;
    UILabel*        m_lbl_pageNumber;
}

@property (nonatomic, retain) NSNumber* pageID;
@property (nonatomic, retain) NSNumber* pageNumber;

@property (nonatomic, retain) IBOutlet UITableViewCell* tvc_TOCTableViewCell;

@property (nonatomic, retain) IBOutlet UILabel*     lbl_pageTitle;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_pageDate;
@property (nonatomic, retain) IBOutlet UILabel*     lbl_pageNumber;

- (void) renderDraftWithID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber;

+ (NSString*) cellIdentifier;

@end
