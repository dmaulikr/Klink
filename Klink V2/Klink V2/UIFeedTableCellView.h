//
//  UIFeedTableCellView.h
//  Klink V2
//
//  Created by Bobby Gill on 9/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface UIFeedTableCellView : UITableViewCell {
    UILabel* m_titleLabel;
    UILabel* m_fromLabel;
    UILabel* m_dateLabel;
    UIImageView* m_imageView;
    Feed*   m_feedItem;
}

@property   (nonatomic,retain)  UILabel*    titleLabel;
@property   (nonatomic,retain)  UILabel*    dateLabel;
@property   (nonatomic,retain)  UIImageView*    imageView;
@property   (nonatomic,retain)  UILabel*    fromLabel;
@property   (nonatomic,retain)  Feed*       feedItem;
@end
