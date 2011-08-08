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
#import <MobileCoreServices/UTCoreTypes.h>
#import "FullScreenPhotoController.h"
#import "PhotoViewController.h"
#import "MWPhotoBrowser.h"

#define kPictureWidth 130
#define kPictureSpacing 5
#define kPictureHeight 120
#define kPictureWidth_landscape 130
#define kPictureHeight_landscape 120

// Jordan's Photo sizes, need to merge with Bobby's above
#define kThumbnailPortraitWidth 150
#define kThumbnailPortraitHeight 200
#define kThumbnailLandscapeWidth 266
#define kThumbnailLandscapeHeight 200
#define kFullscreenPortraitWidth 320
#define kFullscreenPortraitHeight 480
#define kFullscreenLandscapeWidth 480
#define kFullscreenLandscapeHeight 320

#define kThemePictureWidth 320
#define kThemePictureHeight 200
#define kThemePictureWidth_landscape 320
#define kThemePictureHeight_landscape 200
#define kThemePictureSpacing 0

#define kTextViewWidth 300
#define kTextViewHeight 30
#define kTextViewWidth_landscape 300
#define kTextViewHeight_landscape 30

#define kTextViewDescriptionHeight 30
#define kTextViewDescriptionWidth 300
#define kTextViewDescriptionWidth_landscape 300
#define kTextViewDescriptionHeight_landscape 30

#define kCaptionTextViewHeight 10
#define kCaptionTextViewWidth 120
#define kCaptionTextViewHeight_landscape 10
#define kCaptionTextViewWidth_landscape 120

@interface ThemeBrowserViewController2 ()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)getMediaFromSource:(id)sender;
@end

@implementation ThemeBrowserViewController2

@synthesize theme;
@synthesize managedObjectContext;
@synthesize frc_photosInCurrentTheme    = __frc_photosInCurrentTheme;
@synthesize frc_themes                  = __frc_themes;
@synthesize lbl_theme;
@synthesize ec_activeThemePhotoContext;
@synthesize m_isThereAThemePhotoEnumerationAlreadyExecuting;
@synthesize ec_activeThemeContext;
@synthesize m_isThereAThemeEnumerationAlreadyExecuting;
@synthesize m_outstandingPhotoEnumNotificationID;
@synthesize v_portrait;
@synthesize v_landscape;
@synthesize v_pvs_photoSlider2;
@synthesize h_pvs_photoSlider2;
@synthesize h_pvs_themeSlider2;
@synthesize v_pvs_themeSlider2;
@synthesize pvs_photoSlider2            =__pvs_photoSlider2;
@synthesize pvs_themeSlider2            =__pvs_themeSlider2;

#pragma mark - Properties
- (UIPagedViewSlider2*) pvs_photoSlider2 {
    if (self.view == self.v_portrait) {
        return self.v_pvs_photoSlider2;
    }
    else {
        return self.h_pvs_photoSlider2;
    }
}

- (UIPagedViewSlider2*) pvs_themeSlider2 {
    if (self.view == self.v_portrait) {
        return self.v_pvs_themeSlider2;
    }
    else {
        return self.h_pvs_themeSlider2;
    }
}

- (void) registerNotification:(NSString*) notificationID  targetSelector:(SEL)targetSelector targetObject:(id) targetObject {
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:targetObject selector:targetSelector name:notificationID object:nil];
    
}


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
    [self.h_pvs_themeSlider2 release];
    [self.v_pvs_themeSlider2 release];
    [self.h_pvs_photoSlider2 release];
    [self.v_pvs_photoSlider2 release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

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
    

    [self.pvs_photoSlider2 reset];
    self.ec_activeThemePhotoContext = [EnumerationContext contextForPhotosInTheme:self.theme.objectid];
    self.m_outstandingPhotoEnumNotificationID = nil;
    self.m_isThereAThemePhotoEnumerationAlreadyExecuting = NO;
}

#pragma mark - Enumeration Handlers

-(void)enumeratePhotosForCurrentTheme {
    NSString* activityName = @"ThemeBrowserController.enumeratePhotosForCurrentTheme:";
    if (ec_activeThemePhotoContext == nil) {
        //if we have a nil contect, that means we have yet to query for the photos in this theme directly
        self.ec_activeThemePhotoContext = [EnumerationContext contextForPhotosInTheme:self.theme.objectid];
    }
    
    //execute the enumeration only if there is not already one executing and the current one is not done
    if (!m_isThereAThemePhotoEnumerationAlreadyExecuting &&
        ec_activeThemePhotoContext.isDone!=[NSNumber numberWithBool:YES]) {
        
        
        m_isThereAThemePhotoEnumerationAlreadyExecuting = YES;
        WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
        QueryOptions* queryOptions = [QueryOptions queryForPhotosInTheme];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        self.m_outstandingPhotoEnumNotificationID = [NSString GetGUID];
        [notificationCenter addObserver:self selector:@selector(onEnumeratePhotosForThemeFinished:) name:m_outstandingPhotoEnumNotificationID object:nil];
        
        [enumerationManager enumeratePhotosInTheme:self.theme withQueryOptions:queryOptions onFinishNotify:m_outstandingPhotoEnumNotificationID useEnumerationContext:self.ec_activeThemePhotoContext shouldEnumerateSinglePage:YES];
        
        NSString* message = [NSString stringWithFormat:@"executing web service enumeration due to scroll threshold being crossed"];
        [BLLog v:activityName withMessage:message];
    }
    
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

-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
  
    [super viewDidLoad];
    
 
     
     
    NSString* activityName = @"ThemeBrowserViewController2.viewDidLoad:";   
        
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                     target:self
                                     action:@selector(getMediaFromSource:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    [cameraButton release];
    
    
    if (self.theme == nil) {
        NSArray* themes = self.frc_themes.fetchedObjects;
    
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
    
    self.pvs_photoSlider2.layer.borderWidth = 1.0f;
    self.pvs_photoSlider2.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pvs_themeSlider2.layer.borderWidth = 1.0f;
    self.pvs_themeSlider2.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    [self.h_pvs_photoSlider2 initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];
    [self.v_pvs_photoSlider2 initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];
    
    [self.h_pvs_themeSlider2 initWithWidth:kThemePictureWidth withHeight:kThemePictureHeight withWidthLandscape:kThemePictureHeight_landscape withHeightLandscape:kThemePictureHeight withSpacing:kThemePictureSpacing];
    [self.v_pvs_themeSlider2 initWithWidth:kThemePictureWidth withHeight:kThemePictureHeight withWidthLandscape:kThemePictureWidth_landscape withHeightLandscape:kThemePictureHeight_landscape withSpacing:kThemePictureSpacing];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Rotation Handlers

     
-(void)didRotate:(NSNotification*)notification {
    //need to switch out the ladscape and portrait views
    //populate the sv_sliders as needed
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //going to potrait

        int currentPhotoScrollIndex = self.pvs_photoSlider2.currentPageIndex;
        int currentThemeScrollIndex = self.pvs_themeSlider2.currentPageIndex;
        self.view = v_portrait;
        self.pvs_photoSlider2.currentPageIndex = currentPhotoScrollIndex;
        self.pvs_themeSlider2.currentPageIndex = currentThemeScrollIndex;

    }
    else {
        //going to landscape
        int currentPhotoScrollIndex = self.pvs_photoSlider2.currentPageIndex;
        int currentThemeScrollIndex = self.pvs_themeSlider2.currentPageIndex;
        self.view = v_landscape;
        self.pvs_photoSlider2.currentPageIndex = currentPhotoScrollIndex;
        self.pvs_themeSlider2.currentPageIndex = currentThemeScrollIndex;       


    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
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
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    
    
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

        if (self.theme == nil) {
  
            [self assignTheme:anObject];
        }
    }
    else if (type == NSFetchedResultsChangeMove) {

    }
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (controller == self.frc_photosInCurrentTheme) {
        
        if (type == NSFetchedResultsChangeInsert) {

          
            
        }
        else if (type == NSFetchedResultsChangeMove) {

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
        [self.pvs_photoSlider2 setNeedsDisplay];

    }
    
}

#pragma mark - UIViewSliderDelegate 
- (CGRect) getPhotoFrame:(int)index isOrientationHorizontal:(BOOL)isSliderOrientationHorizontal{
    int xCoordinate = 0;
    int yCoordinate = 0;
    
    if (isSliderOrientationHorizontal) {
        //portrait
        xCoordinate = index * (kPictureWidth + kPictureSpacing);
        return CGRectMake(xCoordinate, 0, kPictureWidth, kPictureHeight_landscape);
    }
    else {
        //landscape
        yCoordinate = index * (kPictureHeight_landscape + kPictureSpacing);
        return CGRectMake(0,yCoordinate,kPictureWidth_landscape,kPictureHeight_landscape);

    }
}

- (CGRect) getThemePhotoFrame:(int)index isOrientationHorizontal:(BOOL)isSliderOrientationHorizontal{
    int xCoordinate = 0;
    int yCoordinate = 0;
    
    if (isSliderOrientationHorizontal) {
        //portrait
        xCoordinate = index * (kThemePictureWidth + kThemePictureSpacing);
        return CGRectMake(xCoordinate, 0, kThemePictureWidth, kThemePictureHeight);
        
    }
    else {
        //landscape
        yCoordinate = index * (kThemePictureHeight_landscape + kThemePictureSpacing);
        return CGRectMake(0,yCoordinate,kThemePictureWidth_landscape,kThemePictureHeight_landscape);
    }
}

- (CGRect) getCaptionFrame {
    int xCoordinate = 10;
    int yCoordinate = 0;
    if (self.view == v_landscape) {
        yCoordinate = kPictureHeight_landscape - kCaptionTextViewHeight;
        return CGRectMake(xCoordinate, yCoordinate, kCaptionTextViewWidth_landscape, kCaptionTextViewHeight); 
    }
    else {
        yCoordinate = kPictureHeight - kCaptionTextViewHeight_landscape;
        return CGRectMake(xCoordinate, yCoordinate, kCaptionTextViewWidth, kCaptionTextViewHeight); 
    }
}

- (CGRect) getThemeTitleFrame {
    int xCoordinate = 10;
    int yCoordinate = 0;
    if (self.view == v_landscape) {
        yCoordinate = 10;
        return CGRectMake(xCoordinate, yCoordinate, kTextViewWidth_landscape, kTextViewHeight_landscape); 
    }
    else {
        yCoordinate = 10;
        return CGRectMake(xCoordinate, yCoordinate, kTextViewWidth, kTextViewHeight); 
    }
}

- (CGRect) getThemeDescriptionFrame {
    int xCoordinate = 10;
    int yCoordinate = 0;
    if (self.view == v_landscape) {
        yCoordinate = kThemePictureHeight_landscape - kTextViewDescriptionHeight_landscape;
        return CGRectMake(xCoordinate, yCoordinate, kTextViewDescriptionWidth_landscape, kTextViewDescriptionHeight_landscape); 
    }
    else {
        yCoordinate = kThemePictureHeight - kTextViewDescriptionHeight;
        return CGRectMake(xCoordinate, yCoordinate, kTextViewDescriptionWidth, kTextViewDescriptionHeight); 
    }
}

//- (id) configureViewFor:(Photo*)photo atIndex:(int)index isOrientationHorizontal:(BOOL)isSliderOrientationHorizontal{
//    ImageManager *imageManager = [ImageManager getInstance];
//    
//  
//    
//    CGRect photoImageViewFrame = [self getPhotoFrame:index isOrientationHorizontal:isSliderOrientationHorizontal];
//    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:photoImageViewFrame]autorelease];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
//    
//    //Create the caption label for the current photo
//    Caption* topCaption = photo.topCaption;
//    
//    if (topCaption != nil) {
//        CGRect captionFrame = [self getCaptionFrame];
//        UILabel* captionLabel = [[[UILabel alloc]initWithFrame:captionFrame]autorelease];
//        captionLabel.text = topCaption.caption1;
//        captionLabel.textColor = [UIColor whiteColor];
//        captionLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
//        captionLabel.numberOfLines = 0;
//        captionLabel.lineBreakMode = UILineBreakModeWordWrap;
//        captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [imageView addSubview:captionLabel];
//        
//    }
//    
//    [userInfo setObject:imageView forKey:an_IMAGEVIEW];        
//    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];  
//    if (image != nil) {
//        
//        imageView.image = image;
//     
//    }
//    else {
//        imageView.backgroundColor = [UIColor blackColor];
//    }
//    
//    return imageView;
//}

//- (id) configureViewForTheme:(Theme*)theme atIndex:(int)index isOrientationHorizontal:(BOOL)isSliderOrientationHorizontal {
//    ImageManager *imageManager = [ImageManager getInstance];
//    
//    CGRect imageFrame = [self getThemePhotoFrame:index isOrientationHorizontal:isSliderOrientationHorizontal];
//    UIImageView* imageView = [[[UIImageView alloc]initWithFrame:imageFrame]autorelease];
//
//    
//    //The following adds the text label for the theme display name
//    CGRect textViewFrame = [self getThemeTitleFrame];
//    UILabel* textView = [[[UILabel alloc]initWithFrame:textViewFrame]autorelease];
//    textView.textColor = [UIColor whiteColor];
//    textView.numberOfLines = 0;
//    textView.lineBreakMode = UILineBreakModeWordWrap;
//    textView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
//    textView.text = theme.displayname;
//    [imageView addSubview:textView];
//    
//    
//    //The following adds the text label for the theme description
//    CGRect textViewDescriptionFrame = [self getThemeDescriptionFrame];
//    UILabel* textViewDescription = [[[UILabel alloc]initWithFrame:textViewDescriptionFrame]autorelease];
//    textViewDescription.textColor = [UIColor whiteColor];
//    textViewDescription.numberOfLines = 0;
//    textViewDescription.lineBreakMode = UILineBreakModeWordWrap;
//    textViewDescription.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
//    textViewDescription.text = theme.descr;
//    textViewDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [imageView addSubview:textViewDescription];
//    
//    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:an_INDEXPATH];
//
//    [userInfo setObject:imageView forKey:an_IMAGEVIEW];        
//    
//    UIImage* image = [imageManager downloadImage:theme.homeimageurl withUserInfo:userInfo atCallback:self];   
//    
//    if (image != nil) {
//        imageView.image = image;
//    }
//    else {
//        imageView.backgroundColor =[UIColor blackColor];
//    }
//    return imageView;
//    
//}

//- (UIView*)viewSlider:(UIPagedViewSlider *)viewSlider cellForRowAtIndex:(int)index sliderIsHorizontal:(BOOL)isSliderOrientationHorizontal  {
//    UIPagedViewSlider* currentPhotoSlider = self.pvs_photoSlider;
//    if (viewSlider == currentPhotoSlider) {
//        //need cell for the photo slider
//        NSArray* photosInTheme = [self.frc_photosInCurrentTheme fetchedObjects];
//        if (index >= [photosInTheme count]) {
//            NSString* message = @"dicks";
//        }
//        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
//        return [self configureViewFor:photo atIndex:index isOrientationHorizontal:isSliderOrientationHorizontal];
//    }
//    else {
//        //need cell for the theme slider
//        Theme* theme = [[self.frc_themes fetchedObjects] objectAtIndex:index];
//        return [self configureViewForTheme:theme atIndex:index isOrientationHorizontal:isSliderOrientationHorizontal];
//    }
//    
//}



//-(void)themeSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
//  
//    if (numberOfCellsToEnd < threshold_LOADMORETHEMES) {
//        //the current scroll position is below the threshold, thus we need to load more themes
//        [self enumerateThemesFromWebService];
//    }
//    
//    Theme* themeAtCurrentIndex = [[self.frc_themes fetchedObjects]objectAtIndex:index];
//    if (![self.theme.objectid isEqualToNumber:themeAtCurrentIndex.objectid]) {
//        //the theme scrolled to is not the same as the current one, time to switch themes
//        [self assignTheme:themeAtCurrentIndex];
//    }
//    
//}


//-(void)photoSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
//    
//    if (numberOfCellsToEnd < threshold_LOADMOREPHOTOS) {
//        //the current scroll position is below the threshold, thus we need to load more photos for this particular theme
//        [self enumeratePhotosForCurrentTheme];
//    }
//
//}

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
    
    if (numberOfCellsToEnd < threshold_LOADMOREPHOTOS) {
        //the current scroll position is below the threshold, thus we need to load more photos for this particular theme
        [self enumeratePhotosForCurrentTheme];
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




//- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
- (void)getMediaFromSource:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentModalViewController:picker animated:YES];
        [picker release];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error accessing media" 
                              message:@"Device doesn't support that media source." 
                              delegate:nil 
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


#pragma mark -
#pragma mark UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Begin creation of the thumbnail and fullscreen photos
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGSize chosenImageSize = chosenImage.size;
    CGSize newThumbnailSize;
    CGSize newFullscreenSize;
    CGRect thumbnailCropRect;
    
    thumbnailCropRect = CGRectMake((newThumbnailSize.width - (kThumbnailPortraitWidth))/2, (newThumbnailSize.height - (kThumbnailPortraitHeight))/2, kPictureWidth, kPictureHeight);
    
    if (chosenImageSize.height > chosenImageSize.width) {
       
        newThumbnailSize = CGSizeMake(kThumbnailPortraitWidth, ((chosenImageSize.height*kThumbnailPortraitWidth)/chosenImageSize.width));

        newFullscreenSize = CGSizeMake(kFullscreenPortraitWidth, ((chosenImageSize.height*kFullscreenPortraitWidth)/chosenImageSize.width));
    }
    else if (chosenImageSize.height < chosenImageSize.width) {
        // Create UIImage frame for image in landscape - fill height
               newThumbnailSize = CGSizeMake(((chosenImageSize.width*kThumbnailLandscapeHeight)/chosenImageSize.height), kThumbnailLandscapeHeight);
        
        newFullscreenSize = CGSizeMake(((chosenImageSize.width*kFullscreenLandscapeHeight)/chosenImageSize.height), kFullscreenLandscapeHeight);
    }
    else {
        // Create UIImage frame for image in portrait but maximize image scaling to fill height for thumbnail and width for fullscreen
            newThumbnailSize = CGSizeMake(kThumbnailPortraitHeight, kThumbnailPortraitHeight);
       
        newFullscreenSize = CGSizeMake(kFullscreenPortraitWidth, kFullscreenPortraitWidth);
    }
    
    // Make thumbnail image
    UIImage *thumbnailImage = shrinkImage(chosenImage, newThumbnailSize);
    // Crop the new shrunken thumbnail image to the fit the target frame size
    CGImageRef croppedThumbnailImage = CGImageCreateWithImageInRect([thumbnailImage CGImage], thumbnailCropRect);
    thumbnailImage = [UIImage imageWithCGImage:croppedThumbnailImage];
    
    // Make fullscreen image
    UIImage *fullscreenImage = shrinkImage(chosenImage, newFullscreenSize);
    
    
    // Initialize the new Photo object
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSString* thumbnailPath = nil;
    NSString* fullscreenPath = nil;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:appContext];
    Photo *newPhoto = [[Photo alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:appContext];
    [newPhoto init];
    newPhoto.themeid = theme.objectid;
    newPhoto.descr = @"sample text";
    newPhoto.creatorid = [[AuthenticationManager getInstance]getLoggedInUserID];
    
    ImageManager* imageManager = [ImageManager getInstance];
    
    // Save thumbnail image
    NSString* thumbnailFileName = [newPhoto.objectid stringValue];
    thumbnailPath = [imageManager saveImage:thumbnailImage withFileName:thumbnailFileName];
    
    // Save fullscreen image
    NSString* fullscreenFileName = [newPhoto.objectid stringValue];
    fullscreenPath = [imageManager saveImage:fullscreenImage withFileName:fullscreenFileName];
    
    
    newPhoto.thumbnailurl = thumbnailPath;
    newPhoto.imageurl = fullscreenPath;   
    
    [newPhoto commitChangesToDatabase:NO withPendingFlag:YES];
    //now we need to upload this to the cloud. as they say in Redmond. to the cloud...
    UIProgressView* progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    self.navigationController.navigationItem.titleView = progressView;
    
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    Attachment* thumbnailAttachment = [Attachment attachmentWith:newPhoto.objectid objectType:PHOTO forAttribute:an_THUMBNAILURL atFileLocation:newPhoto.thumbnailurl];
    Attachment* fullscreenAttachment = [Attachment attachmentWith:newPhoto.objectid objectType:PHOTO forAttribute:an_IMAGEURL atFileLocation:newPhoto.imageurl];
    NSArray* attachments = [NSArray arrayWithObjects:thumbnailAttachment,fullscreenAttachment, nil];
    
    //We register a notification receiver to listen in for the completion of the uploads
    NSString* notificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onPhotoWithAttachmentsUploadFinished:) name:notificationID object:nil];
                                    
    [transferManager createObjectsInCloud:[NSArray arrayWithObject:newPhoto.objectid] withObjectTypes:[NSArray arrayWithObject:PHOTO] withAttachments:attachments onFinishNotify:notificationID];
    
    
    
    CGImageRelease(croppedThumbnailImage);
    
    [picker dismissModalViewControllerAnimated:YES];
}


//This method will be called each time an object finished upload, as well as each time an attachment was uploaded
//Hence this is called on each successful upload, and is not batched or atomic across all uploaded objects
- (void) onPhotoWithAttachmentsUploadFinished:(NSNotification*)notification {
    NSString* activityName = @"ThemeBrowserViewController2.onPhotoWithAttachmentsUploadFinished:";
    
    NSDictionary* userInfo = [[notification userInfo]retain];
    
    if ([userInfo objectForKey:an_OBJECTTYPE]!= [NSNull null]) {
        NSString* objectType = [userInfo objectForKey:an_OBJECTTYPE];
        NSNumber* objectID = [userInfo objectForKey:an_OBJECTID];
        
        NSString* message = [NSString stringWithFormat:@"Object Type: %@ with Object ID: %@ completed upload",objectType,objectID];
        [BLLog v:activityName withMessage:message];
        
        //we need to mark the object as not being Pending if it is a Photo
        if ([objectType isEqualToString:PHOTO]) {
            Photo* photo = [DataLayer getObjectByType:PHOTO withId:objectID];
            photo.isPending = [NSNumber numberWithBool:NO];
            
            //we mark the object as being no longer pending.
            [photo commitChangesToDatabase:NO withPendingFlag:NO];
        }
    }
    
        
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}



static inline double radians (double degrees) {
    return degrees * M_PI/180;
}


static UIImage *shrinkImage(UIImage *original, CGSize size) {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat targetWidth = size.width * scale;
    CGFloat targetHeight = size.height * scale;
    CGImageRef imageRef = [original CGImage];
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef context;
    
    // For the thumbnail images, in the right or left cases, we need to switch targetWidth and targetHeight when building the CG context
    //if ((targetWidth / scale) == kFullscreenPortraitWidth || (targetHeight / scale) == kFullscreenPortraitHeight) {
    //    context = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    //} else {
        if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationDown) {
            context = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        } else {
            context = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        }
    //}
    
    // For the fullscreen photos we need to rotate the CG context before drawing the image.
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
	// and also the origin point
    //if ((targetWidth / scale) == kFullscreenPortraitWidth || (targetHeight / scale) == kFullscreenPortraitHeight) {
        if (original.imageOrientation == UIImageOrientationLeft) {
            //CGContextRotateCTM (context, radians(90));
            //CGContextTranslateCTM (context, 0, -targetWidth);
        } else if (original.imageOrientation == UIImageOrientationRight) {
            //CGContextRotateCTM (context, radians(-90));
            //CGContextTranslateCTM (context, -targetHeight, 0);
        } else if (original.imageOrientation == UIImageOrientationUp) {
            // NOTHING
        } else if (original.imageOrientation == UIImageOrientationDown) {
            //CGContextTranslateCTM (context, targetWidth, targetHeight);
            //CGContextRotateCTM (context, radians(180));
        }
    //}
    
    if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationDown) {
        CGContextDrawImage(context, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);

    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, targetHeight, targetWidth), imageRef);
    }
    
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    
    UIImage *shrunkenImage = [UIImage imageWithCGImage:shrunken scale:original.scale orientation:original.imageOrientation];
    //UIImage* shrunkenImage = [UIImage imageWithCGImage:shrunken];
    
    //CGSize shrunkenImageSize = shrunkenImage.size;
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return shrunkenImage;
}

#pragma mark - UIPagedViewDelegate2 

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index {
    
    if (viewSlider == self.pvs_photoSlider2 && 
        index < [[self.frc_photosInCurrentTheme  fetchedObjects]count ]) {
        
        Photo* selectedPhoto = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        PhotoViewController* photoViewController = [[PhotoViewController alloc]init];
        photoViewController.currentPhoto = selectedPhoto;
        photoViewController.currentTheme = self.theme;
        [self.navigationController pushViewController:photoViewController animated:YES];
        [photoViewController release];
        
    }
    else if (viewSlider == self.pvs_themeSlider2 &&
             index < [[self.frc_themes fetchedObjects]count]) {
        Theme* selectedTheme = [[self.frc_themes fetchedObjects]objectAtIndex:index];
        [self assignTheme:selectedTheme];
        
    }
    
    
}

- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:  (int)                   index 
             withFrame:          (CGRect)                frame {
    
    if (viewSlider == self.pvs_photoSlider2 &&
        index < [[self.frc_photosInCurrentTheme fetchedObjects]count]) {

        UIImageView* imageView = [[UIImageView alloc]initWithFrame:frame];
        [self viewSlider:self.pvs_photoSlider2 configure:imageView forRowAtIndex:index withFrame:frame];
        return imageView;
    }
    else if (viewSlider == self.pvs_themeSlider2 &&
             index < [[self.frc_themes fetchedObjects]count] ){

        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:frame];
        [self viewSlider:self.pvs_themeSlider2 configure:imageView forRowAtIndex:index withFrame:frame];
        
        return imageView;
    }
    return nil;
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining: (int)                   numberOfCellsToEnd {
    
        if (viewSlider == self.pvs_photoSlider2) {
            [self photoSliderIsAtIndex:index withCellsRemaining:numberOfCellsToEnd];
        }
        else {
            [self themeSliderIsAtIndex:index withCellsRemaining:numberOfCellsToEnd];
        }
    
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIImageView*)               imageView
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    if (viewSlider == self.pvs_photoSlider2 &&
        index < [[self.frc_photosInCurrentTheme fetchedObjects]count]) {
       
        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        imageView.frame = frame;
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:imageView forKey:an_IMAGEVIEW];
        [userInfo setObject:photo.objectid forKey:an_OBJECTID];
        
        UIImage* image = [[ImageManager getInstance]downloadImage:photo.thumbnailurl withUserInfo:userInfo atCallback:self];
        
        if (image == nil) {
            imageView.backgroundColor = [UIColor blackColor];
            imageView.image = nil;
        }
        else {
            imageView.image = image;
        }
   
    }
        
    else if (viewSlider == self.pvs_themeSlider2 &&
             index < [[self.frc_themes fetchedObjects]count]) {
        Theme* selectedTheme = [[self.frc_themes fetchedObjects]objectAtIndex:index];
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:imageView forKey:an_IMAGEVIEW];
        imageView.frame = frame;
        
        [userInfo setObject:selectedTheme.objectid forKey:an_OBJECTID];
        UIImage* image = [[ImageManager getInstance]downloadImage:selectedTheme.homeimageurl  withUserInfo:userInfo atCallback:self];
        
        if (image == nil) {
            imageView.backgroundColor = [UIColor blackColor];
        }
        else {
            imageView.image = image;
        }
      

    }
}



- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider {
    if (viewSlider == self.pvs_photoSlider2) {
        return [[self.frc_photosInCurrentTheme fetchedObjects]count];
    }
    else if (viewSlider == self.pvs_themeSlider2) {
        return [[self.frc_themes fetchedObjects]count];
    }
    return 0;
}
@end
