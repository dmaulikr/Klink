//
//  BookPageViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIResourceLinkButton.h"

#define UIPageViewControllerOptionSpineLocationKey @"UIPageViewControllerOptionSpineLocationKey"

@class BookPageViewController;

@protocol BookPageViewControllerDelegate

@required
- (IBAction) onHomeButtonPressed:(id)sender;
- (IBAction) onFacebookButtonPressed:(id)sender;
- (IBAction) onTwitterButtonPressed:(id)sender;
- (IBAction) onLinkButtonClicked:(id)sender;
- (IBAction) onTableOfContentsButtonPressed:(id)sender;
- (IBAction) onZoomOutPhotoButtonPressed:(id)sender;
- (IBAction) onPageInfoButtonPressed:(id)sender;
@end

@interface BookPageViewController : BaseViewController {    
    id<BookPageViewControllerDelegate> m_delegate;
    
    NSNumber*       m_pageID; //represents the ID of the page which the view controller is currently displaying
    NSNumber*       m_topVotedPhotoID;
    NSNumber*       m_topVotedCaptionID;
    NSNumber*       m_pageNumber;
    
    NSTimer*        m_controlVisibilityTimer;
    BOOL            m_controlsHidden;
    
    UIImageView*    m_iv_openBookPageImage;
    UILabel*        m_lbl_title;
    UIImageView*    m_iv_photo;
    UIImageView*    m_iv_photoFrame;
    UILabel*        m_lbl_downloading;
    UILabel*        m_lbl_caption;
    UILabel*        m_lbl_photoby;
    UILabel*        m_lbl_captionby;
    UILabel*        m_lbl_publishDate;
    UILabel*        m_lbl_pageNumber;
    
    UIResourceLinkButton*   m_btn_writtenBy;
    UIResourceLinkButton*   m_btn_illustratedBy;
    
    UIButton*       m_btn_homeButton;
    UIButton*       m_btn_tableOfContentsButton;
    UIButton*       m_btn_zoomOutPhoto;
    UIButton*       m_btn_facebookButton;
    UIButton*       m_btn_twitterButton;
    
    UIButton*       m_btn_pageInfoButton;
    
}

@property (assign) id<BookPageViewControllerDelegate>    delegate;

@property (nonatomic,retain) NSNumber*              pageID;
@property (nonatomic,retain) NSNumber*              topVotedPhotoID;
@property (nonatomic,retain) NSNumber*              topVotedCaptionID;
@property (nonatomic,retain) NSNumber*              pageNumber;

@property (nonatomic,retain) NSTimer*               controlVisibilityTimer;

@property (nonatomic,retain) IBOutlet UIImageView*  iv_openBookPageImage;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_title;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_caption;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_photo;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_photoFrame;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_downloading;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_photoby;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_captionby;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_publishDate;
@property (nonatomic,retain) IBOutlet UILabel*      lbl_pageNumber;

@property (nonatomic,retain) IBOutlet UIResourceLinkButton* btn_writtenBy;
@property (nonatomic,retain) IBOutlet UIResourceLinkButton* btn_illustratedBy;

@property (nonatomic,retain) IBOutlet UIButton*     btn_homeButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_tableOfContentsButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_zoomOutPhoto;
@property (nonatomic,retain) IBOutlet UIButton*     btn_facebookButton;
@property (nonatomic,retain) IBOutlet UIButton*     btn_twitterButton;

@property (strong, nonatomic) IBOutlet UIButton*    btn_pageInfoButton;


- (IBAction) onLinkButtonClicked:(id)sender;

+ (BookPageViewController*) createInstanceWithPageID:(NSNumber*)pageID withPageNumber:(NSNumber*)pageNumber;

@end
