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
#import "NSFetchedResultsControllerCategory.h"
#import "CameraButtonManager.h"
#import "UIViewCategory.h"
#import "CloudEnumeratorFactory.h"
#import "UIThemePhotoCellView.h"
/*#define kPictureWidth 130
#define kPictureSpacing 0
#define kPictureHeight 120
#define kPictureWidth_landscape 130
#define kPictureHeight_landscape 120*/

#define kScale 2

#define kPictureSpacing 0
#define kPictureWidth 120
#define kPictureHeight 120
#define kPictureWidth_landscape 120
#define kPictureHeight_landscape 120

/*// Jordan's Photo sizes, need to merge with Bobby's above
#define kThumbnailPortraitWidth 150
#define kThumbnailPortraitHeight 200
#define kThumbnailLandscapeWidth 266
#define kThumbnailLandscapeHeight 200
#define kFullscreenPortraitWidth 320
#define kFullscreenPortraitHeight 480
#define kFullscreenLandscapeWidth 480
#define kFullscreenLandscapeHeight 320*/

// Jordan's Photo sizes, need to merge with Bobby's above
#define kThumbnailPortraitWidth 120
#define kThumbnailPortraitHeight 160
#define kThumbnailLandscapeWidth 160
#define kThumbnailLandscapeHeight 120
#define kFullscreenPortraitWidth 320
#define kFullscreenPortraitHeight 480
#define kFullscreenLandscapeWidth 480
#define kFullscreenLandscapeHeight 320

#define kThemePictureWidth 320
#define kThemePictureHeight 200
#define kThemePictureWidth_landscape 320
#define kThemePictureHeight_landscape 200
#define kThemePictureSpacing 0

#define kThemeTextViewWidth 320
#define kThemeTextViewHeight 40
#define kThemeTextViewWidth_landscape 320
#define kThemeTextViewHeight_landscape 40
#define kThemeTitlePadding 10

#define kTextViewDescriptionHeight 65
#define kTextViewDescriptionWidth 320
#define kTextViewDescriptionWidth_landscape 320
#define kTextViewDescriptionHeight_landscape 65

#define kCaptionTextViewHeight 10
#define kCaptionTextViewWidth 120
#define kCaptionTextViewHeight_landscape 10
#define kCaptionTextViewWidth_landscape 120

#define kCaptionHeight 40
#define kCaptionPadding 10

/*
// DELETE AFTER VERIFYING CAMERABUTTON SINGLETON COMPLETION - jordang
@interface ThemeBrowserViewController2 ()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)getMediaFromSource:(id)sender;
@end*/

@implementation ThemeBrowserViewController2

@synthesize theme;
@synthesize frc_photosInCurrentTheme    = __frc_photosInCurrentTheme;
@synthesize frc_themes                  = __frc_themes;
@synthesize lbl_theme;
@synthesize v_portrait;
@synthesize v_landscape;
@synthesize v_pvs_photoSlider2;
@synthesize h_pvs_photoSlider2;
@synthesize h_pvs_themeSlider2;
@synthesize v_pvs_themeSlider2;
@synthesize pvs_photoSlider2            =__pvs_photoSlider2;
@synthesize pvs_themeSlider2            =__pvs_themeSlider2;
@synthesize themeCloudEnumerator        =m_themeCloudEnumerator;
@synthesize photosInThemeCloudEnumerator=m_photosInThemeCloudEnumeator;

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
    //self.lbl_theme.text = [NSString stringWithFormat:@"Loaded Theme ID %@",themeObject.objectid];
    [self.lbl_theme setText:themeObject.displayname];
    
    NSString* message = [NSString stringWithFormat:@"Changing from ThemeID:%@ to ThemeID:%@",[oldThemeID stringValue],[themeObject.objectid stringValue]];
    [BLLog v:activityName withMessage:message];
    

    [self.pvs_photoSlider2 reset];
    
    self.photosInThemeCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.theme.objectid];
    //[self.pvs_photoSlider2 goTo:0];
}





#pragma mark - View lifecycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //find the index for the current theme in the frc
    int index = 0;
    if (self.theme != nil) {
        index = [self.frc_themes indexOf:self.theme];
        
        //move the scroller to that position
        [self.pvs_themeSlider2 goTo:index];
    }
    
    //reset the photo slider to position 0
    [self.pvs_photoSlider2 reset];
    [self.pvs_photoSlider2 goTo:0];
    
    
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(deviceOrientation)) {
        self.view = self.v_landscape;
        
    }
    else {
        self.view = self.v_portrait;
    }
    
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    self.shouldShowProfileBar = YES;
    [super viewDidLoad];

    NSString* activityName = @"ThemeBrowserViewController2.viewDidLoad:";   
        
    self.themeCloudEnumerator = [[CloudEnumeratorFactory getInstance] enumeratorForThemes];
   // self.themeCloudEnumerator = [CloudEnumerator enumeratorForThemes];
    self.themeCloudEnumerator.delegate = self;
    
    if (self.theme == nil) {
        NSArray* themes = self.frc_themes.fetchedObjects;
        
        if ([themes count] > 0) {
            [self assignTheme:[themes objectAtIndex:0]];
        }
        else {
            //need to issue request to get themes from web service
            NSString* message = [NSString stringWithFormat:@"No themes found in database, enumerating from the web service"];
            [BLLog v:activityName withMessage:message];
            [self.themeCloudEnumerator enumerateNextPage];
            
        }
        
    }
    
    
//    [self.h_pvs_photoSlider2 initWithWidth:kPictureWidth_landscape withHeight:kPictureHeight_landscape withSpacing:kPictureSpacing isHorizontal:NO];
    [self.v_pvs_photoSlider2 initWithWidth:kPictureWidth withHeight:kPictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"thumbnailphoto"];
    
//    [self.h_pvs_themeSlider2 initWithWidth:kThemePictureWidth_landscape withHeight:kThemePictureHeight_landscape withSpacing:kThemePictureSpacing isHorizontal:NO];
    [self.v_pvs_themeSlider2 initWithWidth:kThemePictureWidth withHeight:kThemePictureHeight withSpacing:kPictureSpacing useCellIdentifier:@"themephoto"];
    
    
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                     target:[CameraButtonManager getInstanceWithViewController:self withTheme:self.theme]
                                     action:@selector(cameraButtonPressed:)];
    
//    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]
//                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
//                                     target:self
//                                     action:@selector(test_Scroll:)];
    self.navigationItem.rightBarButtonItem = cameraButton;
    [cameraButton release];

}

- (void) test_Scroll:(id)sender {
    int lastIndex = [[self.frc_photosInCurrentTheme fetchedObjects]count];
    [self.pvs_photoSlider2 goTo:(lastIndex-1) withAnimation:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Rotation Handlers

     
-(void)didRotate:(NSNotification*)notification {
    
   /*
   // old code to handle rotation of view   
    
    //need to switch out the ladscape and portrait views
    //populate the sv_sliders as needed
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //going to potrait

        int currentPhotoScrollIndex = [self.pvs_photoSlider2 getPageIndex];
        int currentThemeScrollIndex = [self.pvs_themeSlider2 getPageIndex];
        self.view = v_portrait;
        
        [self.pvs_photoSlider2 goTo:currentPhotoScrollIndex];
        [self.pvs_themeSlider2 goTo:currentThemeScrollIndex];
      

    }
    else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        //going to landscape
        int currentPhotoScrollIndex = [self.pvs_photoSlider2 getPageIndex];
        int currentThemeScrollIndex = [self.pvs_themeSlider2 getPageIndex];
        self.view = v_landscape;

        [self.pvs_photoSlider2 goTo:currentPhotoScrollIndex];
        [self.pvs_themeSlider2 goTo:currentThemeScrollIndex];


    }
  */

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
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    NSSortDescriptor* sortDescriptor_DateCreated = [[NSSortDescriptor alloc]initWithKey:an_DATECREATED ascending:YES];
    
    NSArray* sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,sortDescriptor_DateCreated, nil];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"themeid=%@",self.theme.objectid];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
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
            [self.pvs_photoSlider2 onNewItemInsertedAt:[newIndexPath row]];
        }
    }
    else if (controller == self.frc_themes) {
        //its a new object in the theme controller
        [self.pvs_themeSlider2 onNewItemInsertedAt:[newIndexPath row]];
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



- (CGRect) getCaptionFrame : (CGRect)frame {
//    int xCoordinate = 10;
//    int yCoordinate = 0;
//    if (self.view == v_landscape) {
//        yCoordinate = kPictureHeight_landscape - kCaptionTextViewHeight;
//        return CGRectMake(xCoordinate, yCoordinate, kCaptionTextViewWidth_landscape, kCaptionTextViewHeight); 
//    }
//    else {
//        yCoordinate = kPictureHeight - kCaptionTextViewHeight_landscape;
//        return CGRectMake(xCoordinate, yCoordinate, kCaptionTextViewWidth, kCaptionTextViewHeight); 
//    }
    
    return CGRectMake(0, kPictureHeight - kCaptionHeight, frame.size.width, kCaptionHeight);
}

- (CGRect) getThemeTitleFrame {
    int xCoordinate = 0;
    int yCoordinate = 0;
    if (self.view == v_landscape) {
        yCoordinate = 0;
        return CGRectMake(xCoordinate, yCoordinate, kThemeTextViewWidth_landscape, kThemeTextViewHeight_landscape); 
    }
    else {
        yCoordinate = 0;
        return CGRectMake(xCoordinate, yCoordinate, kThemeTextViewWidth, kThemeTextViewHeight); 
    }
}

- (CGRect) getThemeDescriptionFrame {
    int xCoordinate = 0;
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


-(void)themeSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
  
    if (numberOfCellsToEnd < threshold_LOADMORETHEMES) {
        //the current scroll position is below the threshold, thus we need to load more themes
        [self.themeCloudEnumerator enumerateNextPage];
    }
    
    if (index >= 0 && numberOfCellsToEnd !=0) {
        Theme* themeAtCurrentIndex = [[self.frc_themes fetchedObjects]objectAtIndex:index];
        if (![self.theme.objectid isEqualToNumber:themeAtCurrentIndex.objectid]) {
            //the theme scrolled to is not the same as the current one, time to switch themes
            [self assignTheme:themeAtCurrentIndex];
            //reset the photo slider to position 0
            [self.pvs_photoSlider2 goTo:0];
        }
    }
    
}

- (void) onPhotoUploadStart:(Photo *)newPhoto {
    [super onPhotoUploadStart:newPhoto];
    
    //we now position our sliders to show the newly formed photo
    int index = 0;
    int count = [[self.frc_photosInCurrentTheme fetchedObjects]count];
    for (int i = 0; i < count; i++) {
        Photo* photoAtIndex = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:i];
        if (photoAtIndex.objectid == newPhoto.objectid) {
            index = i;
            break;
        }
    }
    
    //move the scroller to the appropriate position
    [self.pvs_photoSlider2 goTo:index];
}


- (void) onPhotoUploadComplete : (Photo*) newPhoto {
    [super onPhotoUploadComplete:newPhoto];
    
//    
//    //we now position our sliders to show the newly formed photo
//    int index = 0;
//    int count = [[self.frc_photosInCurrentTheme fetchedObjects]count];
//    for (int i = 0; i < count; i++) {
//        Photo* photoAtIndex = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:i];
//        if (photoAtIndex.objectid == newPhoto.objectid) {
//            index = i;
//            break;
//        }
//    }
//    
//    //move the scroller to the appropriate position
//    [self.pvs_photoSlider2 goTo:index];


    
}

-(void)photoSliderIsAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    
    if (numberOfCellsToEnd < threshold_LOADMOREPHOTOS) {
        //the current scroll position is below the threshold, thus we need to load more photos for this particular theme
//        [self enumeratePhotosForCurrentTheme];
        [self.photosInThemeCloudEnumerator enumerateNextPage];
    }

}


 

#pragma mark - UIPagedViewDelegate2 

- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index {
    
    if (viewSlider == self.pvs_photoSlider2 && index < [[self.frc_photosInCurrentTheme  fetchedObjects]count ]) {
        
        // Set up navigation bar back button
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:self.theme.displayname
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:nil
                                                                                 action:nil] autorelease];
        
        Photo* selectedPhoto = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        PhotoViewController* photoViewController = [[PhotoViewController alloc]init];
        photoViewController.currentPhoto = selectedPhoto;
        photoViewController.currentTheme = self.theme;
        photoViewController.shouldShowProfileBar = NO;
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

//        UIImageView* imageView = [[UIImageView alloc]initWithFrame:frame];
        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        Caption* caption = photo.topCaption;
        UIThemePhotoCellView *imageView = [[UIThemePhotoCellView alloc]initWithFrame:frame withPhoto:photo withCaption:caption withPadding:0];
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
             configure:          (UIView*)               v
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    
    if (viewSlider == self.pvs_photoSlider2 &&
        index < [[self.frc_photosInCurrentTheme fetchedObjects]count]) {
        
        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        Caption* caption = [photo topCaption];
        UIThemePhotoCellView* themeView = (UIThemePhotoCellView*)v;
        themeView.frame = frame;
        [themeView setPhoto:photo withCaption:caption];
        
    }
    else if (viewSlider == self.pvs_themeSlider2 &&
             index < [[self.frc_themes fetchedObjects]count]) {
        Theme* selectedTheme = [[self.frc_themes fetchedObjects]objectAtIndex:index];
        UIImageView* imageView = (UIImageView*)v;
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:imageView forKey:an_IMAGEVIEW];
        imageView.frame = frame;
        
        [userInfo setObject:selectedTheme.objectid forKey:an_OBJECTID];
        UIImage* image = [[ImageManager getInstance]downloadImage:selectedTheme.homeimageurl  withUserInfo:userInfo atCallback:self];
        imageView.image = nil;
        if (image == nil) {
            imageView.backgroundColor = [UIColor blackColor];
        }
        else {
            imageView.image = image;
        }
        
        
        // Add theme title        
        CGRect themeTitleFrame = [self getThemeTitleFrame];
        UIView* themeLabelBackground = nil;     // subview at index 0
        UILabel* themeLabel = nil;              // subview at index 1
        if ([imageView.subviews count] == 4) {
            themeLabel = [imageView.subviews objectAtIndex:1];
            themeLabel.frame = themeTitleFrame;
            [themeLabel setBounds:CGRectMake(themeTitleFrame.origin.x - kThemeTitlePadding, themeTitleFrame.origin.y, themeTitleFrame.size.width - kThemeTitlePadding, themeTitleFrame.size.height)];
            [themeLabel setText:selectedTheme.displayname];
        }
        else {
            [imageView removeAllSubviews];
            //todo: need to release all the objects
            
            // set transparent background first
            themeLabelBackground = [[UIView alloc] initWithFrame:themeTitleFrame];
            [themeLabelBackground setBackgroundColor:[UIColor blackColor]];
            [themeLabelBackground setAlpha:0.5];
            [themeLabelBackground setOpaque:YES];
            [imageView addSubview:themeLabelBackground];
            
            // now add non-transparent text
            themeLabel = [[UILabel alloc] initWithFrame:themeTitleFrame];
            [themeLabel setBounds:CGRectMake(themeTitleFrame.origin.x - kThemeTitlePadding, themeTitleFrame.origin.y, themeTitleFrame.size.width - kThemeTitlePadding, themeTitleFrame.size.height)];
            [themeLabel setFont:[UIFont fontWithName:font_THEME size:fontsize_THEME]];
            [themeLabel setBackgroundColor:[UIColor clearColor]];
            [themeLabel setAlpha:textAlpha];
            [themeLabel setTextColor:[UIColor whiteColor]];
            [themeLabel setOpaque:YES];
            [themeLabel setTextAlignment:UITextAlignmentCenter];        
            [themeLabel setText:selectedTheme.displayname];
            [imageView addSubview:themeLabel];
        }
        
        
        // Add theme description        
        CGRect themeDescriptionFrame = [self getThemeDescriptionFrame];
        UIView* themeDescBackground = nil;      // subview at index 2
        UITextView* themeDescTextView = nil;    // subview at index 3
        if ([imageView.subviews count] == 4) {
            themeDescTextView = [imageView.subviews objectAtIndex:3];
            themeDescTextView.frame = themeDescriptionFrame;
            [themeDescTextView setText:selectedTheme.descr];
        }
        else {
            
            // set transparent background first
            themeDescBackground = [[UIView alloc] initWithFrame:themeDescriptionFrame];
            [themeDescBackground setBackgroundColor:[UIColor blackColor]];
            [themeDescBackground setAlpha:0.5];
            [themeDescBackground setOpaque:YES];
            [imageView addSubview:themeDescBackground];
            
            // now add non-transparent text
            themeDescTextView = [[UITextView alloc] initWithFrame:themeDescriptionFrame];
            [themeDescTextView setFont:[UIFont fontWithName:font_DESCRIPTION size:fontsize_DESCRIPTION]];
            [themeDescTextView setBackgroundColor:[UIColor clearColor]];
            [themeDescTextView setAlpha:textAlpha];
            [themeDescTextView setTextColor:[UIColor whiteColor]];
            [themeDescTextView setOpaque:YES];
            [themeDescTextView setTextAlignment:UITextAlignmentCenter];        
            [themeDescTextView setText:selectedTheme.descr];
            [imageView addSubview:themeDescTextView];
        }
        
        // Add page indicator for themes
        UIPageControl* themePageIndicator = nil; // subview at index 4
        if ([imageView.subviews count] == 5) {
            themePageIndicator.numberOfPages = [self itemCountFor:viewSlider];
            themePageIndicator.currentPage = index;
        } else {
            themePageIndicator = [[UIPageControl alloc] init];
            themePageIndicator.center = CGPointMake(themeDescriptionFrame.size.width/2, themeDescriptionFrame.origin.y + themeDescriptionFrame.size.height - 1);
            themePageIndicator.numberOfPages = [self itemCountFor:viewSlider];
            themePageIndicator.currentPage = index;
            [imageView addSubview:themePageIndicator];
        }
    }
    
    
}
/*
- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIImageView*)          imageView
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    if (viewSlider == self.pvs_photoSlider2 &&
        index < [[self.frc_photosInCurrentTheme fetchedObjects]count]) {
       
        Photo* photo = [[self.frc_photosInCurrentTheme fetchedObjects]objectAtIndex:index];
        Caption* caption = [photo topCaption];
        
        imageView.frame = frame;
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:imageView forKey:an_IMAGEVIEW];
        [userInfo setObject:photo.objectid forKey:an_OBJECTID];
        
        
        CGRect captionFrame = [self getCaptionFrame:frame];
        UIView* captionLabelBackground = nil;   // subview at index 0
        UILabel* captionLabel = nil;            // subview at index 1
        if ([imageView.subviews count] == 2) {
            captionLabel = [imageView.subviews objectAtIndex:1];
            captionLabel.frame = captionFrame;
            [captionLabel setBounds:CGRectMake(captionFrame.origin.x - kCaptionPadding, captionFrame.origin.y, captionFrame.size.width - kCaptionPadding, captionFrame.size.height)];
        }
        else {
            // set transparent background first
            captionLabelBackground = [[UIView alloc] initWithFrame:captionFrame];
            [captionLabelBackground setBackgroundColor:[UIColor blackColor]];
            [captionLabelBackground setAlpha:0.5];
            [captionLabelBackground setOpaque:YES];
            [imageView addSubview:captionLabelBackground];
            
            // now add non-transparent text
            captionLabel = [[UILabel alloc] initWithFrame:captionFrame];
            [captionLabel setBounds:CGRectMake(captionFrame.origin.x - kCaptionPadding, captionFrame.origin.y, captionFrame.size.width - kCaptionPadding, captionFrame.size.height)];
            [captionLabel setFont:[UIFont fontWithName:font_CAPTION size:fontsize_CAPTION]];
            [captionLabel setBackgroundColor:[UIColor clearColor]];
            [captionLabel setAlpha:textAlpha];
            [captionLabel setTextColor:[UIColor whiteColor]];
            [captionLabel setOpaque:YES];
            [captionLabel setNumberOfLines:2];
            [captionLabel setTextAlignment:UITextAlignmentLeft];
            [imageView addSubview:captionLabel];
        }
        
        
        if (caption != nil) {
            captionLabel.text = caption.caption1;
            captionLabelBackground.hidden = NO;
        }
        else {
            captionLabel.text = nil;
            captionLabelBackground.hidden = YES;
        }
        
        imageView.image = nil;
        UIImage* image = [[ImageManager getInstance]downloadImage:photo.thumbnailurl withUserInfo:userInfo atCallback:self];
        
        if (image == nil) {
            imageView.backgroundColor = [UIColor whiteColor];
            
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
        imageView.image = nil;
        if (image == nil) {
            imageView.backgroundColor = [UIColor blackColor];
        }
        else {
            imageView.image = image;
        }
        
        
        // Add theme title        
        CGRect themeTitleFrame = [self getThemeTitleFrame];
        UIView* themeLabelBackground = nil;     // subview at index 0
        UILabel* themeLabel = nil;              // subview at index 1
        if ([imageView.subviews count] == 4) {
            themeLabel = [imageView.subviews objectAtIndex:1];
            themeLabel.frame = themeTitleFrame;
            [themeLabel setBounds:CGRectMake(themeTitleFrame.origin.x - kThemeTitlePadding, themeTitleFrame.origin.y, themeTitleFrame.size.width - kThemeTitlePadding, themeTitleFrame.size.height)];
            [themeLabel setText:selectedTheme.displayname];
        }
        else {
            [imageView removeAllSubviews];
            //todo: need to release all the objects
            
            // set transparent background first
            themeLabelBackground = [[UIView alloc] initWithFrame:themeTitleFrame];
            [themeLabelBackground setBackgroundColor:[UIColor blackColor]];
            [themeLabelBackground setAlpha:0.5];
            [themeLabelBackground setOpaque:YES];
            [imageView addSubview:themeLabelBackground];

            // now add non-transparent text
            themeLabel = [[UILabel alloc] initWithFrame:themeTitleFrame];
            [themeLabel setBounds:CGRectMake(themeTitleFrame.origin.x - kThemeTitlePadding, themeTitleFrame.origin.y, themeTitleFrame.size.width - kThemeTitlePadding, themeTitleFrame.size.height)];
            [themeLabel setFont:[UIFont fontWithName:font_THEME size:fontsize_THEME]];
            [themeLabel setBackgroundColor:[UIColor clearColor]];
            [themeLabel setAlpha:textAlpha];
            [themeLabel setTextColor:[UIColor whiteColor]];
            [themeLabel setOpaque:YES];
            [themeLabel setTextAlignment:UITextAlignmentCenter];        
            [themeLabel setText:selectedTheme.displayname];
            [imageView addSubview:themeLabel];
        }
        
        
        // Add theme description        
        CGRect themeDescriptionFrame = [self getThemeDescriptionFrame];
        UIView* themeDescBackground = nil;      // subview at index 2
        UITextView* themeDescTextView = nil;    // subview at index 3
        if ([imageView.subviews count] == 4) {
            themeDescTextView = [imageView.subviews objectAtIndex:3];
            themeDescTextView.frame = themeDescriptionFrame;
            [themeDescTextView setText:selectedTheme.descr];
        }
        else {
            
            // set transparent background first
            themeDescBackground = [[UIView alloc] initWithFrame:themeDescriptionFrame];
            [themeDescBackground setBackgroundColor:[UIColor blackColor]];
            [themeDescBackground setAlpha:0.5];
            [themeDescBackground setOpaque:YES];
            [imageView addSubview:themeDescBackground];
            
            // now add non-transparent text
            themeDescTextView = [[UITextView alloc] initWithFrame:themeDescriptionFrame];
            [themeDescTextView setFont:[UIFont fontWithName:font_DESCRIPTION size:fontsize_DESCRIPTION]];
            [themeDescTextView setBackgroundColor:[UIColor clearColor]];
            [themeDescTextView setAlpha:textAlpha];
            [themeDescTextView setTextColor:[UIColor whiteColor]];
            [themeDescTextView setOpaque:YES];
            [themeDescTextView setTextAlignment:UITextAlignmentCenter];        
            [themeDescTextView setText:selectedTheme.descr];
            [imageView addSubview:themeDescTextView];
        }
        
        // Add page indicator for themes
        UIPageControl* themePageIndicator = nil; // subview at index 4
        if ([imageView.subviews count] == 5) {
            themePageIndicator.numberOfPages = [self itemCountFor:viewSlider];
            themePageIndicator.currentPage = index;
        } else {
            themePageIndicator = [[UIPageControl alloc] init];
            themePageIndicator.center = CGPointMake(themeDescriptionFrame.size.width/2, themeDescriptionFrame.origin.y + themeDescriptionFrame.size.height - 1);
            themePageIndicator.numberOfPages = [self itemCountFor:viewSlider];
            themePageIndicator.currentPage = index;
            [imageView addSubview:themePageIndicator];
        }
    }
}
*/


- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider {
    if (viewSlider == self.pvs_photoSlider2) {
        return [[self.frc_photosInCurrentTheme fetchedObjects]count];
    }
    else if (viewSlider == self.pvs_themeSlider2) {
        return [[self.frc_themes fetchedObjects]count];
    }
    return 0;
}

#pragma mark - Cloud Enumerator delegate
- (void) onEnumerateComplete {
    
}
@end
