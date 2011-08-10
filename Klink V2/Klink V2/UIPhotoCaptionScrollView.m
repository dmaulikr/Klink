//
//  UIPhotoCaptionScrollView.m
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIPhotoCaptionScrollView.h"
#import "Photo.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "UICaptionLabel.h"

#define kCaptionWidth_landscape     480
#define kCaptionWidth               320
#define kCaptionHeight_landscape    70
#define kCaptionHeight              70
#define kCaptionSpacing             0


@implementation UIPhotoCaptionScrollView
@synthesize photo =             m_photo;
@synthesize captionScrollView = m_captionScrollView;
@synthesize frc_captions =      __frc_captions;
@synthesize managedObjectContext=   __managedObjectContext;
@synthesize captionCloudEnumerator = m_captionCloudEnumerator;

- (void) dealloc {
    [self.frc_captions release];
    [self.photo release];
    [self.captionScrollView release];
    [self.captionCloudEnumerator release];
}

#pragma mark - Properties

- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    __managedObjectContext =  appDelegate.managedObjectContext;
    return __managedObjectContext;
}


- (NSFetchedResultsController*) get_frc_captions:(Photo*)photo {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"photoid=%@",photo.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil]autorelease];
    controller.delegate = self;
    
    
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
   
    [fetchRequest release];
    return controller;
}

- (NSFetchedResultsController*) frc_captions {
    if (__frc_captions != nil) {
        return __frc_captions;
    }
    if (self.photo == nil) {
        return nil;
    }
    
    __frc_captions = [[self get_frc_captions:self.photo] retain];
    
    
    return __frc_captions;
    
}
#pragma mark - Frames
- (CGRect) frameForCaptionScrollView {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, self.frame.size.height - kCaptionHeight_landscape, kCaptionWidth_landscape, kCaptionHeight_landscape);
    }
    else {
        return CGRectMake(0, self.frame.size.height - kCaptionHeight, kCaptionWidth, kCaptionHeight);
//          return CGRectMake(0, 10, kCaptionWidth, kCaptionHeight);
    }
}


#pragma mark - Initializers
- (id) initWithFrame:(CGRect)frame withPhoto:(Photo *)photo {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        
        self.photo = photo;
        
        CGRect frameForCaptionScrollView = [self frameForCaptionScrollView];
        self.captionScrollView = [[UIPagedViewSlider2 alloc]initWithFrame:frameForCaptionScrollView];
        self.captionScrollView.delegate = self;
        self.captionScrollView.currentPageIndex = 0;
        self.captionScrollView.backgroundColor = [UIColor blackColor];
        self.captionScrollView.alpha = 0.5;
        self.captionScrollView.opaque = NO;
        [self.captionScrollView initWithWidth:kCaptionWidth withHeight:kCaptionHeight withWidthLandscape:kCaptionWidth_landscape withHeightLandscape:kCaptionHeight_landscape withSpacing:kCaptionSpacing];
        [self addSubview:self.captionScrollView];
        self.captionCloudEnumerator = [CloudEnumerator enumeratorForCaptions:self.photo.objectid];
        self.captionCloudEnumerator.delegate = self;
        if ([[self.frc_captions fetchedObjects]count] < threshold_LOADMORECAPTIONS) {
            [self.captionCloudEnumerator enumerateNextPage];
        }
        
    }
    return self;
}

- (id) resetWithFrame:(CGRect)frame withPhoto:(Photo*)photo {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self.captionCloudEnumerator];
    
    __frc_captions = nil;
    self.photo = photo;
    CGRect existingFrame = self.frame;
    self.frame = frame;
    CGRect newFrame = self.frame;
    [self.captionScrollView removeFromSuperview];
    self.captionScrollView = nil;
    self.captionCloudEnumerator = nil;
    [self initWithFrame:frame withPhoto:photo];
}
                                                    

#pragma mark - Cloud Enumerator Delegate callback
- (void) onEnumerateComplete {
    
}

#pragma mark - UIPageScrollViewDelegate

- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider configure:(UICaptionLabel *)existingCell forRowAtIndex:(int)index withFrame:(CGRect)frame {
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
    [existingCell setCaption:caption];
    existingCell.frame = frame;


}

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index; {
    
}

- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:         (int)                   index 
             withFrame:          (CGRect)                frame {
    
   
   
//   UICaptionLabel* captionLabel = [[UICaptionLabel alloc]initWithFrame:frame];
  UICaptionLabel* captionLabel = [[UICaptionLabel alloc]initWithFrame:frame];

   [self viewSlider:nil configure:captionLabel forRowAtIndex:index withFrame:frame];
   return captionLabel;
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
    
    int numberOfCaptionsRemaining = [self.frc_captions.fetchedObjects count] - index;
    
    if (numberOfCaptionsRemaining < threshold_LOADMORECAPTIONS &&
        ![self.captionCloudEnumerator isDone]) {
        
        //need to enumerate the next set of captions
        [self.captionCloudEnumerator enumerateNextPage];
    }
    
}

- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider {
    return [[self.frc_captions fetchedObjects]count];
}

- (void) setVisibleCaption:(NSNumber *)objectid {
    NSArray* captions = [self.frc_captions fetchedObjects];
    int index = -1;
    
    for (int i = 0 ; i < [captions count];i++) {
        Caption* caption = [captions objectAtIndex:i];
        if ([caption.objectid isEqualToNumber:objectid]) {
            index = i;
            break;
        }
    }
    
    if (index != -1) {
        [self.captionScrollView goToPage:index];
    }
        
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.captionScrollView onNewItemInsertedAt:newIndexPath.row];
        [self.captionScrollView tilePages];
    }

}
@end
