//
//  SampleViewController2.h
//  Klink V2
//
//  Created by Bobby Gill on 7/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewSlider.h"
#import "UIViewSliderDelegate.h"
#import "ImageDownloadProtocol.h"
@class Photo;
@interface SampleViewController2 : UIViewController <UIViewSliderDelegate,NSFetchedResultsControllerDelegate,ImageDownloadCallback> {
    UIViewSlider* m_viewSlider;
}
- (UIImageView*) configureViewFor:(Photo*)photo atIndex:(int)index; 
@property (nonatomic,retain) IBOutlet UIViewSlider* m_viewSlider;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end
