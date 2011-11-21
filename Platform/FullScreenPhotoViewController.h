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
#import "CloudEnumerator.h"

@interface FullScreenPhotoViewController : BaseViewController <NSFetchedResultsControllerDelegate, UIPagedViewSlider2Delegate> {
    NSNumber*           m_pageID; //represents the ID of the page whose photos will be shown
    NSNumber*           m_photoID;
    NSNumber*           m_captionID;
    
    UIPagedViewSlider2* m_photoViewSlider;
    UIPagedViewSlider2* m_captionViewSlider;
    
    CloudEnumerator*    m_captionCloudEnumerator;
}

@property (nonatomic,retain) NSFetchedResultsController*    frc_photos;
@property (nonatomic,retain) NSFetchedResultsController*    frc_captions;

@property (nonatomic,retain) CloudEnumerator*               captionCloudEnumerator;

@property (nonatomic,retain) NSNumber*                      pageID;
@property (nonatomic,retain) NSNumber*                      photoID;
@property (nonatomic,retain) NSNumber*                      captionID;

// Subviews
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*   photoViewSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2*   captionViewSlider;

- (CGRect)  frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)    updateNavigation;

// Static Initializer
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID;

@end
