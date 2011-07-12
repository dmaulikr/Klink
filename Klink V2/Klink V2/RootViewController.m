//
//  RootViewController.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "RootViewController.h"

#import "BLLog.h"
#import "CustomCell.h"

@interface RootViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation RootViewController

@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize lb_newViews;
@synthesize lb_newCaptions;
@synthesize tableView;
@synthesize activityIndicator;
//Load all state needed for the view from the data layer, execute
//any web service calls to refresh data
- (void)refreshViewFromDataLayer {
    if ([self canShowViewToUser]) {
        NSNumber* currentUserID = [[AuthenticationManager getInstance] m_LoggedInUserID];
        NSArray* photos = [self.fetchedResultsController fetchedObjects];
        
        
        if ([photos count] < 5) {
            //initiate a refresh from the server
            [self startBusyIndicator];
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            NSString* queryIdentifier = [NSString GetGUID];
            [notificationCenter addObserver:self selector:@selector(onTopicsDownloaded:) name:queryIdentifier object:nil];
            
            QueryOptions* queryOptions = [QueryOptions queryForTopics];
            
            WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
            [enumerationManager enumerateObjectsWithType:PHOTO 
                                maximumNumberOfResults:[NSNumber numberWithInt:20]
                                withQueryOptions:queryOptions
                                onFinishNotify:queryIdentifier];
            
            
         
        }
    }
    
}

#pragma - notification handlers

- (void)onTopicsDownloaded:(NSNotification*)notification {
    //disable the activity progress bar if it is running
    [self stopBusyIndicator];
}

#pragma mark - busy indicator methods

- (void)stopBusyIndicator {
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)self.navigationItem.titleView;
    
    [indicatorView stopAnimating];
}

- (void)startBusyIndicator {
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView*)self.navigationItem.titleView;
    
    [indicatorView startAnimating];

}


- (BOOL)canShowViewToUser {
    NSNumber* currentUserID = [[AuthenticationManager getInstance] m_LoggedInUserID];
    return YES;
}

- (void) onNewCaptionCreated:(NSNotification*)notification {
    NSString* activityName = @"RootViewController.onNewCaptionCreated:";
    
    NSString* message = [[NSString alloc] initWithFormat:@"received new caption create notification"];
    [BLLog v:activityName withMessage:message];
    
    
    [message release];
}
                                                            

+ (NSString*) getActivityName {
    return @"RootViewController";
}

+ (NSInteger) getViewID {
    return 1; 
}

- (id) init {
    [BLLog v:@"" withMessage:@"init called"];
    self = [super init];
    if (self != nil) {
        
    }

    return self;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [BLLog v:@"" withMessage:@"initWithNibName called"];
    if (self == [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

        
    }
    return self;
}

#pragma mark - view controller lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //login user for temporary access
    AuthenticationManager* authenticationManager = [[AuthenticationManager getInstance]retain];
    
    NSTimeInterval currentDateInSeconds = [[NSDate date] timeIntervalSince1970];
    NSNumber *currentDate = [NSNumber numberWithDouble:currentDateInSeconds];
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;            
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tn_AUTHENTICATIONCONTEXT inManagedObjectContext:appContext];
  
    
    //Create dummy authentication context
    NSMutableDictionary* authenticationContextDictionary = [[NSMutableDictionary alloc]init];
    
    [authenticationContextDictionary setObject:[NSNumber numberWithInt:1] forKey:an_USERID];
    [authenticationContextDictionary setObject:[currentDate stringValue] forKey:an_EXPIRY_DATE];
    [authenticationContextDictionary setObject:[NSString stringWithFormat:@"dicks"] forKey:an_TOKEN];
    
        AuthenticationContext* context = [[[AuthenticationContext alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:nil]initFromDictionary:authenticationContextDictionary];
    [authenticationManager loginUser:[NSNumber numberWithInt:1] withAuthenticationContext:context];
    [context release];
    
    // Set up the edit and add buttons.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddNewClick:)];
    self.navigationItem.rightBarButtonItem = addButton;
   
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.navigationItem.titleView = self.activityIndicator;
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Dick";
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];

   

    self.tableView.rowHeight = 100;

    [self refreshViewFromDataLayer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}


// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections]count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section]name];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ci";
    
    CustomCell *cell = (CustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
        
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (CustomCell*)currentObject;
            }
        }
        
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ServerManagedResource *resource = (ServerManagedResource*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        NSNumber *objectID = [NSNumber numberWithLongLong:[resource.objectid longLongValue]];
        NSString* objectType = [NSString stringWithString:resource.objecttype];
        [resource deleteFromDatabase];
        
        WS_TransferManager* transferManager = [WS_TransferManager getInstance];
        [transferManager deleteObjectInCloud:objectID withObjectType:objectType];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerManagedResource* selectedResource = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([selectedResource.objecttype isEqualToString:PHOTO]) {
        [self onExistingTopicClick:(Photo*)selectedResource];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [activityIndicator release];
    [super dealloc];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CustomCell *customCell = (CustomCell*)cell;
    
    customCell.topicNameLabel.text = [[managedObject valueForKey:an_LOCATIONDESCRIPTION] descr];
    customCell.streamLabel.text = [[managedObject valueForKey:an_DATECREATED] descr];
   
    
}

- (void)insertNewObject
{
abort();
//    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }

     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    [fetchRequest setFetchBatchSize:20];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:an_DATECREATED ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];


    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

	NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
   
    
	if (error != nil)
        {

	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
//
///*
//// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
// 
// - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    // In the simplest, most efficient, case, reload the table view.
//    [self.tableView reloadData];
//}
// */

#pragma mark - action listeners

- (void)onAddNewClick :(id)sender {
    NSString* activityName = @"RootViewController.onAddNewClick:";

    NoteController* noteViewController = [[NoteController alloc]initWithNibName:@"NoteController" bundle:nil withTopic:nil withThought:nil];
    
    
    NSString* message = [NSString stringWithFormat:@"Add button clicked, launching note controller"];
    [BLLog v:activityName withMessage:message];
    
   
    [self.navigationController pushViewController:noteViewController animated:YES];
    [noteViewController release];
    
}

- (void)onExistingTopicClick:(Photo*)topic {
    NSString *activityName = @"RootViewController.onExisitinTopicCLick:";
    TopicController *topicViewController = [[TopicController alloc]initWithNibName:@"TopicController" bundle:nil withTopic:topic];

    NSString* message = [NSString stringWithFormat:@"Existing topic with id %@ clicked, launching note controller",topic.objectid];
    [BLLog v:activityName withMessage:message];
    
    [self.navigationController  pushViewController:topicViewController animated:YES];
    [topicViewController release];
}

@end
