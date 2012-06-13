//
//  FullScreenPhotoViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPagedViewSlider4.h"
#import "UIPhotoMetaDataView.h"
#import "CloudEnumerator.h"
#import "UIProgressHUDView.h"

@interface FullScreenPhotoViewController : BaseViewController <NSFetchedResultsControllerDelegate, UIPagedViewSlider2Delegate, CloudEnumeratorDelegate, UIProgressHUDViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate > {
    NSNumber*           m_pageID; //represents the ID of the page whose photos will be shown
    NSNumber*           m_photoID;
    NSNumber*           m_captionID;
    
    UIPagedViewSlider2* m_photoViewSlider;
    UIPagedViewSlider2* m_captionViewSlider;
    UIPhotoMetaDataView*    m_photoMetaData;
    UIImageView*        m_iv_photo;
    UIImageView*        m_iv_photoLandscape;
    UILabel*            m_lbl_downloading;
    //UIPageControl*      m_pg_captionPageIndicator;
    UIImageView*        m_iv_leftArrow;
    UIImageView*        m_iv_rightArrow;
    
    CloudEnumerator*    m_captionCloudEnumerator;
    
    NSTimer*            m_controlVisibilityTimer;
    
    UIBarButtonItem*    m_tb_facebookButton;
    UIBarButtonItem*    m_tb_twitterButton;
    UIBarButtonItem*    m_tb_cameraButton;
    UIBarButtonItem*    m_tb_voteButton;
    UIBarButtonItem*    m_tb_captionButton;
    
    BOOL                m_isSinglePhotoAndCaption;
}

@property (nonatomic,retain) NSFetchedResultsController*    frc_photos;
@property (nonatomic,retain) NSFetchedResultsController*    frc_captions;

@property (nonatomic,retain) CloudEnumerator*               captionCloudEnumerator;

@property (nonatomic,retain) NSTimer*                       controlVisibilityTimer;

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSNumber*                      photoID;
@property (nonatomic,retain) NSNumber*                      captionID;

// Subviews
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*   photoViewSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*   captionViewSlider;
@property (nonatomic,retain) IBOutlet UIPhotoMetaDataView*  photoMetaData;
@property (nonatomic,retain)          UIImageView*          iv_photo;
@property (nonatomic,retain) IBOutlet UIImageView*          iv_photoLandscape;
@property (nonatomic,retain) IBOutlet UILabel*              lbl_downloading;
//@property (nonatomic,retain) IBOutlet UIPageControl*        pg_captionPageIndicator;
@property (nonatomic,retain) IBOutlet UIImageView*          iv_leftArrow;
@property (nonatomic,retain) IBOutlet UIImageView*          iv_rightArrow;

// Toolbar Buttons
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_facebookButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_twitterButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_cameraButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_voteButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_captionButton;

@property                             BOOL                  isSinglePhotoAndCaption;

// Navigation
- (void) updateNavigation;
- (void) didRotate;

// Static Initializer
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID;
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber *)pageID withPhotoID:(NSNumber *)photoID withCaptionID:(NSNumber*)captionID;
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber *)pageID withPhotoID:(NSNumber *)photoID withCaptionID:(NSNumber*)captionID isSinglePhotoAndCaption:(BOOL)isSingle;

@end
