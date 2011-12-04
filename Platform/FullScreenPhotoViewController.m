//
//  FullScreenPhotoViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FullScreenPhotoViewController.h"
#import "ImageManager.h"
#import "CloudEnumeratorFactory.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "Macros.h"
#import "UICaptionView.h"
#import "ContributeViewController.h"
#import "UICaptionView.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "ApplicationSettings.h"
#import "DraftViewController.h"
#import "UIDraftView.h"
#import "SocialSharingManager.h"

#define kPictureWidth               320
#define kPictureHeight              480
#define kPictureSpacing             0

#define kCaptionWidth               320
#define kCaptionHeight              70
#define kCaptionSpacing             0

#define kPHOTOID @"photoid"
#define kIMAGEVIEW @"imageview"

@implementation FullScreenPhotoViewController

@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;

@synthesize captionCloudEnumerator  = m_captionCloudEnumerator;

@synthesize pageID                  = m_pageID;
@synthesize photoID                 = m_photoID;
@synthesize captionID               = m_captionID;

@synthesize photoViewSlider         = m_photoViewSlider;
@synthesize captionViewSlider       = m_captionViewSlider;

@synthesize tb_facebookButton       = m_tb_facebookButton;
@synthesize tb_twitterButton        = m_tb_twitterButton;
@synthesize tb_cameraButton         = m_tb_cameraButton;
@synthesize tb_voteButton           = m_tb_voteButton;
@synthesize tb_captionButton        = m_tb_captionButton;


#pragma mark - Properties
- (NSFetchedResultsController*) frc_photos {
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    
    if (self.pageID == nil) {
        return nil;
    }
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", THEMEID, self.pageID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_photos = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_photos;
}

- (NSFetchedResultsController*) frc_captions {
    if (__frc_captions != nil) {
        return __frc_captions;
    }
    
    if (self.photoID == nil) {
        return nil;
    }
    ResourceContext* resourceContext = [ResourceContext instance];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", PHOTOID, self.photoID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_captions = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_captions;
}

#pragma mark - Toolbar buttons
- (NSArray*) toolbarButtonsForViewController {
    //returns an array with the toolbar buttons for this view controller
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    //add Facebook share button
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.tb_facebookButton = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(onFacebookButtonPressed:)];
    [retVal addObject:self.tb_facebookButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add Twitter share button
    self.tb_twitterButton = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(onTwitterButtonPressed:)];
    [retVal addObject:self.tb_twitterButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];

    //add camera button
    self.tb_cameraButton = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"icon-camera2.png"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(onCameraButtonPressed:)];
    [retVal addObject:self.tb_cameraButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    self.tb_voteButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"icon-thumbUp.png"]
                          style:UIBarButtonItemStylePlain
                          target:self
                          action:@selector(onVoteButtonPressed:)];
    [retVal addObject:self.tb_voteButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add draft button
    self.tb_captionButton = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"icon-compose.png"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onCaptionButtonPressed:)];
    [retVal addObject:self.tb_captionButton];
    
    
    return retVal;
}

#pragma mark - Initializers
- (id) commonInit {
    // Custom initialization
    
    self.photoViewSlider.delegate = self;
    self.captionViewSlider.delegate = self;
    
    self.photoViewSlider.tableView.pagingEnabled = YES;
    self.captionViewSlider.tableView.pagingEnabled = YES;
    
    self.photoViewSlider.tableView.allowsSelection = NO;
    self.captionViewSlider.tableView.allowsSelection = NO;
    
    [self.photoViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"photo"];
    [self.captionViewSlider initWithWidth:kCaptionWidth withHeight:kCaptionHeight withSpacing:kPictureSpacing useCellIdentifier:@"caption"];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self =  [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [self.photoViewSlider release];
    [self.captionViewSlider release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Navigation
- (void)updateNavigation {
    int photoCount = [[self.frc_photos fetchedObjects]count];
    int index = [self.photoViewSlider getPageIndex];
    
    // Navigation Bar Title
	if (photoCount > 0) {
		self.title = [NSString stringWithFormat:@"%i of %i", index+1, photoCount];		
	} else {
		self.title = nil;
	}    
}

- (int) indexOfPhotoWithID:(NSNumber*)photoid {
    //returns the index location within the frc_photos for the photo with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_photos fetchedObjects];
    int index = 0;
    for (Photo* photo in fetchedObjects) {
        if ([photo.objectid isEqualToNumber:photoid]) {
            retVal = index;
            break;
        }
        index++;
    }
    return retVal;
}

#pragma mark - View lifecycle
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void) renderPhoto {
    NSString* activityName = @"FullScreenPhotoViewController.renderPhoto:";
    
    //retrieves and draws the layout for the current Photo
    ResourceContext* resourceContext = [ResourceContext instance];
    Photo* currentPhoto = (Photo*)[resourceContext resourceWithType:PHOTO withID:self.photoID];
    
    if (currentPhoto != nil) {
        int indexOfPhoto = [self indexOfPhotoWithID:self.photoID];
        //we instruct the page view slider to move to the index of the page which is specified
        [self.photoViewSlider goTo:indexOfPhoto withAnimation:NO];
        [self.captionViewSlider goTo:0 withAnimation:NO];
    }
    else {
        //error state
        LOG_FULLSCREENPHOTOVIEWCONTROLLER(1,@"%@Could not find photo with id: %@ in local store",activityName,self.photoID);
    }
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // we update the toolbar items each time the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
    
    // Render the photo ID specified as a parameter
    if (self.photoID != nil && [self.photoID intValue] != 0) {
        //render the photo specified by the ID passed in
        [self renderPhoto];
    }
    else {
        //need to find the latest photo
        ResourceContext* resourceContext = [ResourceContext instance];
        Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withValueEqual:nil forAttribute:nil sortBy:DATECREATED sortAscending:NO];
        if (photo != nil) {
            //local store does contain photos to enumerate
            self.photoID = photo.objectid;
            [self renderPhoto];
        }
        else {
            //empty photo store, will need to thow up a progress dialog to show user of download

            //TODO: need to make a call to a centrally hosted busy indicator view
        }
    }
    
	// Navigation
	[self updateNavigation];

}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    self =  [self commonInit];
    
    self.captionCloudEnumerator = [[CloudEnumeratorFactory instance] enumeratorForCaptions:self.photoID];
    self.captionCloudEnumerator.delegate = self;
    [self.captionCloudEnumerator enumerateUntilEnd];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Toolbar Button Helpers
- (void) disableFacebookButton {
    self.tb_facebookButton.enabled = NO;
}

- (void) enableFacebookButton {
    self.tb_facebookButton.enabled = YES;
}

- (void) disableTwitterButton {
    self.tb_twitterButton.enabled = NO;
}

- (void) enableTwitterButton {
    self.tb_twitterButton.enabled = YES;
}

- (void) disableVoteButton {
    self.tb_voteButton.enabled = NO;
}

- (void) enableVoteButton {
    self.tb_voteButton.enabled = YES;
}

- (void) enableDisableVoteButton {
    
    int captionCount = [[self.frc_captions fetchedObjects] count];
    
    if (captionCount > 0) {
        
        [self enableVoteButton];
        
      //  int index = [self.captionViewSlider getPageIndex];
      // Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
      /*  
        if ([caption.user_hasvoted boolValue] == YES) {
            [self disableVoteButton];
        }
        else {
            [self enableVoteButton];
        }
      */  
    }
    else {
        [self disableVoteButton];
    }
}

#pragma mark - Toolbar Button Event Handlers

- (void) onFacebookButtonPressed:(id)sender {
    
       
    //we check to ensure the user is logged in to Facebook first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onFacebookButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
      
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        int count = [[self.frc_captions fetchedObjects]count];
        if (count > 0) {
            [self disableFacebookButton];
            int index = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            [sharingManager shareCaptionOnFacebook:caption.objectid onFinish:nil];
                   }
      
    }
}

- (void) onTwitterButtonPressed:(id)sender {
    //we check to ensure the user is logged in to Twitter first
    if (![self.authenticationManager isUserAuthenticated] ||
         ![[self.authenticationManager contextForLoggedInUser]hasTwitter]) {
        //user is not logged in, must log in first
        [self authenticate:NO withTwitter:YES onFinishSelector:@selector(onTwitterButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
      
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        int count = [[self.frc_captions fetchedObjects]count];
        if (count > 0) {
            [self disableTwitterButton];
            int index = [self.captionViewSlider getPageIndex];
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            [sharingManager shareCaptionOnTwitter:caption.objectid onFinish:nil];
        }
      
    }
}

- (void) onCameraButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onCameraButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewPhotoWithPageID:self.pageID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
    }
}

- (void) onVoteButtonPressed:(id)sender {
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    int photoIndex = [self.photoViewSlider getPageIndex];
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:photoIndex];
    
    int captionIndex = [self.captionViewSlider getPageIndex];
    Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:captionIndex];
    
    photo.numberofvotes = [NSNumber numberWithInt:([photo.numberofvotes intValue] + 1)];
    caption.numberofvotes = [NSNumber numberWithInt:([caption.numberofvotes intValue] + 1)];
    page.numberofpublishvotes = [NSNumber numberWithInt:([page.numberofpublishvotes intValue] + 1)];
    
    //caption.user_hasvoted = [NSNumber numberWithBool:YES];
    
    // animate the updating of the votes label
    /*[UIView animateWithDuration:0.25
                          delay:0
                        options:( UIViewAnimationCurveEaseInOut )
                     animations:^{
                         self.photoVotesLabel.transform = CGAffineTransformMakeScale( 1.5, 1.5 );
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:0
                                             options:( UIViewAnimationCurveEaseInOut )
                                          animations:^{
                                              self.photoVotesLabel.text = [NSString stringWithFormat:@"Votes: %@", self.photo.numberofvotes];
                                              self.photoVotesLabel.transform = CGAffineTransformMakeScale( 1.0, 1.0 );
                                          }
                                          completion:nil];
                     }];
    */
    
    //now we need to commit to the store
    [resourceContext save:YES onFinishCallback:nil];

}

- (void) onCaptionButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onCaptionButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewCaptionWithPageID:self.pageID withPhotoID:self.photoID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
    }
}


#pragma mark - UIPagedViewSlider2Delegate
- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:         (int)                   index 
             withFrame:         (CGRect)                frame {
    
    if (viewSlider == self.photoViewSlider) {
        int photoCount = [[self.frc_photos fetchedObjects]count];
        
        if (photoCount > 0 && index < photoCount) {
            UIImageView* iv_photo = [[UIImageView alloc] initWithFrame:frame];
            iv_photo.contentMode = UIViewContentModeScaleAspectFit;
            [self viewSlider:viewSlider configure:iv_photo forRowAtIndex:index withFrame:frame];
            return iv_photo;
        }
        else {
            return nil;
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            UICaptionView* v_caption = [[UICaptionView alloc] initWithFrame:frame];
            [self viewSlider:viewSlider configure:v_caption forRowAtIndex:index withFrame:frame];
            return v_caption;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    
    if (viewSlider == self.photoViewSlider) {
        int photoCount = [[self.frc_photos fetchedObjects]count];
        
        if (photoCount > 0 && index < photoCount) {
            Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
            
            existingCell.frame = frame;
            
            UIImageView* iv_photo = (UIImageView*)existingCell;
            
            ImageManager* imageManager = [ImageManager instance];
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:iv_photo forKey:kIMAGEVIEW];
            
            //add the photo id to the context
            [userInfo setValue:photo.objectid forKey:kPHOTOID];
            
            if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:nil atCallback:callback];
                
                if (image != nil) {
                    iv_photo.contentMode = UIViewContentModeScaleAspectFit;
                    iv_photo.image = image;
                }
                else {
                    iv_photo.contentMode = UIViewContentModeCenter;
                    iv_photo.image = [UIImage imageNamed:@"icon-pics2@2x.png"];
                }
            }
            else {
                iv_photo.backgroundColor = [UIColor redColor];
            }
            
            [self.photoViewSlider addSubview:iv_photo];
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        int captionCount = [[self.frc_captions fetchedObjects]count];
        
        if (captionCount > 0 && index < captionCount) {
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            existingCell.frame = frame;
            
            UICaptionView* v_caption = (UICaptionView*)existingCell;
            
            if (caption.caption1 != nil) {
                [v_caption renderCaptionWithID:caption.objectid];
            }
            [self.captionViewSlider addSubview:v_caption];
        }
    }
    
    [self enableDisableVoteButton];
    
}

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:         (int)                   index; {
    
    if (viewSlider == self.photoViewSlider) {
        
    }
    else if (viewSlider == self.captionViewSlider) {
        
    }
    
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
     
    if (viewSlider == self.photoViewSlider) {
        Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        self.photoID = photo.objectid;
        
        // reset frc_captions for the new photo
        self.frc_captions = nil;
        [self.frc_captions fetchedObjects];
        [self.captionViewSlider reset];
        
        [self renderPhoto];
        
        [self updateNavigation];
    }
    else if ((viewSlider == self.captionViewSlider) && ([[self.frc_captions fetchedObjects]count] != 0)) {
        Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
        self.captionID = caption.objectid;
    }
    
    [self enableDisableVoteButton];
    
}

- (int)   itemCountFor:         (UIPagedViewSlider2*)   viewSlider {
    int count = 0;
    if (viewSlider == self.photoViewSlider) {
        count = [[self.frc_photos fetchedObjects]count];
    }
    else if (viewSlider == self.captionViewSlider) {
        count = [[self.frc_captions fetchedObjects]count];
    }
    return count;
}

#pragma mark - Delegates and Protocols
#pragma mark Image Download Protocol
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"FullScreenPhotoViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    UIImageView* imageView = [userInfo valueForKey:kIMAGEVIEW];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        int count = [[self.frc_photos fetchedObjects]count];
        if (count > 0) {
            int index = [self.photoViewSlider getPageIndex];
            if (index == [self indexOfPhotoWithID:photoID]) {
                //we only draw the image if this view hasnt been repurposed for another draft
                LOG_IMAGE(1,@"%@settings UIImage object equal to downloaded response",activityName);
                [imageView performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [imageView setNeedsDisplay];
            }
        }
    }
    else {
        imageView.backgroundColor = [UIColor redColor];
        LOG_IMAGE(1,@"%@Image failed to download",activityName);
    }
}

#pragma mark CloudEnumeratorDelegate
- (void) onEnumerateComplete {
    
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"FullScreenPhotoViewController.controller.didChangeObject:";
    if (type == NSFetchedResultsChangeInsert) {
        if (controller == self.frc_photos) {
            //insertion of a new photo
            Resource* resource = (Resource*)anObject;
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
            [self.photoViewSlider onNewItemInsertedAt:[newIndexPath row]];
            [self.photoViewSlider goTo:[newIndexPath row] withAnimation:NO];
        }
        else if (controller == self.frc_captions) {
            //insertion of a new caption
            Resource* resource = (Resource*)anObject;
            LOG_FULLSCREENPHOTOVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
            [self.captionViewSlider onNewItemInsertedAt:[newIndexPath row]];
            [self.captionViewSlider goTo:[newIndexPath row] withAnimation:NO];
        }
    }
}

#pragma mark - Static Initializers
+ (FullScreenPhotoViewController*)createInstanceWithPageID:(NSNumber*)pageID withPhotoID:(NSNumber*)photoID {
    FullScreenPhotoViewController* photoViewController = [[FullScreenPhotoViewController alloc]initWithNibName:@"FullScreenPhotoViewController" bundle:nil];
    photoViewController.pageID = pageID;
    photoViewController.photoID = photoID;
    [photoViewController autorelease];
    return photoViewController;
}


@end
