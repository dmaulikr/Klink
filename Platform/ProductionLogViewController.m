//
//  ProductionLogViewController2.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProductionLogViewController.h"
#import "UIProductionLogTableViewCell.h"
#import "Macros.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DraftViewController.h"
#import "PageViewController.h"
#import "UINotificationIcon.h"
#import "PersonalLogViewController.h"
#import "CloudEnumeratorFactory.h"
#import "DateTimeHelper.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"


#define kPHOTOID @"photoid"
#define kCELLID @"cellid"
#define kCELLTITLE @"celltitle"

@implementation ProductionLogViewController
@synthesize tbl_productionTableView     = m_tbl_productionTableView;
@synthesize frc_draft_pages             = __frc_draft_pages;
@synthesize productionTableViewCell     = m_productionTableViewCell;
@synthesize lbl_numDraftsTotal          = m_lbl_numDraftsTotal;
@synthesize lbl_numDraftsClosing        = m_lbl_numDraftsClosing;
@synthesize cloudDraftEnumerator        = m_cloudDraftEnumerator;
@synthesize refreshHeader               = m_refreshHeader;
#pragma mark - Properties
//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_draft_pages {
    NSString* activityName = @"ProductionLogViewController.frc_draft_pages:";
    if (__frc_draft_pages != nil) {
        return __frc_draft_pages;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    //add predicate to test for being published
    //TODO: commenting these out temporarily since there are no published pages on the server
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kDRAFT];
    
    [fetchRequest setPredicate:predicate];
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
        LOG_PRODUCTIONLOGVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    
    return __frc_draft_pages;
    
}

- (void) updateDraftCounterLabels {
    int numDraftsTotal = [[self.frc_draft_pages fetchedObjects]count];
    self.lbl_numDraftsTotal.text = [NSString stringWithFormat:@"%d", numDraftsTotal];
    
    //Page* draft = [[Page alloc]init];
    
    int numDraftsClosing = 0;
    NSDate* now = [NSDate date];
    NSDate* deadline = [[NSDate alloc] init];
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    NSTimeInterval draftExpirySetting = [settings.page_draftexpiry_seconds doubleValue];
    
    for (int i = 0; i < numDraftsTotal; i++) {
        Page* draft = [[self.frc_draft_pages fetchedObjects]objectAtIndex:i];
        deadline = [DateTimeHelper parseWebServiceDateDouble:draft.datedraftexpires];
        NSTimeInterval deadlineIntervalRemaining = [deadline timeIntervalSinceDate:now];
        if ((deadlineIntervalRemaining < draftExpirySetting) && (deadlineIntervalRemaining > 0)) {
            numDraftsClosing++;
        }
    }
    
    self.lbl_numDraftsClosing.text = [NSString stringWithFormat:@"%d", numDraftsClosing];
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
    
    //add draft button
    UIBarButtonItem* draftButton = [[UIBarButtonItem alloc]
                                     initWithImage:[UIImage imageNamed:@"icon-newPage.png"]
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(onDraftButtonPressed:)];
    [retVal addObject:draftButton];
    
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

#pragma mark - Initializers
- (id) commonInit {
    //common setup for the view controller
    self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
    self.cloudDraftEnumerator.delegate = self;
        return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"page_curled.png"]];
        //self.view.backgroundColor = background;
        //[background release];
        
        //self.tbl_productionTableView.separatorColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"tableviewcell_separator_scetched.png"]];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_productionTableView.bounds.size.height, self.tbl_productionTableView.bounds.size.width, self.tbl_productionTableView.bounds.size.height);
    self.refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader.delegate = self;
    [self.tbl_productionTableView addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
    
    self.lbl_numDraftsTotal.text = [NSString stringWithFormat:@"%d", [self.tbl_productionTableView numberOfRowsInSection:0]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_productionTableView = nil;
    self.productionTableViewCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"ProductionLogViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    

    
    //here we check to see how many items are in the FRC, if it is 0,
    //then we initiate a query against the cloud.
    int count = [[self.frc_draft_pages fetchedObjects] count];
    if (count == 0) {
        //there are no objects in local store, update from cloud
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@No local drafts found, initiating query against cloud",activityName);
        [self.cloudDraftEnumerator enumerateUntilEnd];
    }
    // Update draft counter labels at the top of the view
    [self updateDraftCounterLabels];

    // Toolbar: we update the toolbar items each tgime the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.frc_draft_pages fetchedObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int draftCount = [[self.frc_draft_pages fetchedObjects]count];
    
    if ([indexPath row] < draftCount) {
        Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
        
        UIProductionLogTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UIProductionLogTableViewCell cellIdentifier]];
        if (cell == nil) {
            cell = [[[UIProductionLogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UIProductionLogTableViewCell cellIdentifier]] autorelease];
        }
        
        [cell renderDraftWithID:draft.objectid];
        return cell;
    }
    else {
        return nil;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Toolbar Button Event Handlers
- (void) onUsernameButtonPressed:(id)sender {
    PersonalLogViewController* personalLogViewController = [PersonalLogViewController createInstance];
    [self.navigationController pushViewController:personalLogViewController animated:YES];
}

- (void) onDraftButtonPressed:(id)sender {
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onDraftButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewDraft];
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

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Set up navigation bar back button
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Production Log"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    
    DraftViewController* draftViewController = [[DraftViewController alloc] initWithNibName:@"DraftViewController" bundle:nil];
    
    Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
    draftViewController.pageID = draft.objectid;
    
    [self.navigationController pushViewController:draftViewController animated:YES];
    [draftViewController release];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"ProductionLogViewController.controller.didChangeObject:";
    if (type == NSFetchedResultsChangeInsert) {
        //insertion of a new page
        Resource* resource = (Resource*)anObject;
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@",activityName,resource.objecttype,resource.objectid);
        [self.tbl_productionTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tbl_productionTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        // Update draft counter labels at the top of the view
        [self updateDraftCounterLabels];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tbl_productionTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        // Update draft counter labels at the top of the view
        [self updateDraftCounterLabels];
    }
}

#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    self.cloudDraftEnumerator = nil;
    CloudEnumeratorFactory* cloudEnumeratorFactory = [CloudEnumeratorFactory instance];
    
    self.cloudDraftEnumerator = [cloudEnumeratorFactory enumeratorForDrafts];
    self.cloudDraftEnumerator.delegate = self;
    [self.cloudDraftEnumerator enumerateUntilEnd];

}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    if (self.cloudDraftEnumerator != nil) {
        return [self.cloudDraftEnumerator isLoading];
    }
    else {
        return NO;
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete {
    //we tell the ego fresh header that we've stopped loading items
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_productionTableView];
}

@end
