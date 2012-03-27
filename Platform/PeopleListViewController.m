//
//  PeopleListViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 3/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "PeopleListViewController.h"
#import "Macros.h"
#import "PlatformAppDelegate.h"
#import "CloudEnumerator.h"
#import "PeopleListType.h"
#import "Follow.h"
#import "ProfileViewController.h"
#import "UIPeopleListTableViewCell.h"
#import "AuthenticationManager.h"


@interface PeopleListViewController ()

@end

@implementation PeopleListViewController

//@synthesize cloudFollowEnumerator   = m_cloudFollowEnumerator;
@synthesize cloudFollowersEnumerator   = m_cloudFollowersEnumerator;
@synthesize cloudFollowingEnumerator   = m_cloudFollowingEnumerator;
@synthesize frc_follows             = __frc_follows;
@synthesize userID                  = m_userID;
@synthesize listType                = m_listType;
@synthesize tbl_peopleList          = m_tbl_peopleList;
@synthesize btn_follow              = m_btn_follow;


#pragma mark - Properties
//this NSFetchedResultsController will query for all follow objects
- (NSFetchedResultsController*) frc_follows {
    NSString* activityName = @"PeopleListViewController.frc_follows:";
    if (__frc_follows != nil) {
        return __frc_follows;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    PlatformAppDelegate* app = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:FOLLOW inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSPredicate* predicate;
    if (self.listType == kFOLLOWING) {
        //we need to query for all the individuals this user is following
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", FOLLOWERUSERID, self.userID];
    }
    else {
        //we need to query for all the individuals that are following this user
        predicate = [NSPredicate predicateWithFormat:@"%K=%@", USERID, self.userID];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:100];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_follows = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_PEOPLELISTVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_follows;
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
    self.btn_follow = nil;
    self.tbl_peopleList = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString* activityName = @"PeopleListViewController.frc_follows:";
    
    // Refresh the follow lists on each open
    self.cloudFollowersEnumerator = nil;
    self.cloudFollowingEnumerator = nil;
    
    self.cloudFollowersEnumerator = [CloudEnumerator enumeratorForFollowers:self.userID];
    self.cloudFollowingEnumerator = [CloudEnumerator enumeratorForFollowing:self.userID];
    
    self.cloudFollowersEnumerator.delegate = self;
    self.cloudFollowingEnumerator.delegate = self;
    
    if (!self.cloudFollowersEnumerator.isLoading) 
    {
        //followers enumerator is not loading, so we can go ahead and reset it and run it
        if ([self.cloudFollowersEnumerator canEnumerate]) 
        {
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@Refreshing followers count from cloud",activityName);
            [self.cloudFollowersEnumerator enumerateUntilEnd:nil];
        }
        else
        {
            //the followers enumerator is not ready to run, but we reset it and away we go
            [self.cloudFollowersEnumerator reset];
            [self.cloudFollowersEnumerator enumerateUntilEnd:nil];
        }
    }
    
    if (!self.cloudFollowingEnumerator.isLoading) 
    {
        //following enumerator is not loading, so we can go ahead and reset it and run it
        if ([self.cloudFollowingEnumerator canEnumerate]) 
        {
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@Refreshing following count from cloud",activityName);
            [self.cloudFollowingEnumerator enumerateUntilEnd:nil];
        }
        else
        {
            //the following enumerator is not ready to run, but we reset it and away we go
            [self.cloudFollowingEnumerator reset];
            [self.cloudFollowingEnumerator enumerateUntilEnd:nil];
        }
    }
    
    /*self.cloudFollowEnumerator = nil;
    if (self.listType == kFOLLOWING) 
    {
        self.cloudFollowEnumerator = [CloudEnumerator enumeratorForFollowing:self.userID];
    }
    else {
        self.cloudFollowEnumerator = [CloudEnumerator enumeratorForFollowers:self.userID];
    }
    self.cloudFollowEnumerator.delegate = self;
    
    if (!self.cloudFollowEnumerator.isLoading) 
    {
        //enumerator is not loading, so we can go ahead and reset it and run it
        if ([self.cloudFollowEnumerator canEnumerate]) 
        {
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@Refreshing follow count from cloud",activityName);
            [self.cloudFollowEnumerator enumerateUntilEnd:nil];
        }
        else
        {
            //the enumerator is not ready to run, but we reset it and away we go
            [self.cloudFollowEnumerator reset];
            [self.cloudFollowEnumerator enumerateUntilEnd:nil];
        }
    }*/
    
    NSString* navBarTitle;
    if (self.listType == kFOLLOWING) {
        navBarTitle = @"Following";
    }
    else {
        navBarTitle = @"Followers";
    }
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [navBarTitle sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = navBarTitle;
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    __frc_follows = nil;
    self.frc_follows = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    NSString* activityName = @"ProductionLogViewController.numberOfRowsInSection";
    
    int retVal = [[self.frc_follows fetchedObjects]count];
    
    // Return the number of rows in the section.
    LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@Number of rows in fetched results controller:%d",activityName,retVal);
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int followCount = [[self.frc_follows fetchedObjects]count];
    
    if ([indexPath row] < followCount) {
        //static NSString* CellIdentifier = @"Follows";
        Follow* follow = [[self.frc_follows fetchedObjects] objectAtIndex:[indexPath row]];
        
        //UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UIPeopleListTableViewCell* cell = (UIPeopleListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:[UIPeopleListTableViewCell cellIdentifier]];
        if (cell == nil) {
            cell = [[[UIPeopleListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UIPeopleListTableViewCell cellIdentifier]] autorelease];
            
            //setup a tag on the follow button so we can look it up if pressed
            //cell.btn_follow.tag = indexPath.row;
            [cell.btn_follow addTarget:self action:@selector(onFollowButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        //setup a tag on the follow button so we can look it up if pressed
        cell.btn_follow.tag = indexPath.row;
        
        // Configure the cell...
        [cell renderCellOfPeopleListType:self.listType withFollowID:follow.objectid];
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int followCount = [[self.frc_follows fetchedObjects]count];
    
    if ([indexPath row] < followCount) {
        Follow* follow = [[self.frc_follows fetchedObjects] objectAtIndex:[indexPath row]];
        
        ProfileViewController* profileViewController;
        if (self.listType == kFOLLOWING) {
            profileViewController = [ProfileViewController createInstanceForUser:follow.userid];
        }
        else {
            profileViewController = [ProfileViewController createInstanceForUser:follow.followeruserid];
        }
    
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
    
        [navigationController release];
    }
}

#pragma mark - Follow Button Handlers
- (void) processFollowUserWithID:(NSNumber*)userID withUserName:(NSString*)username {
    NSString* activityName = @"PeopleListViewController.processFollowUser:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    if ([loggedInUserID longValue] != [userID longValue]) 
    {
        if (![Follow doesFollowExistFor:userID withFollowerID:loggedInUserID]) 
        {
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            progressView.delegate = self;
            
            //we create a Follow object and then save it
            [Follow createFollowFor:userID withFollowerID:loggedInUserID];
            
            //lets save it
            ResourceContext* resourceContext = [ResourceContext instance];
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ Created follow object for user %@ to follow user %@",activityName,loggedInUserID,userID);
            
            ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            
            [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:[NSString stringWithFormat:@"Following %@...", username]]];
        }
        else {
            //error case
            LOG_PEOPLELISTVIEWCONTROLLER(1, @"%@ Follow relationship already exists for user %@ to follow user %@",activityName,loggedInUserID,userID);
        }
    }
    else {
        LOG_PEOPLELISTVIEWCONTROLLER(1, @"%@User cannot follow themself",activityName);
    }
}

- (void) processUnfollowUserWithID:(NSNumber*)userID withUserName:(NSString*)username {
    //we need to unfollow a person here
    NSString* activityName = @"PeopleListViewController.processUnfollowUser:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    if ([loggedInUserID longValue] != [userID longValue]) 
    {
        if ([Follow doesFollowExistFor:userID withFollowerID:loggedInUserID]) 
        {
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            progressView.delegate = self;
            
            [Follow unfollowFor:userID withFollowerID:loggedInUserID];
            
            ResourceContext* resourceContext = [ResourceContext instance];
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ Unfollowed relationship for user %@ to unfollow user %@",activityName,loggedInUserID,userID);
            
            ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            
            [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:[NSString stringWithFormat:@"Unfollowing %@...", username]]];
        }
        else {
            //error case
            LOG_PEOPLELISTVIEWCONTROLLER(1, @"%@ Follow relationship does not exist for user %@ to unfollow user %@",activityName,loggedInUserID,userID);
        }
    }
    else 
    {
        LOG_PEOPLELISTVIEWCONTROLLER(1,@"%@User cannot unfollow themself",activityName);
    }
}


- (IBAction) onFollowButtonPressed:(id)sender {
    NSString* activityName = @"PeopleListViewController.onFollowButtonPressed:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    self.btn_follow = (UIButton*)sender;
    
    //first we toggle the state of the follow button
    [self.btn_follow setSelected:!self.btn_follow.selected];
    
    //then we determine from which row the follow button was pressed using the button tag
    int row = self.btn_follow.tag;
    
    int followCount = [[self.frc_follows fetchedObjects]count];
    
    if (row < followCount) {
        Follow* follow = [[self.frc_follows fetchedObjects] objectAtIndex:row];
        
        if (self.btn_follow.selected == YES) {
            //logged in user wants to follow this person
            if (self.listType == kFOLLOWING) {
                LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ User %@ wants to follow user %@",activityName,loggedInUserID,follow.userid);
                [self processFollowUserWithID:follow.userid withUserName:follow.username];
            }
            else {
                LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ User %@ wants to follow user %@",activityName,loggedInUserID,follow.followeruserid);
                [self processFollowUserWithID:follow.followeruserid withUserName:follow.followername];
            }
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        }
        else {
            //logged in user wants to unfollow this person
            if (self.listType == kFOLLOWING) {
                LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ User %@ wants to follow user %@",activityName,loggedInUserID,follow.userid);
                [self processUnfollowUserWithID:follow.userid withUserName:follow.username];
            }
            else {
                LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@ User %@ wants to follow user %@",activityName,loggedInUserID,follow.followeruserid);
                [self processUnfollowUserWithID:follow.followeruserid withUserName:follow.followername];
            }
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        }
    }
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"ProfileViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        // Follow/Unfollow request was successful
        
    }
    else {
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        //toggle the state of the follow button back
        [self.btn_follow setSelected:!self.btn_follow.selected];
        if (self.btn_follow.selected == YES) {
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        }
        else {
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_peopleList endUpdates];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_peopleList beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"PeopleListViewController.controller.didChangeObject:";
    
    if (controller == self.frc_follows) {
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new follow object
            [self.tbl_peopleList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            
            Resource* resource = (Resource*)anObject;
            int count = [[self.frc_follows fetchedObjects]count];
            LOG_PEOPLELISTVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a new follow object
            [self.tbl_peopleList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
    else {
        LOG_PEOPLELISTVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
    
}

#pragma mark - Static Initializers
+ (PeopleListViewController*)createInstanceOfListType:(int)listType withUserID:(NSNumber*)userID {
    PeopleListViewController* instance = [[PeopleListViewController alloc]initWithNibName:@"PeopleListViewController" bundle:nil];
    instance.listType = listType;
    instance.userID = userID;
    [instance autorelease];
    return instance;
}

@end
