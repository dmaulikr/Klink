//
//  NotificationsViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NotificationsViewController.h"
#import "UINotificationTableViewCell.h"
#import "AuthenticationManager.h"
#import "Macros.h"
#import "Feed.h"
#import "User.h"
#import "DateTimeHelper.h"
#import "FeedTypes.h"
#import "EditorialVotingViewController.h"

#define kNOTIFICATIONTABLEVIEWCELLHEIGHT 73

@implementation NotificationsViewController
@synthesize tbl_notificationsTableView = m_tbl_notificationsTableVIew;
@synthesize frc_notifications   = __frc_notifications;
@synthesize refreshHeader       = m_refreshHeader;
@synthesize refreshNotificationFeedOnDownload = m_refreshNotificationFeedOnDownload;

#pragma mark - Properties
- (NSFetchedResultsController*) frc_notifications {
    NSString* activityName = @"PersonalLogViewController.frc_notifications:";
    
    if (__frc_notifications != nil && 
        [self.authenticationManager isUserAuthenticated]) {
        return __frc_notifications;
    }
    else if (![self.authenticationManager isUserAuthenticated]) {
        __frc_notifications = nil;
        return __frc_notifications;
    }
    else {
        
        ResourceContext* resourceContext = [ResourceContext instance];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:FEED inManagedObjectContext:resourceContext.managedObjectContext];
        
        
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
        
        NSDate* currentDate = [NSDate date];
        double currentDateInSeconds = [currentDate timeIntervalSince1970];
        NSNumber* numDateInSeconds = [NSNumber numberWithDouble:currentDateInSeconds];
        //add predicate to test for unopened feed items    
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@ AND %K>%@",HASOPENED, [NSNumber numberWithBool:NO], USERID,self.authenticationManager.m_LoggedInUserID,DATEEXPIRE,numDateInSeconds];
        
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        controller.delegate = self;
        self.frc_notifications = controller;
        
        
        NSError* error = nil;
        [controller performFetch:&error];
        if (error != nil)
        {
            LOG_PERSONALLOGVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        
        [controller release];
        [fetchRequest release];
        [sortDescriptor release];
        return __frc_notifications;
    }
}

#pragma mark - Instance methods
- (void) markAllDisplayedNotificationsSeen {
    NSArray* notifications = [self.frc_notifications fetchedObjects];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    for (Feed* notification in notifications) {
        notification.hasseen = [NSNumber numberWithBool:YES];
    }
    
    [resourceContext save:YES onFinishCallback:nil];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    //self = [super initWithStyle:style];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup pulldown refresh on tableview
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_notificationsTableView.bounds.size.height, self.tbl_notificationsTableView.bounds.size.width, self.tbl_notificationsTableView.bounds.size.height);
    
    EGORefreshTableHeaderView* erthv = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader = erthv;
    [erthv release];
    
    self.refreshHeader.delegate = self;
    self.refreshHeader.backgroundColor = [UIColor clearColor];
    [self.tbl_notificationsTableView addSubview:self.refreshHeader];
    self.tbl_notificationsTableView.userInteractionEnabled = YES;
    self.tbl_notificationsTableView.delegate = self;
    self.tbl_notificationsTableView.dataSource = self;
    self.tbl_notificationsTableView.allowsSelection = YES;
    [self.refreshHeader refreshLastUpdatedDate];
    
    // Navigation Bar Buttons
    UIBarButtonItem* bi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = bi;
    [bi release];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"NotificationsViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    
    // Set the navigationbar title
    self.navigationItem.title = @"Notifications";
    
    //as soon as we open up, we mark all notifications that are currently
    //open on the screen to be read
    [self markAllDisplayedNotificationsSeen];
    
    //we check to see if this view controller is meant to refresh the feed upon load
    //this is uusually set when the app is being launched in response to a remote notification
    //and this is the view controller which is brought to the front
    if (self.refreshNotificationFeedOnDownload) {
        
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@Refreshing notification feed from cloud",activityName);
        FeedManager* feedManager = [FeedManager instance];
        [feedManager refreshFeedOnFinish:nil];
        
        //we need to clear the application badge icon from the app icon
        UIApplication* application = [UIApplication sharedApplication];
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@Setting application badge number to 0",activityName);
        application.applicationIconBadgeNumber =0;
    }
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
    return [[self.frc_notifications fetchedObjects]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int notificationCount = [[self.frc_notifications fetchedObjects]count];
    if ([indexPath row] < notificationCount) 
    {
        Feed* notification = [[self.frc_notifications fetchedObjects] objectAtIndex:[indexPath row]];
        UINotificationTableViewCell* cell = (UINotificationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:[UINotificationTableViewCell cellIdentifier]];
    
        if (cell == nil) {
            //cell = [[[UINotificationTableViewCell alloc] initWithNotificationID:notification.objectid withStyle:UITableViewCellStyleDefault reuseIdentifier:[UINotificationTableViewCell cellIdentifier]]autorelease];
            cell = [[[UINotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UINotificationTableViewCell cellIdentifier]]autorelease];
            cell.userInteractionEnabled = YES;
        }
        
        // Configure the cell...
        [cell renderNotificationWithID:notification.objectid];
        
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

#define kPOLL   @"poll"

#pragma mark - Table view delegate
-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kNOTIFICATIONTABLEVIEWCELLHEIGHT;
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* activityName = @"NotificationsViewController.didSelectRowAtIndexPath:";
    //need to get the notification object
    int index = [indexPath row];
    int feedCount = [[self.frc_notifications fetchedObjects]count];
    
    if (feedCount > 0 && index < feedCount) {
        Feed* notification = [[self.frc_notifications fetchedObjects]objectAtIndex:index];
        
        
        //now we determine which type of notification it is, and navigate to the appropriate view controller
        if ([notification.type intValue] == kEDITORIAL_BOARD_VOTE_STARTED) {
            //when the vote has started, we launch into the editorial vote view in normal view with t
            //3 poll objects there
            
            //we need to mark the notification object as having been read
            //TODO: uncomment the below when testing has sufficiently progressed
//            notification.hasopened = [NSNumber numberWithBool:YES];
//            ResourceContext* resourceContext = [ResourceContext instance];
//            [resourceContext save:YES onFinishCallback:nil];
            
            NSArray* feedObjects = notification.feeddata;
            NSNumber* pollID = nil;
            
            for (FeedData* fd in feedObjects) {
                if ([fd.key isEqualToString:kPOLL]) {
                    pollID = fd.objectid;
                    break;
                }
            }
            
            if (pollID != nil) {
                EditorialVotingViewController* editorialBoardViewController = [EditorialVotingViewController createInstanceForPoll:pollID];
                [self.navigationController pushViewController:editorialBoardViewController animated:YES];
               
            }
            else {
                //error case
                LOG_NOTIFICATIONVIEWCONTROLLER(1, @"%@Could not find poll object associated with notification %@",activityName,notification.objectid);
            }
        }
    }
    
}

- (void) dealloc {
    self.frc_notifications = nil;
    [super dealloc];
}


#pragma mark - NSFetchedResultsControllerDelegate 
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject 
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //new notification has been downloaded
        
        [self.tbl_notificationsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tbl_notificationsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager instance];
    
    Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onFeedFinishedRefresh:)];
    [feedManager refreshFeedOnFinish:callback];
    [callback release];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager instance];
    return [feedManager isRefreshingFeed];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Async Callback Handlers
- (void) onFeedFinishedRefresh:(CallbackResult*)result {
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_notificationsTableView];
}


#pragma mark - Static Initializers
+ (NotificationsViewController*)createInstance {
    NotificationsViewController* instance = [[[NotificationsViewController alloc]initWithNibName:@"NotificationsViewController" bundle:nil]autorelease];
    instance.refreshNotificationFeedOnDownload = NO;
    return instance;
}

+ (NotificationsViewController*)createInstanceAndRefreshFeedOnAppear {
    NotificationsViewController* instance = [[[NotificationsViewController alloc]initWithNibName:@"NotificationsViewController" bundle:nil]autorelease];
    instance.refreshNotificationFeedOnDownload = YES;
    return instance;
}

@end
