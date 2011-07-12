//
//  ThemeBrowserController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Theme.h"
#import "UIViewSlider.h"
#import "ImageDownloadProtocol.h"

@interface ThemeBrowserController : UIViewController <NSFetchedResultsControllerDelegate, ImageDownloadCallback, UIViewSliderDelegate>

{
    UIImageView* imgv_themeHomeImage;
    UIViewSlider* vs_themePhotoSlider;
    
}

- (BOOL) shouldUpdateFromWebService;

@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,retain) NSFetchedResultsController *frc_themes;
@property (nonatomic,retain) Theme* theme;
@property (nonatomic, retain) IBOutlet UIImageView* imgv_themeHomeImage;
@property (nonatomic, retain) IBOutlet UIViewSlider* vs_themePhotoSlider;
@end
