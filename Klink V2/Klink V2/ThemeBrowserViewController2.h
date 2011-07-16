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


@interface ThemeBrowserViewController2 : UIViewController <NSFetchedResultsControllerDelegate, ImageDownloadCallback, UIViewSliderDelegate> {
    UIPagedViewSlider* pvs_slider;
    Theme* theme;
    UILabel* lbl_theme;
    
    EnumerationContext* ec_activeThemePhotoContext;
    BOOL m_isThereAThemePhotoEnumerationAlreadyExecuting;
}

@property (nonatomic,retain) IBOutlet UIPagedViewSlider* pvs_slider;
@property (nonatomic,retain) Theme* theme;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,retain) NSFetchedResultsController *frc_themes;
@property (nonatomic,retain) IBOutlet UILabel* lbl_theme;

@property BOOL m_isThereAThemePhotoEnumerationAlreadyExecuting;
@property (nonatomic, retain) EnumerationContext* ec_activeThemePhotoContext;
@end
