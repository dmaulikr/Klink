//
//  PhotoViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 8/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PhotoViewController.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "ImageManager.h"
#import "UIPhotoCaptionScrollView.h"
#import "NSStringGUIDCategory.h"
#import "IDGenerator.h"

#define kPictureWidth_landscape     480
#define kPictureWidth               320
#define kPictureHeight              370
#define kPictureHeight_landscape    245
#define kPictureSpacing             0



#define kCaptionTextFieldWidth 320
#define kCaptionTextFieldHeight 100
#define kCaptionTextFieldWidth_landscape 480
#define kCaptionTextFieldHeight_landscape 100


@implementation PhotoViewController
@synthesize captionTextField        =__captionTextField;
@synthesize currentPhoto            = m_currentPhoto;
@synthesize currentTheme            = m_currentTheme;
@synthesize frc_photos              = __frc_photos;
@synthesize frc_captions            = __frc_captions;
@synthesize managedObjectContext    = __managedObjectContext;
@synthesize previousButton          = m_previousButton;
@synthesize nextButton              = m_nextButton;
@synthesize controlVisibilityTimer  = m_controlVisibilityTimer;
@synthesize pagedViewSlider         = __pagedViewSlider;
@synthesize v_pagedViewSlider;
@synthesize h_pagedViewSlider;
@synthesize photoCloudEnumerator    =m_photoCloudEnumerator;
@synthesize captionButton           =m_captionButton;
@synthesize submitButton            =m_submitButton;
@synthesize tv_captionBox           =__tv_captionBox;
@synthesize v_tv_captionBox;
@synthesize h_tv_captionBox;
@synthesize state = m_state;
@synthesize sv_view = __sv_view;
@synthesize v_sv_view;
@synthesize h_sv_view;
@synthesize cancelCaptionButton     =m_cancelCaptionButton;

#pragma mark - Property Definitions

- (UIScrollView*) sv_view {
    if (self.view == self.v_portrait) {
        return self.v_sv_view;
        
    }
    else {
        return self.h_sv_view;
    }
}
- (UICaptionTextView*) tv_captionBox {
    if (self.view == self.v_portrait) {
        return self.v_tv_captionBox;
    }
    else {
        return self.h_tv_captionBox;
    }
}

-(UIPagedViewSlider2*)pagedViewSlider {

    if (self.view == self.v_portrait) {
        
        return self.v_pagedViewSlider;
    }
    else {
        return self.h_pagedViewSlider;
    }
}


- (NSManagedObjectContext*)managedObjectContext {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (UITextField*)captionTextField {
    if (__captionTextField != nil) {
        return __captionTextField;
    }
    
    CGRect frame = [self frameForCaptionTextField];
    UITextField* textField = [[UITextField alloc]initWithFrame:frame];
    
    return textField;
}
- (NSFetchedResultsController*) frc_photos {
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    if (self.currentTheme == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_NUMBEROFVOTES ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"themeid=%@",self.currentTheme.objectid];
    
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


- (void) assignPhoto: (Photo*)photo {
    NSString* activityName = @"PhotoViewController.assignPhoto:";
    NSNumber* currentPhotoID = self.currentPhoto.objectid;
   
    __frc_captions = nil;
    
    self.currentPhoto = photo;
    NSString* message = [NSString stringWithFormat:@"Changed active Photo from %@ to %@",currentPhotoID,photo.objectid];
    [BLLog v:activityName withMessage:message];        
}


- (void) addCaptionButtonToNavigationItem {
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    if (authenticationContext != nil) {
        self.navigationItem.rightBarButtonItem = self.captionButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - initializers

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

#pragma mark Memory

- (void)didReceiveMemoryWarning {
	
	NSLog(@"didReceiveMemoryWarning");
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}
#pragma mark - Navigation Bar Handlers
- (void) onCaptionButtonPressed:(id)sender {
    [self onEnterEditMode];
    
    
}

- (void) onSubmitButtonPressed:(id)sender {
    NSString* activityName = @"PhotoViewController.onSubmitButtonPressed:";
    
    
    NSString* captionText = [self.tv_captionBox getText];
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:self.pagedViewSlider.currentPageIndex];
    Caption* caption = [Caption captionForPhoto:photo.objectid withText:captionText];
    
    NSManagedObjectContext *appContext = self.managedObjectContext;
    [appContext insertObject:caption];
    
    NSError* error = nil;
    [appContext save:&error];
    
    if (error != nil) {
        NSString* message = [NSString stringWithFormat:@"Could not save caption to database due to %@",[error description]];
        [BLLog e:activityName withMessage:message];
    }
    
    [self onExitEditMode];
    
    //object is created now we need to upload it to the cloud
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    NSString* notificationID = [NSString GetGUID];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onCreateCaptionInCloudComplete:) name:notificationID object:nil];
    [transferManager createObjectInCloud:caption.objectid withObjectType:CAPTION onFinishNotify:notificationID];
    
    //now we need to scroll to the caption and display it for the user
    NSArray* currentlyDisplayedViews = [self.pagedViewSlider getVisibleViews];
    
    for (int i = 0; i < [currentlyDisplayedViews count];i++) {
        UIPhotoCaptionScrollView* photoCaptionView = [currentlyDisplayedViews objectAtIndex:i];
        if ([photoCaptionView.photo.objectid isEqualToNumber:photo.objectid]) {
            [photoCaptionView setVisibleCaption:caption.objectid];
        }
    }
    
    
}

- (void) onCancelButtonPressed:(id)sender {
    [self.tv_captionBox cancel];
    [self onExitEditMode];
}

#pragma mark - Cloud response handlers
- (void) onCreateCaptionInCloudComplete:(NSNotification*)notification {
    NSString* activityName = @"PhotoViewController.onCreateCaptionInCloudComplete:";
    [BLLog v:activityName withMessage:@"Caption uploaded to the cloud successfully"];
}

#pragma mark - View lifecycle

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 60;
        rect.size.height += 60;;
        self.state = kZoomedIn;
                
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += 60;
        rect.size.height -= 60;
        self.state = kNormal;
        
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    m_isInEditMode = NO;
   
    self.tv_captionBox.hidden = YES;
    
    self.captionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCaptionButtonPressed:)];
    self.submitButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSubmitButtonPressed:)];
    self.cancelCaptionButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButtonPressed:)];
    
   
    [self.h_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];
    [self.v_pagedViewSlider initWithWidth:kPictureWidth withHeight:kPictureHeight withWidthLandscape:kPictureWidth_landscape withHeightLandscape:kPictureHeight_landscape withSpacing:kPictureSpacing];

    self.photoCloudEnumerator = [CloudEnumerator enumeratorForPhotos:self.currentTheme.objectid];
    self.photoCloudEnumerator.delegate = self;
    if ([[self.frc_photos fetchedObjects]count]<threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
    }
    
    m_wantsFullScreenLayout = YES;
    m_hidesBottomBarWhenPushed = YES;
    
      
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    


}


- (void) viewWillAppear:(BOOL)animated {
    // Super
	[super viewWillAppear:animated];
	
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 
    [notificationCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:self.view.window];
    
    // Navigation bar
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self addCaptionButtonToNavigationItem];
    

    
    //set the initial index properly 
    int index = 0;
    NSArray* photos = [self.frc_photos fetchedObjects];
    
    if (self.currentPhoto != nil) {
        for (int i = 0; i < [photos count];i++) {
            Photo* currPhoto = [photos objectAtIndex:i];
            if ([self.currentPhoto.objectid isEqualToNumber:currPhoto.objectid]) {
                index = i;
                break;
            }
        }
    }
    [self.pagedViewSlider setInitialPageIndex:index];
   
	// Layout
	[self.pagedViewSlider performLayout];
  
    // Set status bar style to black translucent
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
	[self updateNavigation];
	[self hideControlsAfterDelay];
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
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didRotate:(NSNotification*)notification {
    [super didRotate:notification];
    //need to switch out the ladscape and portrait views
    //populate the sv_sliders as needed
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //going to potrait
        
        int currentScrollIndex = self.pagedViewSlider.currentPageIndex;
        self.view = self.v_portrait;
        [self.pagedViewSlider setInitialPageIndex:currentScrollIndex];
    }
    else {
        //going to landscape
        int currentScrollIndex = self.pagedViewSlider.currentPageIndex;
        self.view = self.v_landscape;        
        [self.pagedViewSlider setInitialPageIndex:currentScrollIndex];
    }
    
}

#pragma mark - Navigation

// Navigation
- (void)updateNavigation {
    NSArray* photos = [self.frc_photos fetchedObjects];
    // Title
	if (photos.count > 1) {
		self.title = [NSString stringWithFormat:@"%i of %i", self.pagedViewSlider.currentPageIndex+1, photos.count];		
	} else {
		self.title = nil;
	}
	
	// Buttons
	self.previousButton.enabled = (self.pagedViewSlider.currentPageIndex > 0);
	self.nextButton.enabled = (self.pagedViewSlider.currentPageIndex < photos.count-1);
}







#pragma mark Control Hiding / Showing

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		[self.controlVisibilityTimer release];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay {
    [self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		self.controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
    
    
}



- (void)setControlsHidden:(BOOL)hidden {
	
	// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Status Bar
	if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:hidden animated:YES];
	}
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;
	
	// Bars
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];

    // Captions scrollviewer
    UIPhotoCaptionScrollView* photoCaptionView = [self currentlyDisplayedView];
    [photoCaptionView.captionScrollView setAlpha:hidden ? 0 : 1];

    
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
	
}

- (void)hideControls { 
        [self setControlsHidden:YES]; 
}

- (void)toggleControls { 
        [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; 
}

#pragma mark - Frames
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}


- (CGRect) frameForCaptionTextField {
    UIDeviceOrientation orientation = [[UIDevice currentDevice]orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGRectMake(0, self.view.frame.size.height-kCaptionTextFieldHeight_landscape , kCaptionTextFieldWidth_landscape, kCaptionTextFieldHeight_landscape);
    }
    else {
        return CGRectMake(0, self.view.frame.size.height-kCaptionTextFieldHeight , kCaptionTextFieldWidth, kCaptionTextFieldHeight);
    }
}


- (CGRect)frameForPhoto:(int)index sliderIsHorizontal:(BOOL)isHorizontalOrientation {
    if (isHorizontalOrientation == NO) {
        
        return CGRectMake(0, 0, kPictureWidth_landscape, kPictureHeight_landscape);
    }
    else {
        int xcoordinate = index * (kPictureWidth + kPictureSpacing);
       return CGRectMake(xcoordinate, 0, kPictureWidth, kPictureHeight); 
    }
}

#pragma mark - UIPhotoCaptionScrollViewDelegate
- (UIPhotoCaptionScrollView*)currentlyDisplayedView {
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:self.pagedViewSlider.currentPageIndex];
    NSArray* currentlyDisplayedViews = [self.pagedViewSlider getVisibleViews];
    for (int i = 0; i < [currentlyDisplayedViews count];i++) {
        UIPhotoCaptionScrollView* photoCaptionView = [currentlyDisplayedViews objectAtIndex:i];
        if ([photoCaptionView.photo.objectid isEqualToNumber:photo.objectid]) {
            return photoCaptionView;
        }
    }
}

#pragma mark - UIPagedViewSlider2Delegate

- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider configure:(UIPhotoCaptionScrollView *)existingCell forRowAtIndex:(int)index withFrame:(CGRect)frame {
    Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
    ImageManager* imageManager = [ImageManager getInstance];

    [existingCell resetWithFrame:frame withPhoto:photo];

    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:existingCell forKey:an_IMAGEVIEW];
    UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
    
    [existingCell displayImage:image];
 
    
}

- (UIView*)viewSlider:(UIPagedViewSlider2 *)viewSlider cellForRowAtIndex:(int)index withFrame:(CGRect)frame {
   
       Photo* photo = [[self.frc_photos fetchedObjects]objectAtIndex:index];
        UIPhotoCaptionScrollView* photoAndCaptionScrollView = [[UIPhotoCaptionScrollView alloc]initWithFrame:frame withPhoto:photo];
        
        photoAndCaptionScrollView.viewController = self;
        ImageManager* imageManager = [ImageManager getInstance];
        
       
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:photoAndCaptionScrollView forKey:an_IMAGEVIEW];
        UIImage* image = [imageManager downloadImage:photo.imageurl withUserInfo:userInfo atCallback:self];
        
        [photoAndCaptionScrollView displayImage:image];

        return photoAndCaptionScrollView;

}

- (void) adjustNavigationButtons {
    if (m_isInEditMode) {
        self.navigationItem.rightBarButtonItem = self.submitButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = self.captionButton;
    }
}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider isAtIndex:(int)index withCellsRemaining:(int)numberOfCellsToEnd {
    if (index != m_currentIndex) {
        m_currentIndex = index;
        [self adjustNavigationButtons];
    }
    
    int numCellsLeft = [[self.frc_photos fetchedObjects]count] - index;
    
    if (numCellsLeft < threshold_LOADMOREPHOTOS) {
        [self.photoCloudEnumerator enumerateNextPage];
    }
    
    
}

- (void)viewSlider:(UIPagedViewSlider2*)viewSlider selectIndex:(int)index {
    NSLog(@"Dandarr");
}


- (int) itemCountFor: (UIPagedViewSlider2*)viewSlider {
    return [[self.frc_photos fetchedObjects]count];
}

#pragma mark - Image Download Protocol
- (void)onImageDownload:(UIImage *)image withUserInfo:(NSDictionary *)userInfo {
    UIZoomingScrollView* imageView = [userInfo objectForKey:an_IMAGEVIEW];
    [imageView displayImage:image];
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete {
    
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (type == NSFetchedResultsChangeInsert) {
        [self.pagedViewSlider onNewItemInsertedAt:newIndexPath.row];
        [self.pagedViewSlider tilePages];
    }
}

#pragma mark - Keyboard Event Handler
- (void) keyboardWillShow:(NSNotification *)notification {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    NSDictionary* info = [notification userInfo];

    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.sv_view.contentInset = contentInsets;
    self.sv_view.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, (self.tv_captionBox.frame.origin.y+self.tv_captionBox.frame.size.height)-kbSize.height);
    [self.sv_view setContentOffset:scrollPoint animated:YES];


    
    [UIView commitAnimations];
    
}

- (void) keyboardDidHide:(NSNotification *)notification {
    [self onExitEditMode];
}

#pragma mark - Edit Mode Transitions

- (void) onExitEditMode {
    m_isInEditMode = NO;
   
    self.navigationItem.leftBarButtonItem = self.navigationController.navigationItem.backBarButtonItem;
    [self addCaptionButtonToNavigationItem];
    
    
    //animate the fade out of the text view
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    self.tv_captionBox.alpha = 0;
    [UIView commitAnimations];
    
    //animate the scrolling down of the view back to its original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];     
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.sv_view.contentInset =  contentInsets;
    self.sv_view.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    [self.sv_view setContentOffset:scrollPoint animated:YES];
    
    [UIView commitAnimations];
     self.tv_captionBox.hidden = YES;
    [self.tv_captionBox setText:nil];
}

- (void) onEnterEditMode {
    m_isInEditMode = YES;
    self.navigationItem.leftBarButtonItem = self.cancelCaptionButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    self.tv_captionBox.hidden = NO;
    self.tv_captionBox.alpha = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; 
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.tv_captionBox cache:YES];
    self.tv_captionBox.alpha = 1;
    
    [self.sv_view bringSubviewToFront:self.tv_captionBox];
    [UIView commitAnimations];
}



#pragma mark - UICaptionTextViewDelegate Methods
- (void)captionTextView:(UICaptionTextView *)captionTextView finishedWithString:(NSString *)caption {
    self.tv_captionBox.hidden = YES;
    [captionTextView resignFirstResponder];
    [self onSubmitButtonPressed:nil];
    
}


- (void) onUserLoggedIn {
    [super onUserLoggedIn];
    [self addCaptionButtonToNavigationItem];
}

- (void) onUserLoggedOut {
    [super onUserLoggedOut];
    [self addCaptionButtonToNavigationItem];
}
@end
