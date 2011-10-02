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
#import "UIPagedViewSlider4.h"
#import "CloudEnumerator.h"



@interface ThemeBrowserViewController2 : KlinkBaseViewController <NSFetchedResultsControllerDelegate, ImageDownloadCallback, UIPagedViewSlider2Delegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CloudEnumeratorDelegate, UIActionSheetDelegate> {

    UILabel*                        lbl_theme;
     

    CloudEnumerator*                m_themeCloudEnumerator;
    CloudEnumerator*                m_photosInThemeCloudEnumeator;
  
  
}


@property (nonatomic,retain) NSFetchedResultsController*frc_photosInCurrentTheme;
@property (nonatomic,retain) NSFetchedResultsController*frc_themes;
@property (nonatomic,retain) IBOutlet UILabel*          lbl_theme;



@property (nonatomic, retain) CloudEnumerator*    themeCloudEnumerator;
@property (nonatomic, retain) CloudEnumerator*    photosInThemeCloudEnumerator;


@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* v_pvs_photoSlider2;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2* h_pvs_photoSlider2;

@property (nonatomic,retain) IBOutlet UIPagedViewSlider2 *v_pvs_themeSlider2;
@property (nonatomic,retain) IBOutlet UIPagedViewSlider2 *h_pvs_themeSlider2;

@property (nonatomic,retain) UIPagedViewSlider2* pvs_photoSlider2;
@property (nonatomic,retain) UIPagedViewSlider2* pvs_themeSlider2;


@end
