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
#import "NSStringGUIDCategory.h"

#define kCaptionWidth_landscape     480
#define kCaptionWidth               320
#define kCaptionHeight_landscape    70
#define kCaptionHeight              70
#define kCaptionSpacing             0

#define kButtonWidth                70
#define kButtonHeight               30
#define kButtonRightPadding         20
#define kButtonBottomPadding        100

@implementation UIPhotoCaptionScrollView
@synthesize photo =                     m_photo;
@synthesize captionScrollView =         m_captionScrollView;
@synthesize frc_captions =              __frc_captions;
@synthesize managedObjectContext=       __managedObjectContext;
@synthesize captionCloudEnumerator =    m_captionCloudEnumerator;
@synthesize voteButton =                m_voteButton;

- (void) dealloc {
    
    [self.voteButton release];
    [self.frc_captions release];
    [self.photo release];
    [self.captionScrollView release];
    [self.captionCloudEnumerator release];
    [super dealloc];
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

- (CGRect)frameForVoteButton:(CGRect)frame {
    int xCoordinate = frame.size.width - kButtonWidth - kButtonRightPadding;
    int yCoordinate = frame.size.height - kButtonHeight - kButtonBottomPadding;
    return CGRectMake(xCoordinate, yCoordinate, kButtonWidth, kButtonHeight);
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
        
        CGRect frameForVoteButton = [self frameForVoteButton:frame];
        self.voteButton = [[UIButton alloc]initWithFrame:frameForVoteButton];
        self.voteButton.backgroundColor = [UIColor redColor];
        [self.voteButton setTitle:@"Vote" forState:UIControlStateNormal];
        [self.voteButton setTitle:@"Voted!" forState:UIControlStateDisabled];
        [self.voteButton addTarget:self action:@selector(onVoteUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.voteButton];
        
    
        
        if ([[self.frc_captions fetchedObjects]count] < threshold_LOADMORECAPTIONS) {
            [self.captionCloudEnumerator enumerateNextPage];
        }
        
        //lets check to see if the first caption requires us to start with the voting button hidden
        int count = [[self.frc_captions fetchedObjects]count];
        if (count > 0) {
            Caption* firstCaption = [[self.frc_captions fetchedObjects]objectAtIndex:0];
            [self evaluateVotingButton:firstCaption];
        }
        else {
            //if there are no captions, then we need to hide the voting button
            self.voteButton.hidden = YES;
        }
        
        
    }
    return self;
}

- (id) resetWithFrame:(CGRect)frame withPhoto:(Photo*)photo {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self.captionCloudEnumerator];
    
    __frc_captions = nil;
    self.photo = photo;

    self.frame = frame;
   
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
    
   
   

  UICaptionLabel* captionLabel = [[UICaptionLabel alloc]initWithFrame:frame];

   [self viewSlider:nil configure:captionLabel forRowAtIndex:index withFrame:frame];
   return captionLabel;
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
    
    NSArray* captions = [self.frc_captions fetchedObjects];
    int numberOfCaptions = [[self.frc_captions fetchedObjects]count];
    if (index < numberOfCaptions) {
        int numberOfCaptionsRemaining = [self.frc_captions.fetchedObjects count] - index;
        
        if (numberOfCaptionsRemaining < threshold_LOADMORECAPTIONS &&
            ![self.captionCloudEnumerator isDone]) {
            
            //need to enumerate the next set of captions
            [self.captionCloudEnumerator enumerateNextPage];
        }
        
        Caption* currentCaption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        [self evaluateVotingButton:currentCaption];
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

#pragma mark - Button helpers

- (void) evaluateVotingButton:(Caption*)caption {
    
    if ([caption.user_hasvoted boolValue] == YES) {
        [self disableVotingButton];
    }
    else {
        [self enableVotingButton];
    }

}
- (void) disableVotingButton {
    self.voteButton.hidden = NO;
    self.voteButton.enabled = NO;
    self.voteButton.backgroundColor = [UIColor grayColor];
}

- (void) enableVotingButton {
    self.voteButton.hidden = NO;
    self.voteButton.enabled = YES;
    self.voteButton.backgroundColor = [UIColor redColor];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.captionScrollView onNewItemInsertedAt:newIndexPath.row];
        [self.captionScrollView tilePages];
        self.voteButton.hidden = NO;
    }

}

#pragma mark - Button Handlers
- (void) onVoteUpButtonPressed:(id)sender {
    self.photo = [Photo photo:self.photo.objectid];
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:self.captionScrollView.currentPageIndex];
    
    self.photo.numberofvotes =[NSNumber numberWithInt:([self.photo.numberofvotes intValue] + 1)];
    caption.numberofvotes = [NSNumber numberWithInt:([caption.numberofvotes intValue]+1)];
    caption.user_hasvoted = [NSNumber numberWithBool:YES];
    
    //now we need to commit to the store
    [self.photo commitChangesToDatabase:NO withPendingFlag:YES];
    [caption commitChangesToDatabase:NO withPendingFlag:YES];
    
    [self disableVotingButton];
    //now we upload to the cloud
    NSString* notificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onVoteCommittedToServer:) name:notificationID object:self];
   
    [[WS_TransferManager getInstance]updateAttributeInCloud:caption.objectid withObjectType:caption.objecttype forAttribute:an_NUMBEROFVOTES byValue:[NSString stringWithFormat:@"1"] onFinishNotify:notificationID];
    
}

-(void) onVoteCommittedToServer:(NSNotification*)notification {
    
}
@end
