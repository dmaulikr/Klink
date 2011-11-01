//
//  UIPageView.h
//  Platform
//
//  Created by Bobby Gill on 10/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIPageView : UIView {
    NSNumber* m_pageID;
}

@property (nonatomic,retain)  UILabel*      lbl_title;
@property (nonatomic,retain)  UILabel*      lbl_caption;
@property (nonatomic,retain)  UIImageView*  img_photo;
@property (nonatomic,retain)  UILabel*      lbl_photoby;
@property (nonatomic,retain)  UILabel*      lbl_captionby;
@property (nonatomic,retain)  NSNumber*     pageID;


- (void) renderPageWithID:(NSNumber*)pageID;
@end
