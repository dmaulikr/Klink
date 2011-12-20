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
#import "UINotificationIcon.h"
#import "SocialSharingManager.h"
#import "PageState.h"

@implementation BookViewController
@synthesize pageController = m_pageController;
@synthesize pageID              = m_pageID;
@synthesize frc_published_pages = __frc_published_pages;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;
@synthesize tb_facebookButton       = m_tb_facebookButton;
@synthesize tb_twitterButton        = m_tb_twitterButton;
@synthesize tb_bookmarkButton       = m_tb_bookmarkButton;
@synthesize tb_notificationButton  = m_tb_notificationButton;


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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",STATE, kPUBLISHED];
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
    [sortDescriptor release];
    return __frc_published_pages;
    
}

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location with thin the frc_published_photos for the photo with the id specified
    NSArray* fetchedObjects = [self.frc_published_pages fetchedObjects];
    int index = 0;
    for (Page* page in fetchedObjects) {
        
        if ([page.objectid isEqualToNumber:pageid]) {
           
            break;
        }
        index++;
    }
    return index;
}

#pragma mark - Toolbar buttons
- (NSArray*) toolbarButtonsForViewController {
    //returns an array with the toolbar buttons for this view controller
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    // initialize button spacers
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem* fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];

    //add Facebook share button
   UIBarButtonItem* fb = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(onFacebookButtonPressed:)];
    self.tb_facebookButton  = fb;
    [fb release];
    [retVal addObject:self.tb_facebookButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add Twitter share button
    UIBarButtonItem* tb = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(onTwitterButtonPressed:)];
    self.tb_twitterButton = tb;
    [tb release];
    [retVal addObject:self.tb_twitterButton];
    
    //add fixed space for button spacing
    fixedSpace1.width = 66;
    [retVal addObject:fixedSpace1];
    
    //add bookmark button
    UIBarButtonItem* bkb = [[UIBarButtonItem alloc]
                                       initWithImage:[UIImage imageNamed:@"icon-ribbon2.png"]
                                       style:UIBarButtonItemStylePlain
                                       target:self 
                                       action:@selector(onBookmarkButtonPressed:)];
    self.tb_bookmarkButton = bkb;
    [bkb release];
    [retVal addObject:self.tb_bookmarkButton];
    
    //add fixed space for button spacing
    fixedSpace2.width = 13;
    [retVal addObject:fixedSpace2];
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        
        //add flexible space for button spacing
        [retVal addObject:flexibleSpace];
        
        UINotificationIcon* notificationIcon = [UINotificationIcon notificationIconForPageViewControllerToolbar];
        self.tb_notificationButton = [[[UIBarButtonItem alloc]initWithCustomView:notificationIcon]autorelease];
        
        [retVal addObject:self.tb_notificationButton];
    }
    [flexibleSpace release];
    [fixedSpace1 release];
    [fixedSpace2 release];
    return retVal;
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


#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		//[self.controlVisibilityTimer release];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO] ;
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
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            Caption* caption = [page captionWithHighestVotes];
            [sharingManager shareCaptionOnFacebook:caption.objectid onFinish:nil];
            [self disableFacebookButton];
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
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            Caption* caption = [page captionWithHighestVotes];
            [sharingManager shareCaptionOnTwitter:caption.objectid onFinish:nil];
            [self disableTwitterButton];
        }
    }

}

- (void) onBookmarkButtonPressed:(id)sender {
    
}

#pragma mark - Frames
- (CGRect) frameForPageViewController {
    return CGRectMake(0, 0, 302, 460);
}

#pragma mark - Initializers
- (id) commonInit {
    //common setup for the view controller
    self.pageCloudEnumerator = [[CloudEnumeratorFactory instance]enumeratorForPages];
    self.pageCloudEnumerator.delegate = self;
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self = [self commonInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
        self.pageID = page.objectid;
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 1];
        
        PageViewController * pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];

        [pageNumber release];

        
        // reenable sharing buttons
        [self enableFacebookButton];
        [self enableTwitterButton];

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
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    
    UIPageViewController* pvc = [[UIPageViewController alloc] 
                           initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                           options: options];
    self.pageController = pvc;
    [pvc release];
    
    self.pageController.dataSource = self;
    //[self.pageController.view setFrame:[self.view bounds]];
    [self.pageController.view setFrame:[self frameForPageViewController]];
    
//    PageViewController* initialViewController = [self viewControllerAtIndex:0];
//    
//    if (initialViewController) {
//        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
//        
//        [self.pageController setViewControllers:viewControllers  
//                                      direction:UIPageViewControllerNavigationDirectionForward 
//                                       animated:NO 
//                                     completion:nil];
//        
//        [self addChildViewController:self.pageController];
//        [self.view addSubview:self.pageController.view];
//        [self.pageController didMoveToParentViewController:self];
//        
//    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    NSString* activityName = @"BookViewController.viewWillAppear:";
    [super viewWillAppear:animated];
   
    PageViewController* initialViewController = nil;
    
    //here we check to see how many items are in the FRC, if it is 0,
    //then we initiate a query against the cloud.
    int count = [[self.frc_published_pages fetchedObjects] count];
    if (count == 0) {
        //there are no published page objects in local store, update from cloud
        //will need to thow up a progress dialog to show user of download
        LOG_BOOKVIEWCONTROLLER(0, @"%@No local drafts found, initiating query against cloud",activityName);
        [self.pageCloudEnumerator enumerateUntilEnd:nil];
        
        //TODO: need to make a call to a centrally hosted busy indicator view
    }
    else {
        if (self.pageID != nil  && [self.pageID intValue] != 0) {
            //the page id has been set, we will move to that page
            int indexForPage = [self indexOfPageWithID:self.pageID];
            initialViewController = [self viewControllerAtIndex:indexForPage];
        }
        else {
            //need to find the latest page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:NO];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                int indexForPage = [self indexOfPageWithID:self.pageID];
                initialViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                //no published pages
                initialViewController = [self viewControllerAtIndex:0];
            }
        }
    }
    
    if (initialViewController) {
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [self.pageController setViewControllers:viewControllers  
                                      direction:UIPageViewControllerNavigationDirectionForward 
                                       animated:NO 
                                     completion:nil];
        
        [self addChildViewController:self.pageController];
        [self.view addSubview:self.pageController.view];
        [self.pageController didMoveToParentViewController:self];
        
    }
    
    // Toolbar: we update the toolbar items each time the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"BookViewController.controller.didChangeObject:";
    if (controller == self.frc_published_pages) {
        /*PageViewController* pageViewController = nil;
        
        if (self.pageID != nil  && [self.pageID intValue] != 0) {
            //the page id has been set, we will move to that page
            int indexForPage = [self indexOfPageWithID:self.pageID];
            pageViewController = [self viewControllerAtIndex:indexForPage];
        }
        else {
            //need to find the latest page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:DATEPUBLISHED sortAscending:NO];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                int indexForPage = [self indexOfPageWithID:self.pageID];
                pageViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                //no published pages
                pageViewController = [self viewControllerAtIndex:0];
            }
        }
        
        
        if (pageViewController) {
            NSArray *viewControllers = [NSArray arrayWithObject:pageViewController];
            
            [self.pageController setViewControllers:viewControllers  
                                          direction:UIPageViewControllerNavigationDirectionForward 
                                           animated:NO 
                                         completion:nil];
        }*/
        
        
        /*PageViewController* pageViewController = nil;
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
            // Uncomment the below line if you want the pageViewController to move to the new page aded
            //pageViewController = [self viewControllerAtIndex:[newIndexPath row]];
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a page
            //pageViewController = [self viewControllerAtIndex:count-1];
        }
        
        // Uncomment the below line if you want the pageViewController to move to the new page aded
        if (pageViewController) {
            NSArray *viewControllers = [NSArray arrayWithObject:pageViewController];
            
            [self.pageController setViewControllers:viewControllers  
                                          direction:UIPageViewControllerNavigationDirectionForward 
                                           animated:NO 
                                         completion:nil];
        }*/
    }
    else {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    //NSString* activityName = @"BookViewController.controller.onEnumerateComplete:";
    
    PageViewController* pageViewController = nil;
    
    int count = [[self.frc_published_pages fetchedObjects]count];
    
    if (count != 0) {
        if (self.pageID != nil  && [self.pageID intValue] != 0) {
            //the page id has been set, we will move to that page
            int indexForPage = [self indexOfPageWithID:self.pageID];
            pageViewController = [self viewControllerAtIndex:indexForPage];
        }
        else {
            //need to find the latest page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:NO];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                int indexForPage = [self indexOfPageWithID:self.pageID];
                pageViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                //no published pages
                pageViewController = [self viewControllerAtIndex:0];
            }
        }
    }
    
    if (pageViewController) {
        NSArray *viewControllers = [NSArray arrayWithObject:pageViewController];
        
        [self.pageController setViewControllers:viewControllers  
                                      direction:UIPageViewControllerNavigationDirectionForward 
                                       animated:NO 
                                     completion:nil];
    }
}

#pragma mark - Static Initializers
+ (BookViewController*) createInstance {
    BookViewController* instance = [[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

+ (BookViewController*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewController* vc = [BookViewController createInstance];
    vc.pageID = pageID;
    return vc;
}


@end
