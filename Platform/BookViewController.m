//
//  BookViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewController.h"
#import "PageViewController.h"
#import "Macros.h"
#import "Page.h"
#import "CloudEnumeratorFactory.h"

@implementation BookViewController
@synthesize pageController = m_pageController;
@synthesize pageContent = m_pageContent;

@synthesize pageID              = m_pageID;
@synthesize frc_published_pages = __frc_published_pages;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;

@synthesize controlVisibilityTimer = m_controlVisibilityTimer;


#pragma mark - Properties
//this NSFetchedResultsController will query for all published pages
- (NSFetchedResultsController*) frc_published_pages {
    NSString* activityName = @"BookViewController.frc_published_pages:";
    if (__frc_published_pages != nil) {
        return __frc_published_pages;
    }
    ResourceContext* resourceContext = [ResourceContext instance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    //add predicate to test for being published
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",STATE, kDRAFT];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_published_pages = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_PAGEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    
    return __frc_published_pages;
    
}

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location with thin the frc_published_photos for the photo with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_published_pages fetchedObjects];
    int index = 0;
    for (Page* page in fetchedObjects) {
        if ([page.objectid isEqualToNumber:pageid]) {
            retVal = index;
            break;
        }
        index++;
    }
    return index;
}

#pragma mark - Initializers
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) createContentPages
{
    NSMutableArray* pageNumbers = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 11; i++)
    {
        NSString *contentString = [[NSString alloc] initWithFormat:@"%d", i];
        [pageNumbers addObject:contentString];
    }
    
    self.pageContent = [[NSArray alloc] initWithArray:pageNumbers];
}


#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		[self.controlVisibilityTimer release];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		self.controlVisibilityTimer = [[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO] retain];
	}
}

- (void)setControlsHidden:(BOOL)hidden {
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
    
	// Get status bar height if visible
	//CGFloat statusBarHeight = 0;
	//if (![UIApplication sharedApplication].statusBarHidden) {
	//	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	//	statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	//}
	
	// Status Bar
	//if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
	//	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	//} else {
	//	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
	//}
	
	// Get status bar height if visible
	//if (![UIApplication sharedApplication].statusBarHidden) {
	//	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	//	statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	//}
	
	// Set navigation bar frame
	//CGRect navBarFrame = self.navigationController.navigationBar.frame;
	//navBarFrame.origin.y = statusBarHeight;
	//self.navigationController.navigationBar.frame = navBarFrame;
	
	// Navigation and tool bars
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [self.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
    
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	//[self hideControlsAfterDelay];
	
}

- (void)hideControls { 
    [self setControlsHidden:YES]; 
}

- (void)showControls { 
    [self cancelControlHiding];
    [self setControlsHidden:NO];
}

- (void)toggleControls { 
    [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; 
}



#pragma mark - PageViewController Delegate Methods
- (PageViewController *)viewControllerAtIndex:(int)index
{
    // Return the page view controller for the given index
    int count = [[self.frc_published_pages fetchedObjects]count];
    
    if (count == 0 || index >= count) {
        return nil;
    }
    else {
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 1];
        
        PageViewController * pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
        
        return pageViewController;
    }
    
}

- (NSUInteger)indexOfViewController:(PageViewController *)viewController
{
    return [self indexOfPageWithID:viewController.pageID];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PageViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PageViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    //if (index == [self.pageContent count]) {
    //    return nil;
    //}
    if (index == [[self.frc_published_pages fetchedObjects]count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[self createContentPages];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] 
                           initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                           options: options];
    
    self.pageController.dataSource = self;
    [self.pageController.view setFrame:[self.view bounds]];
    
    PageViewController* initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers  
                             direction:UIPageViewControllerNavigationDirectionForward 
                              animated:NO 
                            completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    //NSString* activityName = @"BookViewController.viewWillAppear:";
    [super viewWillAppear:animated];
   
    /*
    //render the page ID specified as a parameter
    if (self.pageID != nil && [self.pageID intValue] != 0) {
        //render the page specified by the ID passed in
        [self renderPage];
    }
    else {
        //need to find the latest page
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:DATEPUBLISHED sortAscending:NO];
        
        LOG_PAGEVIEWCONTROLLER(0, @"%@Enumerating pages from cloud",activityName);
        [self.pageCloudEnumerator enumerateUntilEnd];
        
        
        if (page != nil) {
            //local store does contain pages to enumerate
            self.pageID = page.objectid;
            [self renderPage];
        }
        else {
            //empty page store, will need to thow up a progress dialog to show user of download
            LOG_PAGEVIEWCONTROLLER(0, @"%@Enumerating pages from cloud",activityName);
            [self.pageCloudEnumerator enumerateUntilEnd];
            //TODO: need to make a call to a centrally hosted busy indicator view
        }
        
    }
    
    // Toolbar: we update the toolbar items each tgime the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
     
    */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Static Initializers
+ (BookViewController*) createInstance {
    BookViewController* instance = [[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
    [instance autorelease];
    return instance;
}


@end
