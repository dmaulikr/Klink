//
//  SampleViewController.h
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageGallerySlider.h"
#import "CustomVie2.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "ImageDownloadProtocol.h"
@class Photo;
@interface SampleViewController : UIViewController <NSFetchedResultsControllerDelegate, ImageDownloadCallback, UIScrollViewDelegate> {
  
    UIScrollView* scrollView;
    NSMutableArray* imageSlider;
   
}
- (void)add:(Photo*)photo atIndex:(NSNumber*)index;
- (void)addPlaceholderAtIndex:(NSNumber*)index;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic,retain) IBOutlet NSMutableArray* imageSlider;
@end
