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
#import "Photo.h"
#import "ImageManager.h"
#import "Macros.h"

#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "ApplicationSettings.h"


#define kPictureWidth               320
#define kPictureHeight              480
#define kPictureSpacing             0

#define kCaptionWidth               320
#define kCaptionHeight              70
#define kCaptionSpacing             0

#define kPHOTOID @"photoid"

@implementation FullScreenPhotoViewController

@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;

@synthesize captionCloudEnumerator  = m_captionCloudEnumerator;

@synthesize pageID                  = m_pageID;
@synthesize photoID                 = m_photoID;

@synthesize photoViewSlider         = m_photoViewSlider;
@synthesize captionViewSlider       = m_captionViewSlider;


#pragma mark - Properties
- (NSFetchedResultsController*) frc_photos {
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    
    if (self.pageID == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", THEMEID, self.pageID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
    
    //add predicate to gather only photos for this pageID    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", PHOTOID, self.photoID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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
    
    int count = [[self.frc_captions fetchedObjects]count];
    
    return __frc_captions;
}

#pragma mark - Frames
- (CGRect) frameForPhotoSlider {
    return CGRectMake(0, 0, kPictureWidth, kPictureHeight);
}

- (CGRect) frameForCaptionSlider {
    return CGRectMake(0, 100, kCaptionWidth, kCaptionHeight);
}

#pragma mark - Initializers
- (id) commonInit {
    // Custom initialization
    
    CGRect frameForPhotoSlider = [self frameForPhotoSlider];
    //self.photoViewSlider = [[UIPagedViewSlider2 alloc]initWithFrame:frameForPhotoSlider];
    self.photoViewSlider.delegate = self;
    self.captionViewSlider.delegate = self;
    
    self.photoViewSlider.tableView.pagingEnabled = YES;
    self.captionViewSlider.tableView.pagingEnabled = YES;
    //[self.view addSubview:self.photoViewSlider];
    
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
    
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
    // Navigation bar
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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

#pragma mark - Navigation
- (void)updateNavigation {
    NSArray* photos = [self.frc_photos fetchedObjects];
    int index = [self.photoViewSlider getPageIndex];
    // Navigation Bar Title
	if (photos.count > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", index+1, photos.count];		
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

#pragma mark - UIPagedViewSlider2Delegate
- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:         (int)                   index 
             withFrame:         (CGRect)                frame {
    
    if (viewSlider == self.photoViewSlider) {
        int photoCount = [[self.frc_photos fetchedObjects]count];
        
        if (photoCount > 0 && index < photoCount) {
            UIImageView* iv_photo = [[UIImageView alloc] initWithFrame:frame];
            [self viewSlider:viewSlider configure:iv_photo forRowAtIndex:index withFrame:frame];
            return iv_photo;
        }
        else {
            return nil;
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        //int captionCount = [[self.frc_captions fetchedObjects]count];
        
        //if (captionCount > 0 && index < captionCount) {
            UILabel* lbl_caption = [[UILabel alloc] initWithFrame:frame];
            [self viewSlider:viewSlider configure:lbl_caption forRowAtIndex:index withFrame:frame];
            return lbl_caption;
        //}
        //else {
        //    return nil;
        //}
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
            iv_photo.backgroundColor = [UIColor blueColor];
            
            ImageManager* imageManager = [ImageManager instance];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:existingCell forKey:kPHOTOID];
            
            if (photo.imageurl != nil && ![photo.imageurl isEqualToString:@""]) {
                Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownload:withUserInfo:) withContext:userInfo];
                UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:callback];
                
                if (image != nil) {
                    iv_photo.image = image;
                }
                else {
                    iv_photo.backgroundColor = [UIColor blueColor];
                }
            }
            else {
                iv_photo.backgroundColor = [UIColor redColor];
            }
            [self.photoViewSlider addSubview:iv_photo];
        }
    }
    else if (viewSlider == self.captionViewSlider) {
        //int captionCount = [[self.frc_captions fetchedObjects]count];
        
        //if (captionCount > 0 && index < captionCount) {
            Caption* caption = [[self.frc_captions fetchedObjects]objectAtIndex:index];
            
            existingCell.frame = frame;
            
            UILabel* lbl_caption = (UILabel*)existingCell;
            lbl_caption.backgroundColor = [UIColor blueColor];
            
            if (caption.caption1 != nil) {
                lbl_caption.text = caption.caption1;
            }
            else {
                lbl_caption.text = @"CAPTION WAS NIL";
            }
            [self.captionViewSlider addSubview:lbl_caption];
        //}
    }
    
    /*CGRect frameForCaptionSlider = [self frameForCaptionSlider];
    frameForCaptionSlider.origin.x = frame.origin.x;
    UIPagedViewSlider2* captionViewSlider2 = [[UIPagedViewSlider2 alloc]initWithFrame:frameForCaptionSlider];
    captionViewSlider2.delegate = self;
    captionViewSlider2.tableView.pagingEnabled = YES;
    captionViewSlider2.backgroundColor = [UIColor blueColor];
    [captionViewSlider2 initWithWidth:kCaptionWidth withHeight:kCaptionHeight withSpacing:kCaptionSpacing useCellIdentifier:@"caption"];
    [self.view addSubview:captionViewSlider2];*/
    
}

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:         (int)                   index; {
    
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
     
    [self updateNavigation];

}

- (int)   itemCountFor:         (UIPagedViewSlider2*)   viewSlider {
    int count = [[self.frc_photos fetchedObjects]count];
    return count;
}

#pragma mark - Delegates and Protocols
#pragma mark Image Download Protocol
- (void)onImageDownload:(UIImage *)image withUserInfo:(NSDictionary *)userInfo {
    UIImageView* imageView = [userInfo objectForKey:kPHOTOID];
    imageView.image = image;
}

#pragma mark CloudEnumeratorDelegate
- (void) onEnumerateComplete {
    
}

#pragma mark NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [self.photoViewSlider onNewItemInsertedAt:newIndexPath.row];
        
    }
}

#pragma mark - Static Initializers
+ (FullScreenPhotoViewController*)createInstance {
    FullScreenPhotoViewController* photoViewController = [[FullScreenPhotoViewController alloc]initWithNibName:@"FullScreenPhotoViewController" bundle:nil];
    [photoViewController autorelease];
    return photoViewController;
}


@end
