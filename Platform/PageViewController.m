//
//  PageViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PageViewController.h"
#import "Macros.h"
#import "Page.h"
#import "UIPageView.h"
#import "CloudEnumeratorFactory.h"
#import "UINotificationIcon.h"

#define kWIDTH 320
#define kHEIGHT 375
#define kSPACING 0

@implementation PageViewController
@synthesize pageID              = m_pageID;
@synthesize frc_published_pages = __frc_published_pages;
@synthesize pagedViewSlider     = m_pagedViewSlider;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;

#pragma mark - Properties
//this NSFetchedResultsController will query for all published pages
- (NSFetchedResultsController*) frc_published_pages {
    NSString* activityName = @"PageViewController.frc_published_pages:";
    if (__frc_published_pages != nil) {
        return __frc_published_pages;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:self.managedObjectContext];
    
    //TODO: change this to sort on DATECREATED when the server supports it
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    //add predicate to test for being published
     //TODO: commenting these out temporarily since there are no published pages on the server
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@",STATE, kPUBLISHED];
    
   
    
    //[fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
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

#pragma mark - Frames
- (CGRect) frameForSlider {
    return CGRectMake(0, 0, 320, 375);
}

#pragma mark - Navigationbar buttons
- (NSArray*) navigationBarButtonsForViewController {
    //retrurns an array with the navigation bar buttons for this view controller
    return nil;
}

#pragma mark - Toolbar buttons
- (NSArray*) toolbarButtonsForViewController {
    //returns an array with the toolbar buttons for this view controller
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    //add facebook button
    UIBarButtonItem* facebookButton = [[UIBarButtonItem alloc]
                                       initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(onFacebookButtonPressed:)];
    [retVal addObject:facebookButton];
    
    //add twitter button
    UIBarButtonItem* twitterButton = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(onTwitterButtonPressed:)];
    [retVal addObject:twitterButton];

    //add bookmark button
    UIBarButtonItem* bookmarkButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"bkmark" 
                                       style:UIBarButtonItemStylePlain 
                                       target:self 
                                       action:@selector(onBookmarkButtonPressed:)];
    [retVal addObject:bookmarkButton];
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        UINotificationIcon* notificationIcon = [UINotificationIcon notificationIconForPageViewControllerToolbar];
        UIBarButtonItem* notificationBarItem = [[[UIBarButtonItem alloc]initWithCustomView:notificationIcon]autorelease];
        
        [retVal addObject:notificationBarItem];
    }
    

    return retVal;
}

- (id) commonInit {
    // Custom initialization
    self.pageID = nil;
    CGRect frameForSlider = [self frameForSlider];
    self.pagedViewSlider = [[UIPagedViewSlider2 alloc]initWithFrame:frameForSlider];
    self.pagedViewSlider.delegate = self;
    
    self.pagedViewSlider.tableView.pagingEnabled = YES;
    [self.view addSubview:self.pagedViewSlider];
    
    [self.pagedViewSlider initWithWidth:kWIDTH withHeight:kHEIGHT withSpacing:kSPACING useCellIdentifier:@"page"];
    self.pageCloudEnumerator = [[CloudEnumeratorFactory instance] enumeratorForPages];
    
 
       
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self =  [self commonInit];
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [self.pagedViewSlider release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void) renderPage {
    NSString* activityName = @"PageViewController.renderPage:";
    //retrieves and draws the layout for the current page
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* currentPage = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (currentPage != nil) {
        int indexOfPage = [self indexOfPageWithID:self.pageID];
        //we instruct the page view slider to move to the index of the page which is specified
        [self.pagedViewSlider goTo:indexOfPage withAnimation:NO];
    }
    else {
        //error state
        LOG_PAGEVIEWCONTROLLER(1,@"%@Could not find page with id: %@ in local store",activityName,self.pageID);
    }
    
}
- (void) viewWillAppear:(BOOL)animated {
    //NSString* activityName = @"PageViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    //render the page ID specified as a parameter
    if (self.pageID != nil && [self.pageID intValue] != 0) {
        //render the page specified by the ID passed in
        [self renderPage];
    }
    else {
        //need to find the latest page
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:DATEPUBLISHED sortAscending:NO];
        if (page != nil) {
            //local store does contain pages to enumerate
            self.pageID = page.objectid;
            [self renderPage];
        }
        else {
            //empty page store, will need to thow up a progress dialog to show user of download
            [self.pageCloudEnumerator enumerateUntilEnd];
            //TODO: need to make a call to a centrally hosted busy indicator view
        }

    }
    //we update the toolbar items each tgime the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
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

#pragma mark - UIPagedViewSlider2 Delegate Methods
- (void)    viewSlider:         (UIPagedViewSlider2*)   viewSlider  
           selectIndex:        (int)                   index {
    
}

- (UIView*) viewSlider:         (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:          (int)                   index 
             withFrame:          (CGRect)                frame {
    
    //render a page in its own view and return it using the coordinates passed in for its frame
    int count = [[self.frc_published_pages fetchedObjects]count];
    if (index < count) {
        UIPageView* view = [[UIPageView alloc]initWithFrame:frame];
        [self viewSlider:viewSlider configure:view forRowAtIndex:index withFrame:frame];
        return view;
    }
    else {
        return nil;
    }
    
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining: (int)                   numberOfCellsToEnd {
    
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    
    int count = [[self.frc_published_pages fetchedObjects]count];
    if (index < count) {
        Page* page  = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        existingCell.frame = frame;
        UIPageView* pageView = (UIPageView*)existingCell;
        [pageView renderPageWithID:page.objectid];
    }
}



- (int)     itemCountFor:        (UIPagedViewSlider2*)   viewSlider {
    return [[self.frc_published_pages fetchedObjects]count];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //insertion of a new page
        [self.pagedViewSlider onNewItemInsertedAt:[indexPath row]];
    }
    
}

#pragma mark - Event Handlers
- (void) onFacebookButtonPressed:(id)sender {
    
}

- (void) onTwitterButtonPressed:(id)sender {
    
}

- (void) onBookmarkButtonPressed:(id)sender {
    
}
#pragma mark - Static Initializers
+ (PageViewController*) createInstance {
    PageViewController* pageViewController = [[PageViewController alloc]initWithNibName:@"PageViewController" bundle:nil];
    [pageViewController autorelease];
    return pageViewController;
}


@end
