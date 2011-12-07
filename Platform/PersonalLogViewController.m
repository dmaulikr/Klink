//
//  PersonalLogViewController.m
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PersonalLogViewController.h"
#import "Macros.h"
#import "Feed.h"
#import "UINotificationTableViewCell.h"
#import "User.h"
#import "DateTimeHelper.h"
#import "AuthenticationManager.h"


#define kRefreshHeaderHeight    100
@implementation PersonalLogViewController
@synthesize lbl_title           = m_lbl_title;
@synthesize tbl_notifications   = m_tbl_notifications;
@synthesize frc_notifications   = __frc_notifications;
@synthesize lbl_since           = m_lbl_since;
@synthesize lbl_numphotoslw     = m_lbl_numphotoslw;
@synthesize lbl_numcaptionslw   = m_lbl_numcaptionslw;
@synthesize lbl_currentLevel    = m_lbl_currentLevel;
@synthesize refreshHeader       = m_refreshHeader;
@synthesize refreshNotificationFeedOnDownload   =m_refreshNotificationFeedOnDownload;

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
        
        //add predicate to test for unopened feed items    
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@",HASOPENED, [NSNumber numberWithBool:NO], USERID,self.authenticationManager.m_LoggedInUserID];
        
        
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
        
        return __frc_notifications;
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"page_curled.png"]];
        self.view.backgroundColor = background;
        [background release];
        
    }
    return self;
}

- (void)dealloc
{
    [self.frc_notifications release];
    [self.lbl_title release];
    [self.tbl_notifications release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - Instance methods
- (void) markAllDisplayedNotificationsSeen {
    NSArray* notifications = [self.frc_notifications fetchedObjects];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    
    for (Feed* notification in notifications) {
        notification.hasseen = [NSNumber numberWithBool:YES];
    }
    
    [resourceContext save:YES onFinishCallback:nil];
    
    //we set the badge number to 0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_notifications.bounds.size.height, self.tbl_notifications.bounds.size.width, self.tbl_notifications.bounds.size.height);
    self.refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader.delegate = self;
    [self.tbl_notifications addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    NSString* activityName = @"PersonalLogViewController.viewWillAppear:";
    [super viewWillAppear:YES];
    
    // hide toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    //as soon as we open up, we mark all notifications that are currently
    //open on the screen to be read
    [self markAllDisplayedNotificationsSeen];
    
    
    if ([self.authenticationManager isUserAuthenticated]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        User* user = (User*)[resourceContext resourceWithType:USER withID:self.authenticationManager.m_LoggedInUserID];
        self.lbl_title.text = [NSString stringWithFormat:@"%@'s Log",user.displayname];
        
        NSDateFormatter* format = [[NSDateFormatter alloc]init];
        [format setDateFormat:@"MMM dd, yyyy"];
        
        if ([user.iseditor boolValue]) {
            self.lbl_currentLevel.text = @"editor";
            NSDate* dateBecameEditor =  [DateTimeHelper parseWebServiceDateDouble:user.datebecameeditor];
            self.lbl_since.text = [format stringFromDate:dateBecameEditor];
        }
        else {
            self.lbl_currentLevel.text = @"lack";
            NSDate* dateJoined = [DateTimeHelper parseWebServiceDateDouble:user.datecreated];
            self.lbl_since.text = [format stringFromDate:dateJoined];
        }
        
        self.lbl_numcaptionslw.text = [user.numberofcaptionslw stringValue];
        self.lbl_numphotoslw.text = [user.numberofphotoslw stringValue];
        
    }
    
    //we check to see if this view controller is meant to refresh the feed upon load
    if (self.refreshNotificationFeedOnDownload) {
        
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@Refreshing notification feed from cloud",activityName);
        FeedManager* feedManager = [FeedManager instance];
        [feedManager refreshFeedOnFinish:nil];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // show toolbar
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITableViewDelegate methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 131;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UITableDataSource methods
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int notificationCount = [[self.frc_notifications fetchedObjects]count];
    if ([indexPath row] < notificationCount) 
    {
        Feed* notification = [[self.frc_notifications fetchedObjects] objectAtIndex:[indexPath row]];
        UINotificationTableViewCell* cell = (UINotificationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:[UINotificationTableViewCell cellIdentifier]];
        
        if (cell == nil) 
        {
            cell = [[[UINotificationTableViewCell alloc] initWithNotificationID:notification.objectid withStyle:UITableViewCellStyleDefault reuseIdentifier:[UINotificationTableViewCell cellIdentifier]]autorelease];
        }
        
        [cell renderNotificationWithID:notification.objectid];
        return cell;
    }
    else {
        return nil;
    }
}

- (int) tableView:(UITableView *)tableView 
numberOfRowsInSection:(NSInteger)section 
{
    return [[self.frc_notifications fetchedObjects]count];
}

#pragma mark - NSFetchedResultsControllerDelegate 
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject 
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //new notification has been downloaded
        
        [self.tbl_notifications insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tbl_notifications deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager instance];
    
    Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onFeedFinishedRefresh:)];
    [feedManager refreshFeedOnFinish:callback];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager instance];
    return [feedManager isRefreshingFeed];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - Async Callback Handlers
- (void) onFeedFinishedRefresh:(CallbackResult*)result {
     [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_notifications];
}


#pragma mark - Static Initializers
+ (PersonalLogViewController*)createInstance {
    PersonalLogViewController* instance = [[[PersonalLogViewController alloc]initWithNibName:@"PersonalLogViewController" bundle:nil]autorelease];
    instance.refreshNotificationFeedOnDownload = NO;
    return instance;
    
}

+ (PersonalLogViewController*)createInstanceAndRefreshFeedOnAppear {
    PersonalLogViewController* instance = [[[PersonalLogViewController alloc]initWithNibName:@"PersonalLogViewController" bundle:nil]autorelease];
    instance.refreshNotificationFeedOnDownload = YES;
    return instance;
    
}
@end
