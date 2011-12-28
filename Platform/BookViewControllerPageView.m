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

@implementation BookViewControllerPageView
@synthesize pageController = m_pageController;


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



#pragma mark - PageViewController Delegate Methods (for iOS 5+)
- (PageViewController *)viewControllerAtIndex:(int)index
{
    NSString* activityName = @"BookViewControllerpageView.viewControllerAtIndex:";
    // Return the page view controller for the given index
    int count = [[self.frc_published_pages fetchedObjects]count];
    
    if (count == 0 || index >= count) {
        return nil;
    }
    else {
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        self.pageID = page.objectid;
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 1];
        
        PageViewController* pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];

        [pageNumber release];
        
        //we need to make a check to see how many objects we have left
        //if we are below a threshold, we need to execute a fetch to the server
        int lastIndex = count - 1;
        int pagesRemaining = lastIndex - index;
        [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];
        
        // reenable sharing buttons
        //[super enableFacebookButton];
        //[super enableTwitterButton];

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


#pragma mark - Render Page from PageViewController
-(void)renderPage {
    //NSString* activityName = @"BookViewController.controller.renderPage:";
    
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
    
    [self.pageController setViewControllers:nil  
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
   // NSString* activityName = @"BookViewControllerPageView.viewWillAppear:";
    [super viewWillAppear:animated];
   
    [self renderPage];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
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
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
            [self renderPage];
            
            // Uncomment the below line if you want the pageViewController to move to the new page added
            //pageViewController = [self viewControllerAtIndex:[newIndexPath row]];
            
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
  //  NSString* activityName = @"BookViewControllerPageView.controller.onEnumerateComplete:";
    
    //[self renderPage];
    
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
