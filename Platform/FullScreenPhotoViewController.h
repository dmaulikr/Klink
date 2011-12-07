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

@interface FullScreenPhotoViewController : BaseViewController <NSFetchedResultsControllerDelegate, UIPagedViewSlider2Delegate> {
    NSNumber*           m_pageID; //represents the ID of the page whose photos will be shown
    NSNumber*           m_photoID;
    NSNumber*           m_captionID;
    
    UIPagedViewSlider2* m_photoViewSlider;
    UIPagedViewSlider2* m_captionViewSlider;
    UIPhotoMetaDataView*    m_photoMetaData;
    
    CloudEnumerator*    m_captionCloudEnumerator;
    
    NSTimer*            m_controlVisibilityTimer;
    
    UIBarButtonItem*    m_tb_facebookButton;
    UIBarButtonItem*    m_tb_twitterButton;
    UIBarButtonItem*    m_tb_cameraButton;
    UIBarButtonItem*    m_tb_voteButton;
    UIBarButtonItem*    m_tb_captionButton;
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

// Toolbar Buttons
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_facebookButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_twitterButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_cameraButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_voteButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem*      tb_captionButton;

// Navigation
- (void)    updateNavigation;

// Static Initializer
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID;

@end
