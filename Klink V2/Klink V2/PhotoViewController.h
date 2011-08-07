//
//  PhotoViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 8/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KlinkBaseViewController.h"
#import "Photo.h"
#import "Theme.h"
#import "ImageDownloadProtocol.h"
#import "UIPagedViewSlider2.h"
#import "CloudEnumerator.h"

typedef enum {
    kNormal,
    kZoomedIn
} ViewState;


@interface PhotoViewController : KlinkBaseViewController <UIPagedViewSlider2Delegate,UITextViewDelegate, NSFetchedResultsControllerDelegate,ImageDownloadCallback, CloudEnumeratorDelegate> {
    Theme* m_currentTheme;
    Photo* m_currentPhoto;
    int m_currentIndex;
    
    BOOL m_wantsFullScreenLayout;
    BOOL m_hidesBottomBarWhenPushed;
    
    // Navigation & controls
	
	NSTimer             *m_controlVisibilityTimer;

    
    CloudEnumerator*    m_photoCloudEnumerator;
    
    UIBarButtonItem*    m_captionButton;
    UIBarButtonItem*    m_submitButton;
    UIBarButtonItem*    m_cancelCaptionButton;
    BOOL                m_isInEditMode;
    
    ViewState           m_state;
    
}

@property (nonatomic,retain) Theme* currentTheme;
@property (nonatomic,retain) Photo* currentPhoto;
@property (nonatomic,retain) CloudEnumerator* photoCloudEnumerator;
@property (nonatomic,retain) NSFetchedResultsController* frc_captions;
@property (nonatomic,retain) NSFetchedResultsController* frc_photos;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain) UIPagedViewSlider2* pvs_photoSlider;
@property (nonatomic,retain) UIPagedViewSlider2* pvs_captionSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* v_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* h_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* v_pvs_captionSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* h_pvs_captionSlider;

@property (nonatomic,retain) IBOutlet UITextView*   h_tv_captionBox;
@property (nonatomic,retain) IBOutlet UITextView*   v_tv_captionBox;
@property (nonatomic,retain) UITextView*            tv_captionBox;

@property (nonatomic,retain) NSTimer*                       controlVisibilityTimer;
@property (nonatomic,retain) UIBarButtonItem*               previousButton;
@property (nonatomic,retain) UIBarButtonItem*               nextButton;

@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*    h_pagedViewSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*    v_pagedViewSlider;

@property (nonatomic,retain) IBOutlet UIScrollView*         h_sv_view;
@property (nonatomic,retain) IBOutlet UIScrollView*         v_sv_view;
@property (nonatomic,retain) UIScrollView*                  sv_view;

@property (nonatomic,retain) UIPagedViewSlider2*            pagedViewSlider;
@property (nonatomic,retain) UIBarButtonItem*               captionButton;
@property (nonatomic,retain) UIBarButtonItem*               submitButton;
@property (nonatomic,retain) UIBarButtonItem*               cancelCaptionButton;
@property (nonatomic,retain) UITextField*                   captionTextField;

@property ViewState state;
- (CGRect)  frameForToolbarAtOrientation:   (UIInterfaceOrientation)    orientation;
- (CGRect) frameForCaptionTextField;
// Navigation
- (void)    updateNavigation;
- (void)    hideControlsAfterDelay;
- (void)    cancelControlHiding;
- (void)    hideControls;
- (void)    toggleControls;
- (void)    setControlsHidden:          (BOOL)      hidden;
- (void)    didStartViewingPageAtIndex: (NSUInteger)index;
- (void)    setViewMovedUp:(BOOL)movedUp;
- (void)    keyboardWillShow:(NSNotification*)notification;
- (void)    keyboardDidHide:(NSNotification*)notification;

- (void)    onEnterEditMode;
- (void)    onExitEditMode;
@end
