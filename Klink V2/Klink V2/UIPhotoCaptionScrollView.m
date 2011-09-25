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
#import "SocialSharingManager.h"
#import "PhotoViewController.h"
#import "CloudEnumeratorFactory.h"

#define kCaptionWidth_landscape     480
#define kCaptionWidth               320
#define kCaptionHeight_landscape    70
#define kCaptionHeight              70
#define kCaptionSpacing             0

#define kButtonWidth                65
#define kButtonHeight               30
#define kButtonRightPadding         0
#define kButtonBottomPadding        114
#define kShareButtonLeftPadding     0
#define kShareButtonBottomPadding   114

#define kPhotoCreditsWidth_landscape    480
#define kPhotoCreditsWidth              320
#define kPhotoCreditsHeight             24
#define kPhotoVotesWidth                100
#define kPhotoVotesHeight               24
#define kPhotoCreditsPadding            5

#define kToolbarHeight              44
#define kNavigationbarHeight        44

@implementation UIPhotoCaptionScrollView

@synthesize photo =                     m_photo;
@synthesize captionScrollView =         m_captionScrollView;
@synthesize frc_captions =              __frc_captions;
@synthesize managedObjectContext=       __managedObjectContext;
@synthesize captionCloudEnumerator =    m_captionCloudEnumerator;
@synthesize voteButton =                m_voteButton;
@synthesize shareButton=                m_shareButton;
@synthesize photoCreditsBackground;
@synthesize photoCreditsLabel;
@synthesize photoVotesLabel;
@synthesize photoViewController =       m_photoViewController;

- (void) dealloc {
    [self.voteButton release];
    [self.frc_captions release];
    [self.photo release];
    [self.captionScrollView release];
    [self.captionCloudEnumerator release];
    [self.shareButton release];
    [self.photoCreditsBackground release];
    [self.photoCreditsLabel release];
    [self.photoVotesLabel release];
    [self.photoViewController release];
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
    NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc]initWithKey:an_CAPTION ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"photoid=%@",photo.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor,sortDescriptor2, nil]];
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
- (CGRect) frameForPhotoCreditsBackground {
    // Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// TODO Programatically get navigation bar height
    CGFloat navigationBarHeight = 44;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, statusBarHeight + kNavigationbarHeight, kPhotoCreditsWidth_landscape, kPhotoCreditsHeight);
    }
    else {
        return CGRectMake(0, statusBarHeight + kNavigationbarHeight, kPhotoCreditsWidth, kPhotoCreditsHeight);
    }
}

- (CGRect) frameForPhotoCredits {
    // Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// TODO Get navigation bar height
	CGFloat navigationBarHeight = 44;

    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(kPhotoCreditsPadding, statusBarHeight + kNavigationbarHeight, kPhotoCreditsWidth_landscape - kPhotoVotesWidth - 2*kPhotoCreditsPadding, kPhotoCreditsHeight);
    }
    else {
        return CGRectMake(kPhotoCreditsPadding, statusBarHeight + kNavigationbarHeight, kPhotoCreditsWidth - kPhotoVotesWidth - 2*kPhotoCreditsPadding, kPhotoCreditsHeight);
    }
    
}

- (CGRect) frameForPhotoVotes:(CGRect)frame {
    // Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// TODO Get navigation bar height
	CGFloat navigationBarHeight = 44;
    
    return CGRectMake(frame.size.width - kPhotoVotesWidth - kPhotoCreditsPadding, statusBarHeight + kNavigationbarHeight, kPhotoVotesWidth, kPhotoCreditsHeight);
    
}

- (CGRect) frameForCaptionScrollView:(CGRect)frame {
    
    return CGRectMake(0, frame.size.height-kCaptionHeight-kToolbarHeight, frame.size.width, kCaptionHeight);

}

- (CGRect)frameForVoteButton:(CGRect)frame {
    int xCoordinate = frame.size.width - kButtonWidth - kButtonRightPadding;
    int yCoordinate = frame.size.height - kButtonHeight - kButtonBottomPadding;
    return CGRectMake(xCoordinate, yCoordinate, kButtonWidth, kButtonHeight);
}


- (CGRect)frameForShareButton:(CGRect)frame {
    int xCoordinate =   kShareButtonLeftPadding;
    int yCoordinate = frame.size.height - kButtonHeight - kShareButtonBottomPadding;
    return CGRectMake(xCoordinate, yCoordinate, kButtonWidth, kButtonHeight);
}


#pragma mark - Initializers
- (id) initWithFrame:(CGRect)frame withPhoto:(Photo *)photo {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.photo = photo;
        self.photoViewController = self.viewController;
        
        // Add Photo Credits Label
        // set transparent backgrounds first
        //UIView* frameForPhotoCreditsBackground = nil;
        photoCreditsBackground = [[UIView alloc] initWithFrame:[self frameForPhotoCreditsBackground]];
        [photoCreditsBackground setBackgroundColor:[UIColor blackColor]];
        [photoCreditsBackground setAlpha:0.5];
        [photoCreditsBackground setOpaque:YES];
        [self addSubview:photoCreditsBackground];
        
        // now add non-transparent text for Credits label
        self.photoCreditsLabel = [[UILabel  alloc] initWithFrame:[self frameForPhotoCredits]];
        self.photoCreditsLabel.backgroundColor = [UIColor clearColor];
        self.photoCreditsLabel.opaque = YES;
        self.photoCreditsLabel.alpha = textAlpha;
        self.photoCreditsLabel.font = [UIFont fontWithName:font_CAPTION size:fontsize_PHOTOCREDITS];
        self.photoCreditsLabel.textColor = [UIColor whiteColor];
        self.photoCreditsLabel.textAlignment = UITextAlignmentLeft;
        photoCreditsLabel.text = photo.descr;
        [self addSubview:self.photoCreditsLabel];
        
        // now add non-transparent text for number of votes on the Photo
        self.photoVotesLabel = [[UILabel  alloc] initWithFrame:[self frameForPhotoVotes:frame]];
        self.photoVotesLabel.backgroundColor = [UIColor clearColor];
        self.photoVotesLabel.opaque = YES;
        self.photoVotesLabel.alpha = textAlpha;
        self.photoVotesLabel.font = [UIFont fontWithName:font_CAPTION size:fontsize_CAPTION];
        self.photoVotesLabel.textColor = [UIColor whiteColor];
        self.photoVotesLabel.textAlignment = UITextAlignmentRight;
        photoVotesLabel.text = [NSString stringWithFormat:@"Votes: %@", photo.numberofvotes];
        [self addSubview:self.photoVotesLabel];
        
        
        self.backgroundColor = [UIColor yellowColor];
        CGRect frameForCaptionScrollView = [self frameForCaptionScrollView:frame];
        self.captionScrollView = [[UIPagedViewSlider2 alloc]initWithFrame:frameForCaptionScrollView];
        self.captionScrollView.delegate = self;
        
        self.captionScrollView.backgroundColor = [UIColor clearColor];
        self.captionScrollView.alpha = 1;
        self.captionScrollView.opaque = NO;
        
        [self.captionScrollView initWithWidth:frameForCaptionScrollView.size.width withHeight:frameForCaptionScrollView.size.height withSpacing:kCaptionSpacing useCellIdentifier:@"captioncell" ];
         [self addSubview:self.captionScrollView];
       
        self.captionCloudEnumerator = [[CloudEnumeratorFactory getInstance]enumeratorForCaptions:self.photo.objectid];
//        self.captionCloudEnumerator = [CloudEnumerator enumeratorForCaptions:self.photo.objectid];
        self.captionCloudEnumerator.delegate = self;
        
    
        CGRect frameForShareButton = [self frameForShareButton:frame];
        self.shareButton = [[UIButton alloc]initWithFrame:frameForShareButton];
        self.shareButton.backgroundColor = [UIColor redColor];
        [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(onShareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.shareButton];
        
        CGRect frameForVoteButton = [self frameForVoteButton:frame];
        self.voteButton = [[UIButton alloc]initWithFrame:frameForVoteButton];
        self.voteButton.backgroundColor = [UIColor redColor];
        [self.voteButton setTitle:@"Vote" forState:UIControlStateNormal];
        [self.voteButton setTitle:@"Voted!" forState:UIControlStateDisabled];
        [self.voteButton addTarget:self action:@selector(onVoteUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.voteButton];
        
        // (TODO) TEMP hidding share and vote buttons, need to implement show/hide functionality on new toolbar button versions
        //self.shareButton.hidden = YES;
        //self.shareButton.enabled = NO;
        //self.voteButton.hidden = YES;
        //self.voteButton.enabled = NO;
     

        
        [self showHideVotingSharingButtons];
        
        //register for global events
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
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
    
    return self;
}
    
//checks to see if any additional caption data needs to be fetched prior to the view becoming active
- (void) loadViewData {
    NSString* activityName = @"UIPhotoCaptionScrollView.loadViewData:";
    
            if ([[self.frc_captions fetchedObjects]count] < threshold_LOADMORECAPTIONS) {
                NSString* message = @"Executing fetch of caption data from web service";
                [self.captionCloudEnumerator enumerateNextPage];
                [BLLog v:activityName withMessage:message];
            }
    
}
#pragma mark - Cloud Enumerator Delegate callback
- (void) onEnumerateComplete {
    
}

#pragma mark - UIPageScrollViewDelegate

- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider configure:(UICaptionLabel *)existingCell forRowAtIndex:(int)index withFrame:(CGRect)frame {
    
    if ([self.frc_captions.fetchedObjects count] > 0 &&
        index < [self.frc_captions.fetchedObjects count]) {
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        [existingCell setCaption:caption];
        existingCell.frame = frame;
    }


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
    
    int numberOfCaptions = [[self.frc_captions fetchedObjects]count];
    if (index < numberOfCaptions) {
        int numberOfCaptionsRemaining = [self.frc_captions.fetchedObjects count] - index;
        
        if (numberOfCaptionsRemaining < threshold_LOADMORECAPTIONS &&
            ![self.captionCloudEnumerator isDone]) {
            
            //need to enumerate the next set of captions
            [self.captionCloudEnumerator enumerateNextPage];
        }
        
        [self showHideVotingSharingButtons];
    }
}



- (int) itemCountFor:(UIPagedViewSlider2 *)viewSlider {
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
        [self.captionScrollView goTo:index];
    }
        
    
}

#pragma mark - System Event Handlers
-(void)onUserLoggedIn:(NSNotification*)notification {
    [self showHideVotingSharingButtons];
}

-(void)onUserLoggedOut:(NSNotification*)notification {
    [self showHideVotingSharingButtons];
}

#pragma mark - Button helpers
- (void) showHideVotingSharingButtons {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    AuthenticationContext* authenticationContext = [authenticationManager getAuthenticationContext];
    
    int captionCount = [[self.frc_captions fetchedObjects] count];
    
    if (authenticationContext == nil || captionCount == 0) {
        [self hideShareButton];
    }
    else {
        [self showShareButton];
    }
    
    if (captionCount > 0) {
        Caption* currentCaption = [[self.frc_captions fetchedObjects]objectAtIndex:[self.captionScrollView getPageIndex]];
        [self showVotingButton];
        if ([currentCaption.user_hasvoted boolValue] == YES) {
            [self disableVotingButton];
        }
        else {
            [self enableVotingButton];
        }
       
    }
    else {
        [self disableVotingButton];
        [self hideVotingButton];
    }
}

- (void) disableVotingButton {   
    self.photoViewController.tb_voteButton.enabled = NO;
    self.voteButton.enabled = NO;
    self.voteButton.backgroundColor = [UIColor grayColor];
}

- (void) enableVotingButton {
    self.photoViewController.tb_voteButton.enabled = YES;
    self.voteButton.enabled = YES;
    self.voteButton.backgroundColor = [UIColor redColor];
}

- (void) hideVotingButton {
    self.voteButton.hidden = YES;
}

- (void) showVotingButton {
    self.voteButton.hidden = NO;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        [self.captionScrollView onNewItemInsertedAt:newIndexPath.row];
        [self showHideVotingSharingButtons];
    }

}

#pragma mark - Button Handlers

//method called when the
- (void) onShareButtonPressed:(id)sender {
    SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
    int count = [[self.frc_captions fetchedObjects]count];
    if (count > 0) {
        [self hideShareButton];
        int index = [self.captionScrollView getPageIndex];
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        
        [sharingManager shareCaption:caption.objectid];
        
    }
       
}

//method called when the
- (void) onFacebookShareButtonPressed:(id)sender {
    SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
    int count = [[self.frc_captions fetchedObjects]count];
    if (count > 0) {
        [self hideShareButton];
        int index = [self.captionScrollView getPageIndex];
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        
        [sharingManager shareCaptionOnFacebook:caption.objectid];
        
    }
    
}

//method called when the
- (void) onTwitterShareButtonPressed:(id)sender {
    SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
    int count = [[self.frc_captions fetchedObjects]count];
    if (count > 0) {
        [self hideShareButton];
        int index = [self.captionScrollView getPageIndex];
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        
        [sharingManager shareCaptionOnTwitter:caption.objectid];
        
    }
    
}


- (void) hideShareButton {
    //PhotoViewController* photoViewController = [self viewController];
    //photoViewController.tb_shareButton.enabled = NO;
    self.shareButton.hidden = YES;
    self.shareButton.enabled = NO;
    
    //[photoViewController release];
}

- (void) showShareButton {
    //PhotoViewController* photoViewController = [self viewController];
    //photoViewController.tb_shareButton.enabled = YES;
    self.shareButton.hidden = NO;
    self.shareButton.enabled = YES;
    
    //[photoViewController release];
}

- (void) onVoteUpButtonPressed:(id)sender {
    self.photo = [Photo photo:self.photo.objectid];
    int index = [self.captionScrollView getPageIndex];
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
    
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
