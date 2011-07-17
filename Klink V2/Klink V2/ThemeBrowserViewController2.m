//
//  ThemeBrowserViewController2.m
//  Klink V2
//
//  Created by Bobby Gill on 7/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ThemeBrowserViewController2.h"
#import "ImageManager.h"
#import "TestSliderView.h"
#import "Photo.h"
#import "NSStringGUIDCategory.h"
#import <QuartzCore/QuartzCore.h>

#define kPictureWidth 130
#define kPictureSpacing 5
#define kPictureHeight 120

#define kThemePictureWidth 320
#define kThemePictureHeight 200
#define kThemePictureSpacing 0

#define kTextViewWidth 300
#define kTextViewHeight 30
#define kTextViewDescriptionHeight 70

#define kCaptionTextViewHeight 10
#define kCaptionTextViewWidth 120
@implementation ThemeBrowserViewController2
@synthesize pvs_photoSlider;
@synthesize pvs_themeSlider;
@synthesize theme;
@synthesize managedObjectContext;
@synthesize frc_photosInCurrentTheme = __frc_photosInCurrentTheme;
@synthesize frc_themes = __frc_themes;
@synthesize lbl_theme;
@synthesize ec_activeThemePhotoContext;
@synthesize m_isThereAThemePhotoEnumerationAlreadyExecuting;
@synthesize ec_activeThemeContext;
@synthesize m_isThereAThemeEnumerationAlreadyExecuting;
@synthesize m_outstandingPhotoEnumNotificationID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

- (void) registerNotification:(NSString*) notificationID  targetSelector:(SEL)targetSelector targetObject:(id) targetObject {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:targetObject selector:targetSelector name:notificationID object:nil];
    
}



#pragma mark - View Controller Theme Assignment
- (void) assignTheme:(Theme*)themeObject {
    NSString* activityName = @"ThemeBrowserViewController2.assignTheme:";
    __frc_photosInCurrentTheme = nil;
    NSNumber* oldThemeID = self.theme.objectid;
   
    self.theme = themeObject;    
    self.lbl_theme.text = [NSString stringWithFormat:@"Loaded Theme ID %@",themeObject.objectid];
    
    NSString* message = [NSString stringWithFormat:@"Changing from ThemeID:%@ to ThemeID:%@",[oldThemeID stringValue],[themeObject.objectid stringValue]];
    [BLLog v:activityName withMessage:message];
    
    NSArray* photos = [self.frc_photosInCurrentTheme fetchedObjects];
    [self.pvs_photoSlider resetSliderWithItems:photos];
    self.ec_activeThemePhotoContext = [EnumerationContext contextForPhotosInTheme:self.theme];
    self.m_outstandingPhotoEnumNotificationID = nil;
    self.m_isThereAThemePhotoEnumerationAlreadyExecuting = NO;
}



- (void) enumerateThemesFromWebService {
    NSString* activityName = @"ThemeBrowserController.enumerateThemesFromWebService:";
    if (ec_activeThemeContext == nil) {
        //if we have a nil contect, that means we have yet to query for the photos in this theme directly
        self.ec_activeThemeContext = [EnumerationContext contextForThemes];
    }
    
    //execute the enumeration only if there is not already one executing
    if (!m_isThereAThemeEnumerationAlreadyExecuting &&
        ec_activeThemeContext.isDone!=[NSNumber numberWithBool:YES]) {
        
        m_isThereAThemeEnumerationAlreadyExecuting = YES;
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        QueryOptions* queryOptions = [QueryOptions queryForThemes];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        NSString* notificationID = [NSString GetGUID];
        [notificationCenter addObserver:self selector:@selector(onEnumerateThemesFinished:) name:notificationID object:nil];
        
        [enumerationManager enumerateThemes:[NSNumber numberWithInt:maxsize_THEMEDOWNLOAD] withPageSize:[NSNumber numberWithInt:pageSize_THEME] withQueryOptions:queryOptions onFinishNotify:notificationID useEnumerationContext:ec_activeThemeContext shouldEnumerateSinglePage:YES];
        
        
        NSString* message = [NSString stringWithFormat:@"executing web service enumeration due to scroll threshold being crossed"];
        [BLLog v:activityName withMessage:message];
    }
    
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    NSString* activityName = @"ThemeBrowserViewController2.viewDidLoad:";   
    self.pvs_photoSlider.layer.borderWidth = 1.0f;
    self.pvs_photoSlider.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pvs_themeSlider.layer.borderWidth = 1.0f;
    self.pvs_themeSlider.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.pvs_themeSlider initWith:kThemePictureWidth itemHeight:kThemePictureHeight itemSpacing:kThemePictureSpacing];
    [self.pvs_photoSlider initWith:kPictureWidth itemHeight:kPictureHeight itemSpacing:kPictureSpacing];
    
    if (self.theme == nil) {
        NSArray* themes = self.frc_themes.fetchedObjects;
        [pvs_themeSlider resetSliderWithItems:themes];
        if ([themes count] > 0) {
            [self assignTheme:[themes objectAtIndex:0]];
        }
        else {
            //need to issue request to get themes from web service
            NSString* message = [NSString stringWithFormat:@"No themes found in database, enumerating from the web service"];
            [BLLog v:activityName withMessage:message];
            
            [self enumerateThemesFromWebService];
        }
        
    }
     

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
- (NSFetchedResultsController*) frc_photosInCurrentTheme {
    if (__frc_photosInCurrentTheme != nil) {
        return __frc_photosInCurrentTheme;
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
    self.frc_photosInCurrentTheme = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_photosInCurrentTheme;
    
}

#pragma mark - Fetched Results Controller Delegate Methods
-(void) frc_themes_didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        [pvs_themeSlider item:anObject insertedAt:[newIndexPath row]];
        if (self.theme == nil) {
            //need to set the view controller's theme to theme
            [self assignTheme:anObject];
        }
    }
    else if (type == NSFetchedResultsChangeMove) {
        [pvs_themeSlider item:anObject atIndex:[indexPath row] movedTo:[newIndexPath row]];
    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (controller == self.frc_photosInCurrentTheme) {
        
        if (type == NSFetchedResultsChangeInsert) {
            [pvs_photoSlider item:anObject insertedAt:[newIndexPath row] ];
          
            
        }
        else if (type == NSFetchedResultsChangeMove) {
            [pvs_photoSlider item:anObject atIndex:[indexPath row] movedTo:[newIndexPath row]];
        }
    }
    else if (controller == self.frc_themes) {
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
        [pvs_photoSlider setNeedsDisplay];
    }
    
}

#pragma mark - UIViewSliderDelegate 


- (id) configureViewFor:(Photo*)photo atIndex:(int)index {
    ImageManager *imageManager = [ImageManager getInstance];
    
    
    //need to grab the photo, create the image view, and then return that sucker
    int xCoordinateForImage = (kPictureWidth+kPictureSpacing)*index;
    
    CGRect rect = CGRectMake(xCoordinateForImage, 0, kPictureWidth, kPictureHeight);    
    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
    
    //Create the caption label for the current photo
    Caption* topCaption = photo.topCaption;
    
    if (topCaption != nil) {
        int xCoordinateForCaption = 10;
        int yCoordinateForCaption = kPictureHeight - kCaptionTextViewHeight;
        CGRect captionFrame = CGRectMake(xCoordinateForCaption, yCoordinateForCaption, kCaptionTextViewWidth, kCaptionTextViewHeight);
        UILabel* captionLabel = [[[UILabel alloc]initWithFrame:captionFrame]autorelease];
        captionLabel.text = topCaption.caption1;
        captionLabel.textColor = [UIColor whiteColor];
        captionLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        captionLabel.numberOfLines = 0;
        captionLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [imageView addSubview:captionLabel];
        
    }
    
    [userInfo setObject:imageView forKey:an_IMAGEVIEW];        
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];  
    if (image != nil) {
        
        imageView.image = image;
     
    }
    else {
        imageView.backgroundColor = [UIColor blackColor];
    }
    
    return imageView;
}

- (id) configureViewForTheme:(Theme*)theme atIndex:(int)index {
    ImageManager *imageManager = [ImageManager getInstance];
    
    int xCoordinateForImage = (kThemePictureWidth+kThemePictureSpacing)*index;
    CGRect rect = CGRectMake(xCoordinateForImage, 0, 320, kThemePictureHeight);
    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:rect]autorelease];
    
    int xCoordinateForText = 10;
    int yCoordinateForText = 10;
    int yCoordinateForDescription = kThemePictureHeight - kTextViewDescriptionHeight;
    
    //The following adds the text label for the theme display name
    CGRect textViewFrame = CGRectMake(xCoordinateForText,yCoordinateForText,kTextViewWidth,kTextViewHeight);
    UILabel* textView = [[[UILabel alloc]initWithFrame:textViewFrame]autorelease];
    textView.textColor = [UIColor whiteColor];
    textView.numberOfLines = 0;
    textView.lineBreakMode = UILineBreakModeWordWrap;
    textView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    textView.text = theme.displayname;
    [imageView addSubview:textView];
    
    
    //The following adds the text label for the theme description
    CGRect textViewDescriptionFrame = CGRectMake(xCoordinateForText, yCoordinateForDescription, kTextViewWidth, kTextViewDescriptionHeight);
    UILabel* textViewDescription = [[[UILabel alloc]initWithFrame:textViewDescriptionFrame]autorelease];
    textViewDescription.textColor = [UIColor whiteColor];
    textViewDescription.numberOfLines = 0;
    textViewDescription.lineBreakMode = UILineBreakModeWordWrap;
    textViewDescription.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    textViewDescription.text = theme.descr;
    [imageView addSubview:textViewDescription];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];

    [userInfo setObject:imageView forKey:an_IMAGEVIEW];        
    
    UIImage* image = [imageManager downloadImage:theme.homeimageurl withUserInfo:userInfo atCallback:self];   
    
    if (image != nil) {
        imageView.image = image;
    }
    else {
        imageView.backgroundColor =[UIColor blackColor];
    }
    return imageView;
    
}

- (UIView*)viewSlider:(UIPagedViewSlider *)viewSlider cellForRowAtIndex:(int)index {
    
    if (viewSlider == pvs_photoSlider) {
        //need cell for the photo slider
        NSArray* photosInTheme = [self.frc_photosInCurrentTheme fetchedObjects];
        if (index >= [photosInTheme count]) {
            NSString* message = @"dicks";
        }
        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        return [self configureViewFor:photo atIndex:index];
    }
    else {
        //need cell for the theme slider
        Theme* theme = [[self.frc_themes fetchedObjects] objectAtIndex:index];
        return [self configureViewForTheme:theme atIndex:index];
    }
    
}



-(void)themeSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
  
    if (numberOfCellsToEnd < threshold_LOADMORETHEMES) {
        //the current scroll position is below the threshold, thus we need to load more themes
        [self enumerateThemesFromWebService];
    }
    
    Theme* themeAtCurrentIndex = [[self.frc_themes fetchedObjects]objectAtIndex:index];
    if (![self.theme.objectid isEqualToNumber:themeAtCurrentIndex.objectid]) {
        //the theme scrolled to is not the same as the current one, time to switch themes
        [self assignTheme:themeAtCurrentIndex];
    }
    
}

-(void)photoSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    NSString* activityName = @"ThemeBrowserController.photoSliderIsAtIndex.isAtIndex:";
    if (numberOfCellsToEnd < threshold_LOADMOREPHOTOS) {
        //the current scroll position is below the threshold, thus we need to load more photos for this particular theme
        
        if (ec_activeThemePhotoContext == nil) {
            //if we have a nil contect, that means we have yet to query for the photos in this theme directly
            self.ec_activeThemePhotoContext = [EnumerationContext contextForPhotosInTheme:self.theme];
        }
        
        //execute the enumeration only if there is not already one executing and the current one is not done
        if (!m_isThereAThemePhotoEnumerationAlreadyExecuting &&
            ec_activeThemePhotoContext.isDone!=[NSNumber numberWithBool:YES]) {
            
            
            m_isThereAThemePhotoEnumerationAlreadyExecuting = YES;
            WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
            QueryOptions* queryOptions = [QueryOptions queryForPhotosInTheme];
            
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            m_outstandingPhotoEnumNotificationID = [NSString GetGUID];
            [notificationCenter addObserver:self selector:@selector(onEnumeratePhotosForThemeFinished:) name:m_outstandingPhotoEnumNotificationID object:nil];
            
            [enumerationManager enumeratePhotosInTheme:self.theme withQueryOptions:queryOptions onFinishNotify:m_outstandingPhotoEnumNotificationID useEnumerationContext:self.ec_activeThemePhotoContext shouldEnumerateSinglePage:YES];
            
            NSString* message = [NSString stringWithFormat:@"executing web service enumeration due to scroll threshold being crossed"];
            [BLLog v:activityName withMessage:message];
        }
    }

}

//we will use this method to pre-fetch additional pictures for a particular theme as a user pulls on the listÔ
- (void)viewSlider:(UIPagedViewSlider*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    
    //need to launch a new enumeration if the user gets within a certain threshold of the end scroll position
    
    if (viewSlider == pvs_photoSlider) {
        [self photoSliderIsAtIndex:index withCellsRemaining:numberOfCellsToEnd];
    }
    else {
        [self themeSliderIsAtIndex:index withCellsRemaining:numberOfCellsToEnd];
    }
}

#pragma mark - Enumeration Completion Handlers
- (void)onEnumerateThemesFinished:(NSNotification*)notification {
    NSString* activityName = @"ThemeBrowserController.onEnumerateThemesFinished:";
    NSDictionary *userInfo = [notification userInfo];
    

    
    if ([userInfo objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
        EnumerationContext* returnedContext = [userInfo objectForKey:an_ENUMERATIONCONTEXT];
        if ([returnedContext.isDone boolValue] == NO) {
            //enumeration remains open
            NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved for future use",returnedContext.isDone];
            [BLLog v:activityName withMessage:message];
           
        }
        else {
            //enumeration is complete, set the context to nil
            
            NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved value set to null",returnedContext.isDone];
            [BLLog v:activityName withMessage:message];
            
            
        }
        self.ec_activeThemeContext = returnedContext;
        
    }
    m_isThereAThemeEnumerationAlreadyExecuting = NO;
}

- (void)onEnumeratePhotosForThemeFinished:(NSNotification*)notification {
    NSString* activityName = @"ThemeBrowserController.onEnumeratePhotosForThemeFinished:";
    NSDictionary *userInfo = [notification userInfo];
    
    //we need to check to ensure that the theme for which this enumeration was launched is still the currently active theme    
    if ([notification.name isEqualToString:self.m_outstandingPhotoEnumNotificationID]) {
        if ([userInfo objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
            EnumerationContext* returnedContext = [userInfo objectForKey:an_ENUMERATIONCONTEXT];
            if ([returnedContext.isDone boolValue] == NO) {
                //enumeration remains open
                NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved for future use",returnedContext.isDone];
                [BLLog v:activityName withMessage:message];
                
            }
            else {
                //enumeration is complete, set the context to nil
                
                NSString* message = [NSString stringWithFormat:@"enumeration context isDone:%@, saved value set to null",returnedContext.isDone];
                [BLLog v:activityName withMessage:message];
              
                               
            }
            self.ec_activeThemePhotoContext = returnedContext;
        }
        
        m_isThereAThemePhotoEnumerationAlreadyExecuting = NO;
    }
    else {
        NSString* message = [NSString stringWithFormat:@"expired enumeration context returned, not persisting value"];
        [BLLog v:activityName withMessage:message];
        
    }
}

@end
