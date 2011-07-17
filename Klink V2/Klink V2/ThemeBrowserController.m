//
//  ThemeBrowserController.m
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ThemeBrowserController.h"
#import "DataLayer.h"
#import "NSStringGUIDCategory.h"
#import "ImageManager.h"
#import "Photo.h"
#import "TestSliderView.h"
#define kPictureWidth 130
#define kPictureSpacing 30
#define kPictureHeight 100

@implementation ThemeBrowserController
@synthesize managedObjectContext;
@synthesize theme;
@synthesize imgv_themeHomeImage;
@synthesize vs_themePhotoSlider;
@synthesize ec_activeThemePhotoContext;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize frc_themes = __frc_themes;
@synthesize m_isThereAThemePhotoEnumerationAlreadyExecuting;
@synthesize tv_ThemeID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        ec_activeThemePhotoContext = nil;
        m_isThereAThemePhotoEnumerationAlreadyExecuting = NO;
        //in the future we will store the contect in persistence and load it from there if we have it
        
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

- (BOOL) shouldUpdateFromWebService {
    return NO;
}

- (void) registerNotification:(NSString*) notificationID  targetSelector:(SEL)targetSelector targetObject:(id) targetObject {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:targetObject selector:targetSelector name:notificationID object:nil];
    
}

- (void) enumerateFromWebService {
    WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
    QueryOptions* queryOptions = [QueryOptions queryForThemes];
    
    NSString* notificationID = [NSString GetGUID];
    [self registerNotification:notificationID targetSelector:@selector(onEnumerateThemesFinished:) targetObject:self];

    [enumerationManager enumerateThemes:[NSNumber numberWithInt:batchSize_THEME] withQueryOptions:queryOptions onFinishNotify:notificationID];
}

#pragma mark - Enumeration Completion Handlers
- (void)onEnumerateThemesFinished:(NSNotification*)notification {
    
}

- (void)onEnumeratePhotosForThemeFinished:(NSNotification*)notification {
    NSString* activityName = @"ThemeBrowserController.onEnumeratePhotosForThemeFinished:";
    NSDictionary *userInfo = [notification userInfo];
    if ([userInfo objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
        EnumerationContext* returnedContext = [userInfo objectForKey:an_ENUMERATIONCONTEXT];
        if ([returnedContext.isDone boolValue] == NO) {
            //enumeration remains open
            NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved for future use",returnedContext.isDone];
            [BLLog v:activityName withMessage:message];
            self.ec_activeThemePhotoContext = returnedContext;
        }
        else {
            //enumeration is complete, set the context to nil
            
            NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved value set to null",returnedContext.isDone];
            [BLLog v:activityName withMessage:message];
            [returnedContext release];
            self.ec_activeThemePhotoContext = nil;
            
        }
 
    }
    m_isThereAThemePhotoEnumerationAlreadyExecuting = NO;
}

#pragma mark - View Controller Theme Assignment
- (void) assignTheme:(Theme*)themeObject {
    __fetchedResultsController = nil;
    self.theme = themeObject;    
    self.tv_ThemeID.text = [NSString stringWithFormat:@"Loaded Theme ID %@",themeObject.objectid];
    NSArray* photos = [self.fetchedResultsController fetchedObjects];
    [vs_themePhotoSlider hasNumberOfElements:[photos count] itemWidth:kPictureWidth itemHeight:kPictureHeight itemSpacing:kPictureSpacing];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    
    if (self.theme == nil) {
        //no theme set for this browser to display, retrieve the latest theme from the DB
        NSArray* themes = [self.frc_themes fetchedObjects];
        if ([themes count] > 0) {
            [self assignTheme:[themes objectAtIndex:0]];
        }
    }
    else {
        [self assignTheme:self.theme];
    }
    
   
    
    if ([self shouldUpdateFromWebService]) {
        //if yes, we should execute a refresh of theme objects from the web service
        [self enumerateFromWebService];
    }
 
    
    
    [imgv_themeHomeImage init];
    [super viewDidLoad];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (self.theme != nil) {
        //now we populate the ui contorls for the theme viewer
        
    }

    [super viewDidAppear:animated];
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

#pragma mark - UIViewSlider Fetched Results Controller
//returns a fetched results controller for theme objects
- (NSFetchedResultsController*) frc_themes {
    if (__frc_themes != nil) {
        return __frc_themes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tn_THEME inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:NO];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_themes = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_themes;
}


//Returns a fetched controller delegate to populate the image slider for the current theme
- (NSFetchedResultsController*) fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:NO];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"themeid=%@",self.theme.objectid];
    [fetchRequest setPredicate:predicate];
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
-(void) frc_themes_didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        if (self.theme == nil) {
            //need to set the view controller's theme to theme
            [self assignTheme:anObject];
        }
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
   
    if (controller == self.fetchedResultsController) {
        
        if (type == NSFetchedResultsChangeInsert) {
            [vs_themePhotoSlider datasetItemAddedAt:[newIndexPath row]];
            
        }
        else if (type == NSFetchedResultsChangeMove) {
            [vs_themePhotoSlider datasetHasChangedAt:[newIndexPath row]];
        }
    }
    else {
        //its a new object in the theme controller
        [self frc_themes_didChangeObject:anObject
                             atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    }
    
    
}

#pragma mark - Image Download Protocol
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo {
    
    UIImageView* v = [userInfo objectForKey:an_IMAGEVIEW];
    if (v != nil) {
        [v setImage:image];
        [vs_themePhotoSlider setNeedsDisplay];
    }
    
}


#pragma mark - UIViewSliderDelegate 


- (id) configureViewFor:(Photo*)photo atIndex:(int)index {
    ImageManager *imageManager = [ImageManager getInstance];
   
    
    //need to grab the photo, create the image view, and then return that sucker
    int xCoordinateForImage = (index )* (kPictureWidth + kPictureSpacing);
    
    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, kPictureHeight);    
    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
    UITextView* textView = [[[UITextView alloc]initWithFrame:rect]autorelease];
    TestSliderView* testSliderView = [[TestSliderView alloc]initWithFrame:rect];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
    [userInfo setObject:imageView forKey:an_IMAGEVIEW];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];   
    
    textView.text = [NSString stringWithFormat:@"Date Created: %@",[DateTimeHelper formatDateForWebService:self.theme.datecreated]];
    testSliderView.tv_DisplayName.text = photo.descr;
    testSliderView.tv_DateCreated.text = [DateTimeHelper formatDateForWebService:photo.datecreated];
    testSliderView.tv_Other = [photo.objectid stringValue];
    
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

- (UIView*)viewSlider:(UIViewSlider *)viewSlider cellForRowAtIndex:(int)index {
    
    Photo* photo = [[self.fetchedResultsController fetchedObjects]objectAtIndex:index];
    return [self configureViewFor:photo atIndex:index];
    
    
}

//we will use this method to pre-fetch additional pictures for a particular theme as a user pulls on the listÔ
- (void)viewSlider:(UIViewSlider*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    NSString* activityName = @"ThemeBrowserController.viewSlider.isAtIndex:";
    //need to launch a new enumeration if the user gets within a certain threshold of the end scroll position
    if (numberOfCellsToEnd < threshold_LOADMOREPHOTOS) {
        //the current scroll position is below the threshold, thus we need to load more photos for this particular theme
        
        if (ec_activeThemePhotoContext == nil) {
            //if we have a nil contect, that means we have yet to query for the photos in this theme directly
            self.ec_activeThemePhotoContext = [EnumerationContext contextForPhotosInTheme:self.theme];
        }
        
        //execute the enumeration only if there is not already one executing
        if (!m_isThereAThemePhotoEnumerationAlreadyExecuting) {

            
            m_isThereAThemePhotoEnumerationAlreadyExecuting = YES;
            WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
            QueryOptions* queryOptions = [QueryOptions queryForPhotosInTheme];
            
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            NSString* notificationID = [NSString GetGUID];
            [notificationCenter addObserver:self selector:@selector(onEnumeratePhotosForThemeFinished:) name:notificationID object:nil];
            
            [enumerationManager enumeratePhotosInTheme:self.theme withQueryOptions:queryOptions onFinishNotify:notificationID useEnumerationContext:self.ec_activeThemePhotoContext shouldEnumerateSinglePage:YES];
            
            NSString* message = [NSString stringWithFormat:@"executing web service enumeration due to scroll threshold being crossed"];
            [BLLog v:activityName withMessage:message];
        }
    }
}


@end
