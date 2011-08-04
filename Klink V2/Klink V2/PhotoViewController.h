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
@interface PhotoViewController : KlinkBaseViewController <UIPagedViewSlider2Delegate, NSFetchedResultsControllerDelegate,ImageDownloadCallback> {
    Photo* m_currentPhoto;
    Theme* m_currentTheme;
    int m_currentIndex;
    
    BOOL m_wantsFullScreenLayout;
    BOOL m_hidesBottomBarWhenPushed;
    
    // Navigation & controls
	
	NSTimer             *m_controlVisibilityTimer;
	UIBarButtonItem     *m_previousButton;
    UIBarButtonItem     *m_nextButton;
    

    
}

@property (nonatomic,retain) Photo* currentPhoto;
@property (nonatomic,retain) Theme* currentTheme;
@property (nonatomic,retain) NSFetchedResultsController* frc_captions;
@property (nonatomic,retain) NSFetchedResultsController* frc_photos;
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,retain) UIPagedViewSlider2* pvs_photoSlider;
@property (nonatomic,retain) UIPagedViewSlider2* pvs_captionSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* v_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* h_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* v_pvs_captionSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* h_pvs_captionSlider;

@property (nonatomic,retain) NSTimer*                       controlVisibilityTimer;
@property (nonatomic,retain) UIBarButtonItem*               previousButton;
@property (nonatomic,retain) UIBarButtonItem*               nextButton;

@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*    h_pagedViewSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*    v_pagedViewSlider;
@property (nonatomic,retain) UIPagedViewSlider2*            pagedViewSlider;


- (CGRect)  frameForToolbarAtOrientation:   (UIInterfaceOrientation)    orientation;

// Navigation
- (void)    updateNavigation;
- (void)    hideControlsAfterDelay;
- (void)    cancelControlHiding;
- (void)    hideControls;
- (void)    toggleControls;
- (void)    setControlsHidden:          (BOOL)      hidden;
- (void)    didStartViewingPageAtIndex: (NSUInteger)index;
@end
