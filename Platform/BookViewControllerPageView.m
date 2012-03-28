//
//  BookViewControllerPageView.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerPageView.h"
#import "Macros.h"
#import "Page.h"
#import "Photo.h"
#import "CloudEnumeratorFactory.h"
#import "PageState.h"
#import "UserDefaultSettings.h"
#import "ProfileViewController.h"
#import "BookTableOfContentsViewController.h"

@implementation BookViewControllerPageView
@synthesize pageController = m_pageController;
@synthesize tapGesture = m_tapGesture;
//@synthesize panGesture = m_panGesture;


#pragma mark - Frames
- (CGRect) frameForBookPageViewController {
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

#pragma mark - Page Index Methods
- (void)savePageIndex:(int)index {
    [super savePageIndex:index];
}

- (int)getLastViewedPageIndex {
    return [super getLastViewedPageIndex];
}

#pragma mark - UIPageViewController Data Source and Delegate Methods (for iOS 5+)
- (UIViewController *)viewControllerAtIndex:(int)index
{
    //NSString* activityName = @"BookViewControllerpageView.viewControllerAtIndex:";
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index == 0) {
        // Return the title page, HomeViewController
        HomeViewController* homeViewController;
        if (self.userID != nil) {
            homeViewController = [HomeViewController createInstanceWithUserID:self.userID];
        }
        else {
            homeViewController = [HomeViewController createInstance];
        }
        homeViewController.delegate = self;
        
        return homeViewController;
    }
    else if (index == publishedPageCount + 1) {
        // Return the last page placeholder, BookLastPageViewController
        BookLastPageViewController* bookLastPageViewController;
        if (self.userID != nil) {
            bookLastPageViewController = [BookLastPageViewController createInstanceWithUserID:self.userID];
        }
        else {
            bookLastPageViewController = [BookLastPageViewController createInstance];
        }
        bookLastPageViewController.delegate = self;
        
        return bookLastPageViewController;
    }
    else {
        // Return the page view controller for the given index
        index--;    // we need to subtract one from the index to account for the title page which is not in the frc
        
        if (publishedPageCount == 0 || index >= publishedPageCount) {
            return nil;
        }
        else {
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
            
            NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 2];
            
            BookPageViewController* bookPageViewController = [BookPageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
            bookPageViewController.delegate = self;
            
            [pageNumber release];
            
            //we need to make a check to see how many objects we have left
            //if we are below a threshold, we need to execute a fetch to the server
            int lastIndex = publishedPageCount - 1;
            int pagesRemaining = lastIndex - index;
            [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];
            
            return bookPageViewController;
        }
    }
}

- (int)indexOfViewController:(UIViewController *)viewController
{
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if ([viewController isKindOfClass:[HomeViewController class]]) {
        // title page, return HomeViewController
        return 0;
    }
    else if ([viewController isKindOfClass:[BookLastPageViewController class]]) {
        // last page, return BookLastPageViewController
        return publishedPageCount + 1;
    }
    else if ([viewController isKindOfClass:[BookPageViewController class]]) {
        BookPageViewController* bookPageViewController = (BookPageViewController *)viewController;
        return [self indexOfPageWithID:bookPageViewController.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
    }
    else {
        return NSNotFound;
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int index = [self indexOfViewController:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        // we are on the title page
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int index = [self indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index > (publishedPageCount + 1)) {
        // if the new index is greater than the frc count + 1 then it means we are at the end of the book
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        UIViewController* currentViewController = [pageViewController.viewControllers objectAtIndex:0];
        
        if ([currentViewController isKindOfClass:[HomeViewController class]]) {
            // we are now showing the title page
        }
        else if ([currentViewController isKindOfClass:[HomeViewController class]]) {
            // we are now showing the last placholder page
        }
        else if ([currentViewController isKindOfClass:[BookPageViewController class]]) {
            // we are still showing a regular page view
            
            self.shouldOpenToLastPage = NO;
            
            int index = [self indexOfViewController:currentViewController];
            int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
            
            if (publishedPageCount != NSNotFound && index != NSNotFound) {
                
                int publishedPageIndex = index - 1;  // 1 is subtracted from the index to account for the title page which is not in the frc
                
                if (publishedPageIndex < publishedPageCount) {
                    
                    Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:publishedPageIndex];
                    self.pageID = page.objectid;
                    
                    ResourceContext* resourceContext = [ResourceContext instance];
                    
                    Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:page.finishedphotoid];
                    self.topVotedPhotoID = photo.objectid;
                    
                    Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:page.finishedcaptionid];
                    self.topVotedCaptionID = caption.objectid;
                    
                    // we update the userDefault setting for the last page viewed by the user
                    [self savePageIndex:publishedPageIndex];
                }
                else {
                    [self savePageIndex:0];
                }
            }
            else {
                [self savePageIndex:0];
            }
        }
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return UIPageViewControllerSpineLocationMin;
}


#pragma mark - Render Page from BookPageViewController
-(void)renderPage {
    [super renderPage];
    
    UIViewController* bookPageViewController = nil;
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    // we check the user default settings for the last page of the book the user viewed
    int lastViewedPublishedPageIndex = [self getLastViewedPageIndex];
    
    // check to determine which page to render first
    if (self.shouldOpenToLastPage) {
        // cancel further opening to the last page
        //self.shouldOpenToLastPage = NO;
        
        int publishedPageIndex = publishedPageCount - 1;
        
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:publishedPageIndex];
        self.pageID = page.objectid;
        
        // go to last page immidiately
        bookPageViewController = [self viewControllerAtIndex:publishedPageCount];
    }
    else if (self.shouldOpenToTitlePage) {
        // go to title page immidiately
        bookPageViewController = [self viewControllerAtIndex:0];
    }
    else if (publishedPageCount != 0) {
        if (self.shouldOpenToSpecificPage) {
            // cancel further opening to this specific page
            //self.shouldOpenToSpecificPage = NO;
            
            if (self.pageID != nil  && [self.pageID intValue] != 0) {
                // the page id has been set, we will move to that page
                int publishedPageIndex = [self indexOfPageWithID:self.pageID];
                int indexForPage = publishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                
                // we update the userDefault setting for the last page viewed by the user to be this page
                [self savePageIndex:publishedPageIndex];
                
                bookPageViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                // No page specified, go to last page placeholder immidiately
                bookPageViewController = [self viewControllerAtIndex:publishedPageCount+1];
            }
        }
        else if (lastViewedPublishedPageIndex < publishedPageCount) {
            // we go to the last page the user viewed
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:lastViewedPublishedPageIndex];
            self.pageID = page.objectid;
            
            int indexForPage = lastViewedPublishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            bookPageViewController = [self viewControllerAtIndex:indexForPage];
        }
        else {
            //need to find the first page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:YES];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                
                int publishedPageIndex = [self indexOfPageWithID:self.pageID];
                int indexForPage = publishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                
                // we update the userDefault setting for the last page viewed by the user to be this page
                [self savePageIndex:publishedPageIndex];
                
                bookPageViewController = [self viewControllerAtIndex:indexForPage];
            }
            else {
                //no published pages, go to last page placeholder immidiately
                bookPageViewController = [self viewControllerAtIndex:publishedPageCount+1];
            }
        }
    }
    else {
        //no published pages, go to last page placeholder immidiately
        bookPageViewController = [self viewControllerAtIndex:publishedPageCount+1];
    }
    
    
    if (bookPageViewController) {
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        self.topVotedPhotoID = page.finishedphotoid;
        self.topVotedCaptionID = page.finishedcaptionid;
        
        NSArray *viewControllers = [NSArray arrayWithObject:bookPageViewController];
        
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
    
    // set up a tap gesture recognizer to grab page flip taps that may cover BookPageViewController and HomeViewController buttons
    for (UIGestureRecognizer* gesture in self.pageController.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            self.tapGesture = (UITapGestureRecognizer*)gesture;
            self.tapGesture.delegate = self;
        }
        /*else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            self.panGesture = (UIPanGestureRecognizer*)gesture;
            self.panGesture.delegate = self;
        }*/
    }
    
    /*// Add a swipe gesture recognizer to grab page flip swipes that start from the far right of the screen, past the edge of the book page
    self.panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:nil] autorelease];
    [self.panGesture setDelegate:self];
    [self.iv_background addGestureRecognizer:self.panGesture];
    //enable gesture events on the background image
    [self.iv_background setUserInteractionEnabled:YES];*/
    
    //[self.pageController.view setFrame:[self.view bounds]];
    [self.pageController.view setFrame:[self frameForBookPageViewController]];
    
    [self.pageController setViewControllers:nil  
                                  direction:UIPageViewControllerNavigationDirectionForward 
                                   animated:NO 
                                 completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    /*// Create gesture recognizer for the background image view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the photo image view
    [self.iv_background addGestureRecognizer:oneFingerTap];*/
    
    // Bring the book cover subview to the front
    [self.view bringSubviewToFront:self.iv_bookCover];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tapGesture = nil;
    //self.panGesture = nil;
    
}

- (void) viewWillAppear:(BOOL)animated {
   // NSString* activityName = @"BookViewControllerPageView.viewWillAppear:";
    [super viewWillAppear:animated];
   
    [self renderPage];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    // NSString* activityName = @"BookViewControllerPageView.viewWillDisppear:";
    [super viewWillDisappear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated {
    // NSString* activityName = @"BookViewControllerPageView.viewDidAppear:";
    [super viewDidAppear:animated];
    
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
    if (self.pageController.view.superview != nil) {
        if (gestureRecognizer == self.tapGesture) {
            // we touched the UIPageViewController
            [self.nextResponder touchesBegan:[NSSet setWithObject:touch] withEvent:UIEventTypeTouches];
            
            return NO; // ignore the touch
        }
        /*else if (gestureRecognizer == self.panGesture) {
            // we touched background of the BookViewController, pass the pan to the UIPageViewController
            [self.pageController.view touchesBegan:[NSSet setWithObject:touch] withEvent:UIEventTypeTouches];
            
            return YES; // handle the touch
        }*/
    }
    return YES; // handle the touch
}

#pragma mark - Button Handlers
#pragma mark Book Page Delegate Methods
- (IBAction) onHomeButtonPressed:(id)sender {
    [super onHomeButtonPressed:sender];
    
    HomeViewController* homeViewController;
    if (self.userID != nil) {
        homeViewController = [HomeViewController createInstanceWithUserID:self.userID];
    }
    else {
        homeViewController = [HomeViewController createInstance];
    }
    homeViewController.delegate = self;
    
    if (homeViewController) {
        
        NSArray *viewControllers = [NSArray arrayWithObject:homeViewController];
        
        self.shouldOpenToTitlePage = NO;
        self.shouldAnimatePageTurn = YES;
        
        [self.pageController setViewControllers:viewControllers  
                                      direction:UIPageViewControllerNavigationDirectionReverse 
                                       animated:self.shouldAnimatePageTurn 
                                     completion:nil];
    }
}

- (IBAction) onFacebookButtonPressed:(id)sender {   
    [super onFacebookButtonPressed:sender];
}

- (IBAction) onTwitterButtonPressed:(id)sender {
    [super onTwitterButtonPressed:sender];
}

- (IBAction) onLinkButtonClicked:(id)sender {
    [super onLinkButtonClicked:sender];
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = NO;
    
    UIResourceLinkButton* rlb = (UIResourceLinkButton*)sender;
    ProfileViewController* pvc = [ProfileViewController createInstanceForUser:rlb.objectID];
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:pvc];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
    
}

- (IBAction) onTableOfContentsButtonPressed:(id)sender {
    [super onTableOfContentsButtonPressed:sender];
}

- (IBAction) onZoomOutPhotoButtonPressed:(id)sender {
    [super onZoomOutPhotoButtonPressed:sender];
}

#pragma mark Home Page Delegate Methods
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    [super onReadButtonClicked:sender];
    
    [self renderPage];
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    [super onProductionLogButtonClicked:sender];
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
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
    [super onEnumerateComplete:enumerator withResults:results withUserInfo:userInfo];
    
}

#pragma mark - Static Initializers
+ (BookViewControllerPageView*) createInstance {
    BookViewControllerPageView* instance = [[BookViewControllerPageView alloc]initWithNibName:@"BookViewControllerPageView" bundle:nil];
    // by default the book should always open to the title page on first load
    instance.shouldOpenToTitlePage = YES;
    instance.shouldOpenToSpecificPage = NO;
    instance.shouldOpenToLastPage = NO;
    instance.shouldAnimatePageTurn = NO;
    [instance autorelease];
    return instance;
}

+ (BookViewControllerPageView*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerPageView* vc = [BookViewControllerPageView createInstance];
    vc.pageID = pageID;
    vc.shouldOpenToTitlePage = NO;
    vc.shouldOpenToSpecificPage = YES;
    vc.shouldOpenToLastPage = NO;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}


@end
