//
//  PageViewController2.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface PageViewController : BaseViewController {    
    NSNumber*       m_pageID; //represents the ID of the page which the view controller is currently displaying
    NSNumber*       m_topVotedPhotoID;
    NSNumber*       m_pageNumber;
    
    UIImageView*    m_iv_openBookPageImage;
    UILabel*        m_lbl_title;
    UIImageView*    m_iv_photo;
    UILabel*        m_lbl_caption;
    UILabel*        m_lbl_photoby;
    UILabel*        m_lbl_captionby;
    UILabel*        m_lbl_publishDate;
    UILabel*        m_lbl_pageNumber;
    
    NSTimer*        m_controlVisibilityTimer;
    BOOL            m_controlsHidden;

}




@property (nonatomic,retain) NSNumber*              pageID;
@property (nonatomic,retain) NSNumber*              topVotedPhotoID;
@property (nonatomic,retain) NSNumber*              pageNumber;

@property (nonatomic,retain) IBOutlet UIImageView*  iv_openBookPageImage;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_title;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_caption;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_photo;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_photoby;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_captionby;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_publishDate;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_pageNumber;

@property (nonatomic,retain) NSTimer*               controlVisibilityTimer;

+ (PageViewController*) createInstanceWithPageID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber;

@end
