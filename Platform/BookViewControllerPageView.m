//
//  BookViewControllerPageView.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerPageView.h"
#import "PageViewController.h"
#import "Macros.h"
#import "Page.h"
#import "CloudEnumeratorFactory.h"
#import "PageState.h"
#import "HomeViewController.h"
#import "UserDefaultSettings.h"

@implementation BookViewControllerPageView
@synthesize pageController = m_pageController;
@synthesize invisibleReadButton = m_invisibleReadButton;
@synthesize invisibleProductionLogButton = m_invisibleProductionLogButton;
@synthesize invisibleWritersLogButton = m_invisibleWritersLogButton;
@synthesize v_tapWritersLogView = m_v_tapWritersLogView;


#pragma mark - Frames
- (CGRect) frameForPageViewController {
    return CGRectMake(0, 0, 302, 460);
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


#pragma mark - UIPageViewController Data Source and Delegate Methods (for iOS 5+)
- (UIViewController *)viewControllerAtIndex:(int)index
{
    //NSString* activityName = @"BookViewControllerpageView.viewControllerAtIndex:";
    
    if (index == 0) {
        // Return the title page, HomeViewController
        HomeViewController* homeViewController = [HomeViewController createInstance];
        
        return homeViewController;
    }
    else {
        // Return the page view controller for the given index
        index--;    // we need to subtract one from the index to account for the title page which is not in the frc
        
        int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
        
        if (publishedPageCount == 0 || index >= publishedPageCount) {
            return nil;
        }
        else {
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
            //self.pageID = page.objectid;
            
            NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 2];
            
            PageViewController* pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
            
            [pageNumber release];
            
            //we need to make a check to see how many objects we have left
            //if we are below a threshold, we need to execute a fetch to the server
            int lastIndex = publishedPageCount - 1;
            int pagesRemaining = lastIndex - index;
            [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];
            
            return pageViewController;
        }
    }
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[HomeViewController class]]) {
        // title page, return HomeViewController
        return 0;
    }
    else if ([viewController isKindOfClass:[PageViewController class]]) {
        PageViewController* pageViewController = (PageViewController *)viewController;
        return [self indexOfPageWithID:pageViewController.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
    }
    else {
        return NSNotFound;
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        // we are on the title page
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index == (publishedPageCount + 1)) {
        // we add 1 to the frc count to account for the title page of the book which is not in the frc,
        // if the new index equals the frc count + 1 then it means we are at the end of the book
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        UIViewController* currentViewController = [pageViewController.viewControllers objectAtIndex:0];
        
        if ([currentViewController isKindOfClass:[HomeViewController class]]) {
            // we are now showing the title page, enable and show the title page buttons
            [self.invisibleReadButton setEnabled:YES];
            [self.invisibleProductionLogButton setEnabled:YES];
            [self.invisibleWritersLogButton setEnabled:YES];
            [self.invisibleReadButton setHidden:NO];
            [self.invisibleProductionLogButton setHidden:NO];
            [self.invisibleWritersLogButton setHidden:NO];
        }
        else if ([currentViewController isKindOfClass:[PageViewController class]]) {
            // we are still showing a regular page view, ensure the title page buttons are disabled and hidden
            [self.invisibleReadButton setEnabled:NO];
            [self.invisibleProductionLogButton setEnabled:NO];
            [self.invisibleWritersLogButton setEnabled:NO];
            [self.invisibleReadButton setHidden:YES];
            [self.invisibleProductionLogButton setHidden:YES];
            [self.invisibleWritersLogButton setHidden:YES];
            
            NSUInteger index = [self indexOfViewController:currentViewController];
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            if (index != NSNotFound) {
                // we update the userDefault setting for the last page viewed by the user,
                // 1 is subtracted from the index to account for the title page which is not in the frc
                [userDefaults setInteger:(index - 1) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
            }
            else {
                [userDefaults setInteger:(0) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
            }
        }
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return UIPageViewControllerSpineLocationMin;
}


#pragma mark - Render Page from PageViewController
-(void)renderPage {
    //NSString* activityName = @"BookViewController.controller.renderPage:";
    
    UIViewController* pageViewController = nil;
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    // we check the user default settings for the last page of the book the user viewed
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastViewedPublishedPageIndex = [userDefaults integerForKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
    
    
    // check to determine which page to render first
    if (self.shouldOpenToTitlePage) {
        // go to title page immidiately
        pageViewController = [self viewControllerAtIndex:0];
    }
    else if (publishedPageCount != 0) {
        if (self.pageID != nil  && [self.pageID intValue] != 0) {
            // the page id has been set, we will move to that page
            int indexForPage = [self indexOfPageWithID:self.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            pageViewController = [self viewControllerAtIndex:indexForPage];
        }
        else if (lastViewedPublishedPageIndex < publishedPageCount) {
            // we go to the last page the user viewed
            int indexForPage = lastViewedPublishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            pageViewController = [self viewControllerAtIndex:indexForPage];
        }
        else {
            //need to find the first page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:YES];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                int indexForPage = [self indexOfPageWithID:self.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                pageViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                //no published pages, go to title page
                pageViewController = [self viewControllerAtIndex:0];
            }
        }
    }
    
    
    if (pageViewController) {
        if ([pageViewController isKindOfClass:[HomeViewController class]]) {
            // we are about to move to the title page of the book, enable and show the title page buttons
            [self.invisibleReadButton setEnabled:YES];
            [self.invisibleProductionLogButton setEnabled:YES];
            [self.invisibleWritersLogButton setEnabled:YES];
            [self.invisibleReadButton setHidden:NO];
            [self.invisibleProductionLogButton setHidden:NO];
            [self.invisibleWritersLogButton setHidden:NO];
        }
        else {
            // we are about to move to a page view of the book that is not the title page, disable and hide the title page buttons
            [self.invisibleReadButton setEnabled:NO];
            [self.invisibleProductionLogButton setEnabled:NO];
            [self.invisibleWritersLogButton setEnabled:NO];
            [self.invisibleReadButton setHidden:YES];
            [self.invisibleProductionLogButton setHidden:YES];
            [self.invisibleWritersLogButton setHidden:YES];
        }
        
        NSArray *viewControllers = [NSArray arrayWithObject:pageViewController];
        
        [self.pageController setViewControllers:viewControllers  
                                      direction:UIPageViewControllerNavigationDirectionForward 
                                       animated:self.shouldAnimatePageTurn 
                                     completion:nil];
    }
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
    
    pvc.delegate = self;
    pvc.dataSource = self;
    
    self.pageController = pvc;
    [pvc release];
    
    
    //[self.pageController.view setFrame:[self.view bounds]];
    [self.pageController.view setFrame:[self frameForPageViewController]];
    
    [self.pageController setViewControllers:nil  
                                  direction:UIPageViewControllerNavigationDirectionForward 
                                   animated:NO 
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    // by default the book should always open to the title page on first load
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
    
    // Create gesture recognizer for the background image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_background addGestureRecognizer:oneFingerTap];
    
    
    /*// Enable gesture recognizers for the title page buttons of the HomeViewController
    UIView* tapReadView = [[UIView alloc] initWithFrame:CGRectMake(32, 183, 257, 66)];
    UIView* tapProdutionLogView = [[UIView alloc] initWithFrame:CGRectMake(32, 242, 257, 66)];
    self.v_tapWritersLogView = [[UIView alloc] initWithFrame:CGRectMake(32, 301, 257, 66)];
    
    // add tapViews to the view
    [self.view addSubview:tapReadView];
    [self.view addSubview:tapProdutionLogView];
    [self.view addSubview:self.v_tapWritersLogView];
    
    UITapGestureRecognizer* tapReadButton = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReadButtonClicked:)] autorelease];
    UITapGestureRecognizer* tapProductionLogButton = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onProductionLogButtonClicked:)] autorelease];
    UITapGestureRecognizer* tapWritersLogButton = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onWritersLogButtonClicked:)] autorelease];
    
    tapWritersLogButton.delegate = self;
    
    // Set required taps and number of touches
    [tapReadButton setNumberOfTapsRequired:1];
    [tapReadButton setNumberOfTouchesRequired:1];
    [tapProductionLogButton setNumberOfTapsRequired:1];
    [tapProductionLogButton setNumberOfTouchesRequired:1];
    [tapWritersLogButton setNumberOfTapsRequired:1];
    [tapWritersLogButton setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [tapReadView addGestureRecognizer:tapReadButton];
    [tapProdutionLogView addGestureRecognizer:tapProductionLogButton];
    [self.v_tapWritersLogView addGestureRecognizer:tapWritersLogButton];
    
    [tapReadView release];
    [tapProdutionLogView release];
    //[tapWritersLogButton release];*/
    
    // Add an invisible buttons to capture touches on HomePage buttons
    self.invisibleReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.invisibleProductionLogButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.invisibleWritersLogButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //self.invisibleReadButton.backgroundColor = [UIColor redColor];
    //self.invisibleProductionLogButton.backgroundColor = [UIColor redColor];
    //self.invisibleWritersLogButton.backgroundColor = [UIColor redColor];
    
    // set the frames of the buttons to match the frames on the HomeViewController layout
    self.invisibleReadButton.frame = CGRectMake(32, 183, 257, 66);
    self.invisibleProductionLogButton.frame = CGRectMake(32, 242, 257, 66);
    self.invisibleWritersLogButton.frame = CGRectMake(32, 301, 257, 66);
    
    // add button targets and actions
    [self.invisibleReadButton addTarget:self action:@selector(onReadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.invisibleProductionLogButton addTarget:self action:@selector(onProductionLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.invisibleWritersLogButton addTarget:self action:@selector(onWritersLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // add buttons to the view
    [self.view addSubview:self.invisibleReadButton];
    [self.view addSubview:self.invisibleProductionLogButton];
    [self.view addSubview:self.invisibleWritersLogButton];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.invisibleReadButton = nil;
    self.invisibleProductionLogButton = nil;
    self.invisibleWritersLogButton = nil;
}

- (void) viewWillAppear:(BOOL)animated {
   // NSString* activityName = @"BookViewControllerPageView.viewWillAppear:";
    [super viewWillAppear:animated];
   
    [self renderPage];
    
    // Set the navigation bar and toolbar to the custom clear type
    // Background Image
    UIImage *barImage = [UIImage imageNamed:@"NavigationBar_clear.png"];
    
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        // iOS 5 method for changing bar backgounds
        [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.toolbar setBackgroundImage:barImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated {
    // NSString* activityName = @"BookViewControllerPageView.viewWillDisppear:";
    [super viewWillDisappear:animated];
    
    // Set the navigation bar and toolbar back to the default type
    if([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        // iOS 5 method for changing bar backgounds
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = NO;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIGestureRecognizer Delegates
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if (self.v_tapWritersLogView.superview != nil) {
        if ([touch.view isDescendantOfView:self.v_tapWritersLogView]) {
            // we touched our control surface
            [self.nextResponder touchesBegan:[NSSet setWithObject:touch] withEvent:UIEventTypeTouches];
            
            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}

#pragma mark - Navigation Bar Button Handlers
- (void) onHomeButtonPressed:(id)sender {
    [super onHomeButtonPressed:sender];
    
    HomeViewController* homeViewController = [HomeViewController createInstance];
    
    if (homeViewController) {
        // we are about to move to the title page of the book, enable and show the title page buttons
        [self.invisibleReadButton setEnabled:YES];
        [self.invisibleProductionLogButton setEnabled:YES];
        [self.invisibleWritersLogButton setEnabled:YES];
        [self.invisibleReadButton setHidden:NO];
        [self.invisibleProductionLogButton setHidden:NO];
        [self.invisibleWritersLogButton setHidden:NO];
        
        NSArray *viewControllers = [NSArray arrayWithObject:homeViewController];
        
        self.shouldOpenToTitlePage = NO;
        self.shouldAnimatePageTurn = YES;
        
        [self.pageController setViewControllers:viewControllers  
                                      direction:UIPageViewControllerNavigationDirectionReverse 
                                       animated:self.shouldAnimatePageTurn 
                                     completion:nil];
    }
}

#pragma mark - UI Event Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    [super onReadButtonClicked:sender];

    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = YES;
    
    [self renderPage];

}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    [super onProductionLogButtonClicked:sender];
    
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    //called when the writer's log button is pressed
    [super onWritersLogButtonClicked:sender];
    
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"BookViewController.controller.didChangeObject:";
    if (controller == self.frc_published_pages) {
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
            //[self renderPage];
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a page
            
        }
    }
    else {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    [super onEnumerateComplete:userInfo];
    
}

#pragma mark - Static Initializers
+ (BookViewControllerPageView*) createInstance {
    BookViewControllerPageView* instance = [[BookViewControllerPageView alloc]initWithNibName:@"BookViewControllerPageView" bundle:nil];
    [instance autorelease];
    return instance;
}

+ (BookViewControllerPageView*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerPageView* vc = [BookViewControllerPageView createInstance];
    vc.pageID = pageID;
    return vc;
}


@end
