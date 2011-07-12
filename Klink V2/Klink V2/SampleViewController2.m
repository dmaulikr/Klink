//
//  SampleViewController2.m
//  Klink V2
//
//  Created by Bobby Gill on 7/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SampleViewController2.h"
#import "Photo.h"
#import "ImageManager.h"
#import "NSStringGUIDCategory.h"
#define kPictureWidth 130
#define kPictureSpacing 30
#define kPictureHeight 100
#define kNumPrevImagesToLoad 0
#define kNumNextImagesToLoad 1

@implementation SampleViewController2
@synthesize m_viewSlider;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AuthenticationManager* authenticationManager = [[AuthenticationManager getInstance]retain];
    //Create dummy authentication context
    NSMutableDictionary* authenticationContextDictionary = [[NSMutableDictionary alloc]init];
    NSTimeInterval currentDateInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *currentDate = [NSNumber numberWithDouble:currentDateInSeconds];
    
    [authenticationContextDictionary setObject:[NSNumber numberWithInt:1] forKey:an_USERID];
    [authenticationContextDictionary setObject:[currentDate stringValue] forKey:an_EXPIRY_DATE];
    [authenticationContextDictionary setObject:[NSString stringWithFormat:@"dicks"] forKey:an_TOKEN];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tn_AUTHENTICATIONCONTEXT inManagedObjectContext:self.managedObjectContext];
    AuthenticationContext* context = [[[AuthenticationContext alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:nil]initFromDictionary:authenticationContextDictionary];
    [authenticationManager loginUser:[NSNumber numberWithInt:1] withAuthenticationContext:context];
    [context release];
    
    NSArray* photoObjects = [self.fetchedResultsController fetchedObjects];
    
    [m_viewSlider init];
    [m_viewSlider hasNumberOfElements:[photoObjects count] itemWidth:kPictureWidth itemHeight:kPictureHeight itemSpacing:kPictureSpacing];
    

        //in this case there are no results so we instruct the manager to enumerate
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        QueryOptions* queryOptions = [QueryOptions queryForPhotos];
        
        NSString* notificationID = [NSString GetGUID];
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(onEnumerationFinish:) name:notificationID object:nil];
        
        [enumerationManager enumerateObjectsWithType:PHOTO maximumNumberOfResults:[NSNumber numberWithInt:1000] withQueryOptions:queryOptions onFinishNotify:notificationID];
    

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

- (void)onEnumerationFinish:(NSNotification*)notification {
    NSLog(@"enumeration complete");
}

#pragma mark - UIViewSliderDelegate 
- (UIView*)viewSlider:(UIViewSlider *)viewSlider cellForRowAtIndex:(int)index {
 
    Photo* photo = [[self.fetchedResultsController fetchedObjects]objectAtIndex:index];
    return [self configureViewFor:photo atIndex:index];
    
   
}

- (UIImageView*) configureViewFor:(Photo*)photo atIndex:(int)index {
    ImageManager *imageManager = [ImageManager getInstance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];    
    
    //need to grab the photo, create the image view, and then return that sucker
    int xCoordinateForImage = (index )* (kPictureWidth + kPictureSpacing);
    
    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, kPictureHeight);    
    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
    
    if (image != nil) {
        imageView.image = image;
        
//        imageView.backgroundColor = [UIColor blackColor];
//        
    }
    else {
        imageView.backgroundColor = [UIColor blackColor];
    }
    
    return imageView;
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController*) fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __fetchedResultsController;
    
}

#pragma mark - Fetched Results Controller Delegate Methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        [m_viewSlider datasetItemAddedAt:[newIndexPath row]];

    }
    else if (type == NSFetchedResultsChangeMove) {
        [m_viewSlider datasetHasChangedAt:[newIndexPath row]];
    }
    
    
}

#pragma mark - Image Download Protocol
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    
    NSNumber* index = [userInfo objectForKey:an_INDEXPATH];
    UIImageView* v = [m_viewSlider viewAt:[index intValue]];
    [v setImage:image];

    

}
@end
