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
#import "DraftViewController.h"
#import "FullScreenPhotoViewController.h"
#import "BookViewControllerBase.h"
#import "ProfileViewController.h"

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
        if ([notification.hasseen boolValue] != YES) {
            notification.hasseen = [NSNumber numberWithBool:YES];
        }
    }
    
    [resourceContext save:YES onFinishCallback:nil trackProgressWith:nil];
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
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                    target:self
                                    action:@selector(onDoneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon-profile.png"]
                                   //initWithTitle:@"Profile"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(onProfileButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
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
    
       
    //we count the number of notifications
    int count = [[self.frc_notifications fetchedObjects]count];
    
    //we check to see if this view controller is meant to refresh the feed upon load
    //this is uusually set when the app is being launched in response to a remote notification
    //and this is the view controller which is brought to the front
    if (self.refreshNotificationFeedOnDownload ||
        count == 0) {
        
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@Refreshing notification feed from cloud",activityName);
        FeedManager* feedManager = [FeedManager instance];
        [feedManager refreshFeedOnFinish:nil];
        
       
    }
    
    //we need to clear the application badge icon from the app icon
    UIApplication* application = [UIApplication sharedApplication];
    LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@Setting application badge number to 0",activityName);
    application.applicationIconBadgeNumber =0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //if the user is not logged in, close the view immediately
    if (![self.authenticationManager isUserAuthenticated]) {
        // user is not, or is no longer authenticated, dismiss notifications view immediately
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        //as soon as we open up, we mark all notifications that are currently
        //open on the screen to be read
        //we execute this on a background thread
        [self performSelectorInBackground:@selector(markAllDisplayedNotificationsSeen) withObject:nil];
        
    }

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
        [cell renderNotificationWithID:notification.objectid linkClickTarget:self linkClickSelector:@selector(onResourceLinkClick:)];
        
        return cell;
    }
    else {
        return nil;
    }
}

- (void) onResourceLinkClick:(NSNumber*)objectid {
    ProfileViewController* profileViewController = [ProfileViewController createInstanceForUser:objectid];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
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
#define kCAPTION    @"caption"
#define kPHOTO      @"photo"
#define kPAGE       @"page"
#define kDRAFT      @"draft"
#define kUSER       @"user"
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



- (void) processClickOfNewVoteNotification:(Feed*)notification {
    NSString* activityName = @"NotificationsViewController.processClickOfNewVoteNotification:";
    NSArray* feedObjects = notification.feeddata;
    NSNumber* pageID = nil;
    NSNumber* photoID = nil;
    NSNumber* captionID = nil;
    
    //we retrieve the values for the above variables by iterating
    //through the feedObjects array
    for (FeedData* fd in feedObjects) {
        if ([fd.key isEqualToString:kPAGE])
        {
            pageID = fd.objectid;
        }
        else if ([fd.key isEqualToString:kPHOTO]) {
            photoID = fd.objectid;
        }
        else if ([fd.key isEqualToString:kCAPTION]) {
            captionID = fd.objectid;
        }
    }
    
    //at this point we now have the ids of all the objects we need
    //to properly render the draft
    LOG_NOTIFICATIONVIEWCONTROLLER(0, @"%@Retrieved PageID:%@, PhotoID:%@, CaptionID:%@ for new caption vote notification",activityName,pageID,photoID,captionID);
    
    FullScreenPhotoViewController* fullScreenController = [FullScreenPhotoViewController createInstanceWithPageID:pageID withPhotoID:photoID withCaptionID:captionID];
    [self.navigationController pushViewController:fullScreenController animated:YES];
}



- (void) processClickOfNewCaptionNotification:(Feed*)notification {
     //this method has the same logic as the one above it
    [self processClickOfNewVoteNotification:notification];
    
    
}

- (void) processGenericFullscreenNotification:(Feed*)notification {
    //this method will simply call the exisiting method which performs same task
    [self processClickOfNewVoteNotification:notification];
}

- (void) processClickOfNewPhotoNotification:(Feed*)notification {
    //this method has the same logic as the one 2 above it
    [self processClickOfNewVoteNotification:notification];
}

- (void) processDraftLeaderChangedNotification:(Feed*)notification {
    [self processClickOfNewVoteNotification:notification];
}


//opens the draft view
- (void) processClickOfDraftSubmittedToEditorsNotification:(Feed*)notification {
    //on click this method will move to the draftview controller for this specified page
    NSString* activityName = @"NotificationsViewController.processClickOfNewVoteNotification:";
    NSArray* feedObjects = notification.feeddata;
    NSNumber* pageID = nil;
    
    for (FeedData* fd in feedObjects) {
        if ([fd.key isEqualToString:kDRAFT])
        {
            pageID = fd.objectid;
        }
    }
       LOG_NOTIFICATIONVIEWCONTROLLER(0, @"%@Retrieved PageID:%@ draft submission to editorial board notification",activityName,pageID);
    
    //we have th page id, now we launch the draftviewcontroller for this page
    DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:pageID];
    [self.navigationController pushViewController:draftViewController animated:YES];

}

- (void) processGenericDraftNotification:(Feed*)notification {
    //generic handler for draft notifications
    //we just callt he method above as it already does it
    [self processClickOfDraftSubmittedToEditorsNotification:notification];
}


- (void) processClickOfEditorialBoardVotingBegin:(Feed*)notification {
    NSString* activityName = @"NotificationViewController.processClickOfEditorialBoardVotingBegin:";
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
        
        // Modal naviation
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:editorialBoardViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        
    }
    else {
        //error case
        LOG_NOTIFICATIONVIEWCONTROLLER(1, @"%@Could not find poll object associated with notification %@",activityName,notification.objectid);
    }
    
}

- (void) processGenericEditorialBoardPostVoteNotification:(Feed*)notification {
    //will display the editorial board view, designed to show the post-vote scene for the user
    
    //we will simply call processClickOfEditorialBoardVotingBegin message
    [self processClickOfEditorialBoardVotingBegin:notification];
}

- (void) processGenericEditorialBoardNotification:(Feed*)notification {
    [self processClickOfEditorialBoardVotingBegin:notification];
}

- (void) processClickOfEditorialBoardVotingEnding:(Feed*)notification 
{
    //this method opens up the same viewcontroller that is used for the editing process
    [self processClickOfEditorialBoardVotingBegin:notification];
    
}


- (void) processClickOfDraftPublishedNotification:(Feed*)notification {
    //this method will open up the BookViewController to the specified pageID
    NSString* activityName = @"NotificationsViewController.processClickOfDraftPublishedNotification:";
    
    NSArray* feedObjects = notification.feeddata;
    NSNumber* pageID = nil;
    
    for (FeedData* fd in feedObjects) {
        if ([fd.key isEqualToString:kPAGE])
        {
            pageID = fd.objectid;
        }
    }
    LOG_NOTIFICATIONVIEWCONTROLLER(0, @"%@Retrieved PageID:%@ that was published notification",activityName,pageID);
    
    //we launch the BookViewController and open it up to the page we specified
    BookViewControllerBase* bookViewController = [BookViewControllerBase createInstanceWithPageID:pageID];
    //TODO: need to implement proper logic in bookviewcontroller to open up to a specific page
    [self.navigationController pushViewController:bookViewController animated:NO];
}

- (void) processGenericBookNotification:(Feed*)notification {
    //we just call the method above and assume it works
    [self processClickOfDraftPublishedNotification:notification];
}

- (void) processClickOfDraftExpired:(Feed*)notification {
    //this method is the same as processClickOfDraftSubmittedToEditorNotification
    [self processClickOfDraftPublishedNotification:notification];
}

- (void) processClickOfPromotionToEditorNotification:(Feed*)notification 
{
        //will open up the user profile page for the user
    ProfileViewController* profileViewController = [ProfileViewController createInstance];
    //[self.navigationController pushViewController:profileViewController animated:NO];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

- (void) processGenericUserNotification:(Feed*)notification {
    //generic notification handler for user notifications, will open up the user feed    
    NSNumber* userID = nil;
    NSArray* feedObjects = notification.feeddata;
    
    //we cycle through the parameters and find the user id
    for (FeedData* fd in feedObjects) {
        if ([fd.key isEqualToString:kUSER])
        {
            userID = fd.objectid;
        }
    }
    
    //open the user profile view
    ProfileViewController* profileViewController = [ProfileViewController createInstanceForUser:userID];
    [self.navigationController pushViewController:profileViewController animated:NO];
}

- (void) processClickOfDemotionFromEditorNotification:(Feed*)notification
{
    [self processClickOfPromotionToEditorNotification:notification];
}

- (void) processClickOfDraftNotPublishedNotification:(Feed*)notification {
    //we will open up into the voting view
    [self processClickOfEditorialBoardVotingBegin:notification];
}

- (void) processClickOfDraftEditorialBoardNoResult:(Feed*)notification {
    [self processClickOfEditorialBoardVotingBegin:notification];
}



- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* activityName = @"NotificationsViewController.didSelectRowAtIndexPath:";
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //need to get the notification object
    int index = [indexPath row];
    int feedCount = [[self.frc_notifications fetchedObjects]count];
    
    if (feedCount > 0 && index < feedCount) {
        Feed* notification = [[self.frc_notifications fetchedObjects]objectAtIndex:index];
        
        
        //now we determine which type of notification it is, and navigate to the appropriate view controller
//        if ([notification.type intValue] == kEDITORIAL_BOARD_VOTE_STARTED) {
//            //when the vote has started, we launch into the editorial vote view in normal view with t
//            //3 poll objects there
//            
//            //we need to mark the notification object as having been read
//            //TODO: uncomment the below when testing has sufficiently progressed
////            notification.hasopened = [NSNumber numberWithBool:YES];
////            ResourceContext* resourceContext = [ResourceContext instance];
////            [resourceContext save:YES onFinishCallback:nil];
//            
//            NSArray* feedObjects = notification.feeddata;
//            NSNumber* pollID = nil;
//            
//            for (FeedData* fd in feedObjects) {
//                if ([fd.key isEqualToString:kPOLL]) {
//                    pollID = fd.objectid;
//                    break;
//                }
//            }
//            
//            if (pollID != nil) {
//                EditorialVotingViewController* editorialBoardViewController = [EditorialVotingViewController createInstanceForPoll:pollID];
//                
//                // Modal naviation
//                UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:editorialBoardViewController];
//                navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//                
//                [self presentModalViewController:navigationController animated:YES];
//                
//                [navigationController release];
//            }
//            else {
//                //error case
//                LOG_NOTIFICATIONVIEWCONTROLLER(1, @"%@Could not find poll object associated with notification %@",activityName,notification.objectid);
//            }
//
//            [self processClickOfEditorialBoardVotingBegin:notification];
//
//        }
//        else if ([notification.type intValue] == kCAPTION_VOTE) 
//        {
//          //someone has voted for this user's caption on a photo
//          //on click, should transition to view of the photo and their caption
//            [self processClickOfNewVoteNotification:notification];  
//        }
//        else if ([notification.type intValue] == kPHOTO_VOTE) 
//        {
//            //someone has voted for this user's photo in a draft
//            //on click should transition to view of the photo and the newest caption
//            [self processClickOfNewVoteNotification:notification];
//        }
//        else if ([notification.type intValue] == kCAPTION_ADDED) 
//        {
//          //a new caption has been added for this user's photo in a draft, sent to photo and draft creator
//            //on click should transition to view of the new caption and photo
//            [self processClickOfNewCaptionNotification:notification];
//        }
//        else if ([notification.type intValue] == kDRAFT_SUBMITTED_TO_EDITORS) 
//        {
//            //raised when a draft has expired and been submitted to the editorial board for voting
//            //sent to: creator of draft, and the users of the photo and caption that
//            //are the highest voted in the draft
//            [self processClickOfDraftSubmittedToEditorsNotification:notification];
//        }
//        else if ([notification.type intValue] == kDRAFT_PUBLISHED ) 
//        {
//            //raised when a draft has been published in the book
//            //sent to: creator of draft, creator of photo, creator of caption
//            //on click should open page in book to the page published
//            [self processClickOfDraftPublishedNotification:notification];
//        }
//        else if ([notification.type intValue] == kEDITORIAL_BOARD_VOTE_ENDED) {
//            [self processClickOfEditorialBoardVotingEnding:notification];
//        }
//        else if ([notification.type intValue] == kDRAFT_EXPIRED) 
//        {
//            //raised when a draft has expired
//            //sent to the creator of draft, creator of photo, creator of caption
//            //on click should open draft 
//            [self processClickOfDraftExpired:notification];
//        }
//        else if ([notification.type intValue] == kPHOTO_ADDED_TO_DRAFT) 
//        {
//            //raised when a new photo has been added to a draft
//            //sent to the creator of the draft, creator of the photo
//            //on click should open up to the newly added photo
//            [self processClickOfNewPhotoNotification:notification];
//        }
//        else if ([notification.type intValue] == kPROMOTION_TO_EDITOR) 
//        {
//            //raised when a user has been promoted
//            //sent to user that has been promoted to editorial board
//            //on click should open up profile page
//            [self processClickOfPromotionToEditorNotification:notification];
//        }
//        else if ([notification.type intValue] == kDEMOTION_FROM_EDITOR) 
//        {
//            //raised when a user has been demoted
//            //sent to user that has been demoted from the editorial board
//            //on click should open up profile page
//            [self processClickOfDemotionFromEditorNotification:notification];
//        }
//        
//        else if ([notification.type intValue] == kDRAFT_NOT_PUBLISHED) 
//        {
//            //raised when a draft does not win a editorial board election
//            //sent to the page owner, photo creator, caption creator when a draft
//            //submitted to the editorial board does not win
//            //on click should open up into Dark Side view which illustrates which page was the winner
//            [self processClickOfDraftNotPublishedNotification:notification];
//        }
//        else if ([notification.type intValue] == kEDITORIAL_BOARD_NO_RESULT) 
//        {
//            //sent to all editors at the end of a poll where no winner was chosen because
//            //there were no votes
//            //onclick should open up into Dark Side view with vote counts listed for each page
//            [self processClickOfDraftEditorialBoardNoResult:notification];
//        }
//        else if ([notification.type intValue] == kDRAFT_LEADER_CHANGED) {
//            //this notification sent when we have a change in draft leadership
//            //we go to the caption supplied
//            [self processDraftLeaderChangedNotification:notification];
//        }
//        else 
            
            
        
        if ([notification.rendertype intValue] == kGENERIC_EDITORIAL_POST_VOTE) {
            //this notification type is a generic type designed to popup up the editorial
            //board view in a post-vote layout
            [self processGenericEditorialBoardPostVoteNotification:notification];
        }
        else if ([notification.rendertype intValue] == kGENERIC_FULLSCREEN) {
            //generic notification that will open up the fullscreen view and show a specific photo and caption
            [self processGenericFullscreenNotification:notification];
        }
        else if ([notification.rendertype intValue] == kGENERIC_DRAFT) {
            //generic notification that will open up the draft view and show a specific draft
            [self processGenericDraftNotification:notification];
        }
        else if ([notification.rendertype intValue] == kGENERIC_USER) {
            //generic notification that will open up the user view and show a specific user
            [self processGenericUserNotification:notification];
        }
        else if ([notification.rendertype intValue] == kGENERIC_EDITORIAL) {
            //generic editorial voting screen pre vote layout
            [self processGenericEditorialBoardNotification:notification];
        }
        else if ([notification.rendertype intValue] == kGENERIC_MESSAGE) {
            //generic message display notification to the user
            
        }
        else if ([notification.rendertype intValue] == kGENERIC_BOOK) {
            //generic book display
            [self processGenericBookNotification:notification];
        }
        
    }
    
}

- (void) dealloc {
    self.frc_notifications = nil;
    [super dealloc];
}


#pragma mark - NSFetchedResultsControllerDelegate 
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_notificationsTableView endUpdates];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_notificationsTableView beginUpdates];
}
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
    callback.fireOnMainThread = YES;
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

- (void)onProfileButtonPressed:(id)sender {    
    ProfileViewController* profileViewController = [ProfileViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
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
