//
//  DraftViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DraftViewController.h"
#import "Macros.h"
#import "Page.h"
#import "UIDraftView.h"
#import "CloudEnumeratorFactory.h"
#import "UINotificationIcon.h"
#import "UICameraActionSheet.h"
#import "Photo.h"
#import "User.h"
#import "ContributeViewController.h"
#import "PersonalLogViewController.h"

#define kWIDTH 320
#define kHEIGHT 480
#define kSPACING 0

@implementation DraftViewController
@synthesize pageID              = m_pageID;
@synthesize frc_draft_pages     = __frc_draft_pages;
@synthesize pagedViewSlider     = m_pagedViewSlider;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;

@synthesize tableViewNeedsUpdate    = m_tableViewNeedsUpdate;

@synthesize thumbnailImage      = m_thumbnailImage;
@synthesize fullImage           = m_fullImage;


#pragma mark - Properties
//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_draft_pages {
    NSString* activityName = @"DraftViewController.frc_draft_pages:";
    if (__frc_draft_pages != nil) {
        return __frc_draft_pages;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
    
    //TODO: change this to sort on DATECREATED when the server supports it
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    //add predicate to test for being published
    //TODO: commenting these out temporarily since there are no published pages on the server
    //NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kDRAFT];
    
    //[fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_draft_pages = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_DRAFTVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    
    return __frc_draft_pages;
    
}

#pragma mark - Frames
- (CGRect) frameForSlider {
    return CGRectMake(0, 0, 320, 480);
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

    //flexible space for button spacing
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];    
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        UIBarButtonItem* usernameButton = [[UIBarButtonItem alloc]
                                           initWithTitle:self.loggedInUser.displayname
                                           style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(onUsernameButtonPressed:)];
        [retVal addObject:usernameButton];
    }
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add camera button
    UIBarButtonItem* cameraButton = [[UIBarButtonItem alloc]
                                      initWithImage:[UIImage imageNamed:@"icon-camera2.png"]
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onCameraButtonPressed:)];
    [retVal addObject:cameraButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add bookmark button
    UIBarButtonItem* bookmarkButton = [[UIBarButtonItem alloc]
                                       initWithImage:[UIImage imageNamed:@"icon-ribbon2.png"] 
                                       style:UIBarButtonItemStylePlain 
                                       target:self 
                                       action:@selector(onBookmarkButtonPressed:)];
    [retVal addObject:bookmarkButton];
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        
        //add flexible space for button spacing
        [retVal addObject:flexibleSpace];
        
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
    
    [self.pagedViewSlider initWithWidth:kWIDTH withHeight:kHEIGHT withSpacing:kSPACING useCellIdentifier:@"draft"];
    
    self.pagedViewSlider.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.pageCloudEnumerator = [[CloudEnumeratorFactory instance] enumeratorForPages];
    
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self =  [self commonInit];
        
        //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"page_curled.png"]];
        //self.view.backgroundColor = background;
        //[background release];
        
    }
    return self;
}

- (void)dealloc
{
    [self.pagedViewSlider release];
    [self.frc_draft_pages release];
    [super dealloc];
   
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
    
    // set initial state of parent contollers tableView update observer property to NO
    self.tableViewNeedsUpdate = NO;
}

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location within the frc_draft_pages for the draft with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_draft_pages fetchedObjects];
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
    NSString* activityName = @"DraftViewController.renderPage:";
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
        LOG_DRAFTVIEWCONTROLLER(1,@"%@Could not find page with id: %@ in local store",activityName,self.pageID);
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    //NSString* activityName = @"DraftViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    //render the page ID specified as a parameter
    if (self.pageID != nil && [self.pageID intValue] != 0) {
        //render the page specified by the ID passed in
        [self renderPage];
    }
    else {
        //need to find the latest page
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:nil forAttribute:nil sortBy:DATECREATED sortAscending:NO];
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
    
    // Toolbar: we update the toolbar items each tgime the view controller is shown
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
- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider  
           selectIndex:          (int)                   index {
    
}

- (UIView*) viewSlider:          (UIPagedViewSlider2*)   viewSlider 
     cellForRowAtIndex:          (int)                   index 
             withFrame:          (CGRect)                frame {
    
    //render a page in its own view and return it using the coordinates passed in for its frame
    int count = [[self.frc_draft_pages fetchedObjects]count];
    if (index < count) {    
        UIDraftView* draftView = [[UIDraftView alloc] initWithFrame:frame];
        draftView.navigationController = self.navigationController;
        [self viewSlider:viewSlider configure:draftView forRowAtIndex:index withFrame:frame];
        return draftView;
    }
    else {
        return nil;
    }
    
}

- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider 
             isAtIndex:          (int)                   index 
    withCellsRemaining:          (int)                   numberOfCellsToEnd {
    
    
    NSString* draftTitle = @"Back";
    int count = [[self.frc_draft_pages fetchedObjects]count];
    if (index < count) {
        Page* page  = [[self.frc_draft_pages fetchedObjects]objectAtIndex:index];
        if (page != nil) {
            draftTitle = page.displayname;
        }
        else {
            page  = [[self.frc_draft_pages fetchedObjects]objectAtIndex:0];
        }
        self.pageID = page.objectid;
    }
    
    // Set up navigation bar back button
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:draftTitle
                                                                              style:UIBarButtonItemStyleBordered
                                                                              target:nil
                                                                              action:nil] autorelease];
}


- (void)    viewSlider:          (UIPagedViewSlider2*)   viewSlider
             configure:          (UIView*)               existingCell
         forRowAtIndex:          (int)                   index
             withFrame:          (CGRect)                frame {
    
    int count = [[self.frc_draft_pages fetchedObjects]count];
    if (index < count) {
        Page* page  = [[self.frc_draft_pages fetchedObjects]objectAtIndex:index];
        
        existingCell.frame = frame;
             
        UIDraftView* draftView = (UIDraftView*)existingCell;
        [draftView renderDraftWithID:page.objectid];
    }
}

- (int)   itemCountFor:          (UIPagedViewSlider2*)   viewSlider {
    return [[self.frc_draft_pages fetchedObjects]count];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    NSString* activityName = @"DraftViewController.controller.didChangeObject:";
    if (type == NSFetchedResultsChangeInsert) {
        //insertion of a new draft
        Resource* resource = (Resource*)anObject;
        LOG_DRAFTVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
        [self.pagedViewSlider onNewItemInsertedAt:[newIndexPath row]];
        self.tableViewNeedsUpdate = YES;
    }
}


#pragma mark - Toolbar Button Event Handlers
- (void) onUsernameButtonPressed:(id)sender {
    PersonalLogViewController* personalLogViewController = [PersonalLogViewController createInstance];
    [self.navigationController pushViewController:personalLogViewController animated:YES];
}

- (void) onCameraButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onCameraButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewPhotoWithPageID:self.pageID];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        [contributeViewController release];
    }
}

- (void) onBookmarkButtonPressed:(id)sender {
    
}

#pragma mark - Static Initializers
+ (DraftViewController*) createInstance {
    DraftViewController* draftViewController = [[DraftViewController alloc]initWithNibName:@"DraftViewController" bundle:nil];
    [draftViewController autorelease];
    return draftViewController;
}


@end
