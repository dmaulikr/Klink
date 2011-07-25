//
//  ThemeBrowserViewController2.h
//  Klink V2
//
//  Created by Bobby Gill on 7/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPagedViewSlider.h"
#import "Theme.h"
#import "ImageDownloadProtocol.h"
#import "KlinkBaseViewController.h"

@class FullScreenPhotoController;

@interface ThemeBrowserViewController2 : KlinkBaseViewController <NSFetchedResultsControllerDelegate, ImageDownloadCallback, UIPagedViewSliderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
//    UIPagedViewSlider* pvs_photoSlider;
//    UIPagedViewSlider* pvs_themeSlider;
    UILabel* lbl_theme;
    Theme* theme;  
    EnumerationContext* ec_activeThemePhotoContext;
    EnumerationContext* ec_activeThemeContext;
    BOOL m_isThereAThemePhotoEnumerationAlreadyExecuting;
    BOOL m_isThereAThemeEnumerationAlreadyExecuting;
    
    NSString* m_outstandingPhotoEnumNotificationID;
    
    FullScreenPhotoController *fullScreenPhotoController;
  
}

@property (nonatomic,retain) UIPagedViewSlider* pvs_photoSlider;
@property (nonatomic,retain) UIPagedViewSlider* pvs_themeSlider;
@property (nonatomic,retain) Theme* theme;

@property (nonatomic,retain) NSString* m_outstandingPhotoEnumNotificationID;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSFetchedResultsController *frc_photosInCurrentTheme;
@property (nonatomic,retain) NSFetchedResultsController *frc_themes;
@property (nonatomic,retain) IBOutlet UILabel* lbl_theme;

@property BOOL m_isThereAThemePhotoEnumerationAlreadyExecuting;
@property BOOL m_isThereAThemeEnumerationAlreadyExecuting;
@property (nonatomic, retain) EnumerationContext* ec_activeThemePhotoContext;
@property (nonatomic, retain) EnumerationContext* ec_activeThemeContext;

//@property (nonatomic,retain) IBOutlet UIView* v_landscape;
//@property (nonatomic,retain) IBOutlet UIView* v_portrait;

@property (nonatomic,retain) IBOutlet UIPagedViewSlider* v_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider* h_pvs_photoSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider *v_pvs_themeSlider;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider *h_pvs_themeSlider;

@property (nonatomic, retain) FullScreenPhotoController *fullScreenPhotoController;

@end
