//
//  SampleViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SampleViewController.h"
#import "Photo.h"
#import "WS_EnumerationManager.h"
#import "NSStringGUIDCategory.h"
#import "ImageManager.h"

#define kPictureWidth 130
#define kPictureSpacing 30
#define kHeight 100
#define kNumPrevImagesToLoad 10
#define kNumNextImagesToLoad 10

@implementation SampleViewController
@synthesize scrollView;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize imageSlider;

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
 
//    
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

    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://school.discoveryeducation.com/clipart/images/cookbook.gif"]];
    
    NSArray* photoObjects = [self.fetchedResultsController fetchedObjects];
    
    int numPictures = [photoObjects count];    
    imageSlider = [[NSMutableArray alloc]initWithCapacity:numPictures];
    for (int i = 0; i < numPictures; i++) {
        NSNull* null = [NSNull null];
        [imageSlider insertObject:null atIndex:i];
        [self addPlaceholderAtIndex:[NSNumber numberWithInt:i]];
        
    }
    
    int width = numPictures * (kPictureWidth + kPictureSpacing);
    [scrollView setContentSize:CGSizeMake(width, kHeight)];
    
    if ([photoObjects count] > 0) {
        //need to calculate the correct content width 
        
        
//        for (int i = 0; i < 3; i++) {
//            Photo* photo = [photoObjects objectAtIndex:i];
//            [self add:photo atIndex:[NSNumber numberWithInt:i]];
//        }
    }
    else {
        //in this case there are no results so we instruct the manager to enumerate
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        QueryOptions* queryOptions = [QueryOptions queryForPhotos];
        
        NSString* notificationID = [NSString GetGUID];
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(onEnumerationFinish:) name:notificationID object:nil];
        
        [enumerationManager enumerateObjectsWithType:PHOTO maximumNumberOfResults:[NSNumber numberWithInt:10] withQueryOptions:queryOptions onFinishNotify:notificationID];
    }

    
    [super viewDidLoad];
}

- (void)addPlaceholderAtIndex:(NSNumber*)index {
    
    int xCoordinateForImage = ([index integerValue] )* (kPictureWidth + kPictureSpacing);
    
    
    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, 300); 
    CGRect rectTV = CGRectMake(0, 20, 130, 70);
    
    UITextView* textView = [[UITextView alloc]initWithFrame:rectTV];
    textView.text = [index stringValue];
    [textView setEditable:NO];
    UIView* view = [[UIView alloc]initWithFrame:rect];
    [view setBackgroundColor:[UIColor blackColor]];
    [view addSubview:textView];
    [scrollView addSubview:view];
    [view release];
    [textView release];
}

- (void)add:(Photo*)photo atIndex:(NSNumber*)index {      
    int xCoordinateForImage = ([index integerValue] )* (kPictureWidth + kPictureSpacing);
    
    ImageManager *imageManager = [ImageManager getInstance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:index forKey:an_INDEXPATH];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
  
    
//    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, 100);    
    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, 100);    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:rect];
    
    if (image != nil) {
        imageView.image = image;
    }
    else {
        imageView.backgroundColor = [UIColor blackColor];
    }
    [imageSlider replaceObjectAtIndex:[index integerValue] withObject:imageView];    
    [scrollView insertSubview:imageView atIndex:[index integerValue]];
        
    
    
//     CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, 100); 
//    CustomVie2* custom = [[CustomVie2 alloc]initWithFrame:rect];
//    [custom setIndexNumber:[index stringValue]];
//    [imageSlider replaceObjectAtIndex:[index integerValue] withObject:custom];
//    [scrollView addSubview:custom];
  
  
}



- (void)onEnumerationFinish:(NSNotification*)notification {
    NSLog(@"enumeration complete");
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

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController*) fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:NO];
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
    
        //need to insert this into our list of image views
        Photo* photo = (Photo*)anObject;
        NSLog(@"Inserting new item into list at index %@",[newIndexPath row]);
        [imageSlider insertObject:[NSNull null] atIndex:[newIndexPath row]];
        
        CGSize currentContentSize = scrollView.contentSize;
        int existingWidth = currentContentSize.width;
        int existingHeight = currentContentSize.height;
        
        existingWidth += kPictureWidth+kPictureSpacing;
        CGSize newContentSize = CGSizeMake(existingWidth, existingHeight);
        scrollView.contentSize = newContentSize;
        
        [self addPlaceholderAtIndex:[NSNumber numberWithUnsignedInt:[newIndexPath row]]];
        [self add:photo atIndex:[NSNumber numberWithUnsignedInt:[newIndexPath row]]];
        
      //  [self add:photo atIndex:[NSNumber numberWithUnsignedInteger:[indexPath row]]];
    }
    else if (type == NSFetchedResultsChangeMove) {
        int newIndex = [newIndexPath row];
        int oldIndex = [indexPath row];
        
        if (newIndex > ([imageSlider count]-1)) {
            
        }
        else {
            Photo* photo = (Photo*)anObject;
            
            UIImageView* imageView = [imageSlider objectAtIndex:oldIndex];
            [imageView removeFromSuperview];

            [imageSlider replaceObjectAtIndex:oldIndex withObject:[NSNull null]];
            
            [self add:photo atIndex:[NSNumber numberWithInt:newIndex]];
            
            
            
        }
    }
    
    
}

#pragma mark - Image Download Callback Methods
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    
    NSNumber* index = [userInfo objectForKey:an_INDEXPATH];
    if ([imageSlider objectAtIndex:[index integerValue]] != [NSNull null]) {
        UIImageView* imageView = [imageSlider objectAtIndex:[index integerValue]];
        
        [imageView setImage:image];
    }
    
    
    
}

#pragma mark - UI Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint position =  scrollView.contentOffset;
    
    //need to translate the x-coordinate to the appropriate set of images to draw
    int xCoordinate = position.x;
    
    int index = xCoordinate / (kPictureWidth+kPictureSpacing);
    
  
    NSLog(@"Scroll Stopped at Index %@",[NSNumber numberWithInt:index]);
    
    
    int maxNumberOfItems = [[self.fetchedResultsController fetchedObjects] count];
    //get 10 photos forwards
    //get 10 photos backwards
    int startIndex = index - kNumPrevImagesToLoad;
    int endIndex = index + kNumNextImagesToLoad;
    
    if (endIndex > maxNumberOfItems) {
        endIndex =maxNumberOfItems;
    }
    
    if (startIndex < 0) {
        startIndex = 0;
    }
    
    for (int i = startIndex; i<endIndex; i++) {
        if ([imageSlider objectAtIndex:i] != [NSNull null]) {
//            CustomVie2* customvie = [imageSlider objectAtIndex:i];
//            [customvie removeFromSuperview];
//            [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
            
            UIImageView* imageView = [imageSlider objectAtIndex:i];
            [imageView removeFromSuperview];
            [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
            
        }
        
        Photo* photo = [[self.fetchedResultsController fetchedObjects]objectAtIndex:i];
        [self add:photo atIndex:[NSNumber numberWithInt:i]];

      
    }
    
    //now we need to manage our memory such that we have a fixed amount being used
    for (int i = 0; i < startIndex; i++) {
       if ([imageSlider objectAtIndex:i] != [NSNull null]) {
            UIImageView* imageView = [imageSlider objectAtIndex:i];
            [imageView removeFromSuperview];
            imageView = nil;
             [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
       } 
//        CustomVie2* customvie2 = [imageSlider objectAtIndex:i];
//        if (customvie2 != [NSNull null]) {
//            [customvie2 removeFromSuperview];
//            customvie2 = nil;
//            
//            [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
//        }
//        }
    }
    
    for (int i = endIndex; i < maxNumberOfItems;i++) {
        if ([imageSlider objectAtIndex:i] != [NSNull null]) {
            UIImageView* imageView = [imageSlider objectAtIndex:i];
            [imageView removeFromSuperview];
            imageView = nil;
              [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
        }
        
//            CustomVie2* customvie2 = [imageSlider objectAtIndex:i];
//            if (customvie2 != [NSNull null]) {
//                [customvie2 removeFromSuperview];
//                customvie2 = nil;
//                 [imageSlider replaceObjectAtIndex:i withObject:[NSNull null]];
//            }
           
//        }
    }
    

   
    
}

@end
