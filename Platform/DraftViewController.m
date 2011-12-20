//
//  DraftViewController2.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DraftViewController.h"
#import "Macros.h"
#import "UIDraftTableViewCell.h"
#import "DateTimeHelper.h"
#import "CloudEnumeratorFactory.h"
#import "AuthenticationManager.h"
#import "UINotificationIcon.h"
#import "UICameraActionSheet.h"
#import "Types.h"
#import "Attributes.h"
#import "Photo.h"
#import "Page.h"
#import "User.h"
#import "FullScreenPhotoViewController.h"
#import "ContributeViewController.h"
#import "ProfileViewController.h"

#define kPAGEID @"pageid"
#define kDRAFTTABLEVIEWCELLHEIGHT_TOP 320
#define kDRAFTTABLEVIEWCELLHEIGHT_LEFTRIGHT 115

@implementation DraftViewController
@synthesize frc_photos = __frc_photos;
@synthesize pageID = m_pageID;
@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize lbl_deadline = m_lbl_deadline;
@synthesize deadline = m_deadline;
@synthesize tbl_draftTableView = m_tbl_draftTableView;
@synthesize cloudPhotoEnumerator = m_cloudPhotoEnumerator;
@synthesize refreshHeader = m_refreshHeader;


#pragma mark - Deadline Date Timers
- (void) timeRemaining:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    NSTimeInterval remaining = [self.deadline timeIntervalSinceDate:now];
    self.lbl_deadline.text = [NSString stringWithFormat:@"deadline: %@", [DateTimeHelper formatTimeInterval:remaining]];
}

#pragma mark - Properties

- (NSFetchedResultsController*) frc_photos {
    NSString* activityName = @"UIDraftViewController.frc_photos:";
    
    if (__frc_photos != nil) {
        return __frc_photos;
    }
    else {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:resourceContext.managedObjectContext];
        
        NSSortDescriptor* sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:NUMBEROFVOTES ascending:NO];
        NSSortDescriptor* sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
        
        NSMutableArray* sortDescriptorArray = [NSMutableArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
        
        //add predicate to gather only photos for this pageID    
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", THEMEID, self.pageID];
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:sortDescriptorArray];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        controller.delegate = self;
        self.frc_photos = controller;
        
        
        NSError* error = nil;
        [controller performFetch:&error];
        if (error != nil)
        {
            LOG_UIDRAFTVIEW(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        
        [sortDescriptor1 release];
        [sortDescriptor2 release];
        [controller release];
        [fetchRequest release];
        
        return __frc_photos;
    }
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
        [usernameButton release];
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
    [cameraButton release];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add bookmark button
    UIBarButtonItem* bookmarkButton = [[UIBarButtonItem alloc]
                                       initWithImage:[UIImage imageNamed:@"icon-ribbon2.png"] 
                                       style:UIBarButtonItemStylePlain 
                                       target:self 
                                       action:@selector(onBookmarkButtonPressed:)];
    [retVal addObject:bookmarkButton];
    [bookmarkButton release];
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        
        //add flexible space for button spacing
        [retVal addObject:flexibleSpace];
        
        UINotificationIcon* notificationIcon = [UINotificationIcon notificationIconForPageViewControllerToolbar];
        UIBarButtonItem* notificationBarItem = [[[UIBarButtonItem alloc]initWithCustomView:notificationIcon]autorelease];
        
        [retVal addObject:notificationBarItem];
    }
    
    [flexibleSpace release];
    return retVal;
}


#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    
    // resister callbacks for change events
    Callback* newCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaption:)];
    Callback* newPhotoVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhotoVote:)];
    Callback* newCaptionVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaptionVote:)];
    
    [self.eventManager registerCallback:newCaptionCallback forSystemEvent:kNEWCAPTION];
    [self.eventManager registerCallback:newPhotoVoteCallback forSystemEvent:kNEWPHOTOVOTE];
    [self.eventManager registerCallback:newCaptionVoteCallback forSystemEvent:kNEWCAPTIONVOTE];
    
    [newCaptionCallback release];
    [newPhotoVoteCallback release];
    [newCaptionVoteCallback release];
    
    
     
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.tbl_draftTableView = nil;
    self.frc_photos = nil;
    self.pageID = nil;
    //[self.tbl_draftTableView release];
    //[self.frc_photos release];
    //[self.pageID release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
  
    

    
    // setup pulldown refresh on tableview
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_draftTableView.bounds.size.height, self.tbl_draftTableView.bounds.size.width, self.tbl_draftTableView.bounds.size.height);
    
    EGORefreshTableHeaderView* erthv = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader = erthv;
    [erthv release];
    
    self.refreshHeader.delegate = self;
    self.refreshHeader.backgroundColor = [UIColor clearColor];
    [self.tbl_draftTableView addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
    
    [self.lbl_draftTitle setFont:[UIFont fontWithName:@"TravelingTypewriter" size:24]];
    [self.lbl_deadline setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    
    }

- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"DraftViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* draft = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    if (draft != nil) {
        
        self.lbl_draftTitle.text = draft.displayname;
        
        // Show time remaining on draft
        self.lbl_deadline.text = @"";
        self.deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timeRemaining:)
                                       userInfo:nil
                                        repeats:YES];
        
      
        int numPhotosInDraft = [draft.numberofphotos intValue];
        int numPhotosInStore = [[self.frc_photos fetchedObjects]count];
        
        if (numPhotosInStore < numPhotosInDraft) {
            LOG_DRAFTVIEWCONTROLLER(0, @"%@Number of photos in store (%d) is less than number of photos on draft (%d), enumerating from cloud",activityName,numPhotosInStore,numPhotosInDraft);
            self.cloudPhotoEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
            self.cloudPhotoEnumerator.delegate = self;
            
            [self.cloudPhotoEnumerator enumerateUntilEnd:nil];
        }
        
        
        
    }

    
    
    // Toolbar: we update the toolbar items each time the view controller is shown
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


#pragma mark -
#pragma mark Table View Delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] == 0) {
        // leading draft, show version of draft table view cell for the leading draft
        return kDRAFTTABLEVIEWCELLHEIGHT_TOP;
    }
    else {
        // else, show version of draft table view cell with image on the right
        return kDRAFTTABLEVIEWCELLHEIGHT_LEFTRIGHT;
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    //[self.tbl_draftTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
    
    Photo* selectedPhoto = [[self.frc_photos fetchedObjects] objectAtIndex:[indexPath row]];
    
    // Set up navigation bar back button with draft title
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:page.displayname
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    
    FullScreenPhotoViewController* photoViewController = [FullScreenPhotoViewController createInstanceWithPageID:selectedPhoto.themeid withPhotoID:selectedPhoto.objectid];
    
    [self.navigationController pushViewController:photoViewController animated:YES];
  
}


#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.frc_photos fetchedObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int photoCount = [[self.frc_photos fetchedObjects]count];
    if ([indexPath row] < photoCount) 
    {
        Photo* photo = [[self.frc_photos fetchedObjects] objectAtIndex:[indexPath row]];
        
        NSString* reusableCellIdentifier = nil;
        
        if ([indexPath row] == 0) {
            // leading draft, show version of draft table view cell for the leading draft
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierTop];
        }
        else if ([indexPath row] % 2) {
            // row is odd, show version of draft table view cell with image on the left
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierLeft];
        }
        else {
            // row is even, show version of draft table view cell with image on the right
            reusableCellIdentifier = [UIDraftTableViewCell cellIdentifierRight];
        }
        
        UIDraftTableViewCell* cell = (UIDraftTableViewCell*) [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier];
        
        if (cell == nil) 
        {
            cell = [[[UIDraftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellIdentifier]autorelease];
        }
        
        [cell renderWithPhotoID:photo.objectid];
        return cell;
    }
    else {
        return nil;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_draftTableView endUpdates];
    [self.tbl_draftTableView reloadData];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_draftTableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject 
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //new photo has been downloaded
        [self.tbl_draftTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        //[self.tbl_draftTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
      
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tbl_draftTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        //[self.tbl_draftTableView reloadData];
    }
}

#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    self.cloudPhotoEnumerator = [CloudEnumerator enumeratorForPhotos:self.pageID];
    self.cloudPhotoEnumerator.delegate = self;
    
    [self.cloudPhotoEnumerator enumerateUntilEnd:nil];
    
//    self.cloudPhotoEnumerator = nil;
//    CloudEnumeratorFactory* cloudEnumeratorFactory = [CloudEnumeratorFactory instance];
//    
//    self.cloudPhotoEnumerator = [cloudEnumeratorFactory enumeratorForPhotos:self.pageID];
//    self.cloudPhotoEnumerator.delegate = self;
//    [self.cloudPhotoEnumerator enumerateUntilEnd:nil];
    
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    if (self.cloudPhotoEnumerator != nil) {
        return [self.cloudPhotoEnumerator isLoading];
    }
    else {
        return NO;
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    //we tell the ego fresh header that we've stopped loading items
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_draftTableView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    [self.tbl_draftTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f)];
}


#pragma mark - Callback Event Handlers
- (void) onNewCaption:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
}

- (void) onNewPhotoVote:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
}

- (void) onNewCaptionVote:(CallbackResult*)result {
    [self.tbl_draftTableView reloadData];
}

#pragma mark - Toolbar Button Event Handlers
- (void) onUsernameButtonPressed:(id)sender {
    //PersonalLogViewController* personalLogViewController = [PersonalLogViewController createInstance];
    //[self.navigationController pushViewController:personalLogViewController animated:YES];
    
    ProfileViewController* profileViewController = [ProfileViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
   
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
+ (DraftViewController*)createInstanceWithPageID:(NSNumber*)pageID {
    DraftViewController* draftViewController = [[DraftViewController alloc]initWithNibName:@"DraftViewController" bundle:nil];
    draftViewController.pageID = pageID;
    [draftViewController autorelease];
    return draftViewController;
}

+ (DraftViewController*)createInstanceWithPageID:(NSNumber *)pageID 
                                     withPhotoID:(NSNumber *)photoID 
                                   withCaptionID:(NSNumber *)captionID 
{
    //this constructor called by notification view controller to
    //create a draft view controller for the page,photo and caption specified
    DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:pageID];
    return draftViewController;
}
@end
