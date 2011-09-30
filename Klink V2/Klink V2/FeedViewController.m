//
//  FeedViewController.m
//  Klink V2
//
//  Created by Bobby Gill on 9/29/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "FeedViewController.h"
#import "Feed.h"
#import "ImageManager.h"
#import "Photo.h"
#import "Caption.h"
#import "UIFeedTableCellView.h"
#import "FeedManager.h"

#define kFeedTableWidth_Portrait  320
#define kFeedTableHeight_Portrait  480
#define kFeedTableX_Portrait  0
#define kFeedTableY_Portrait  0



#define kFeedTableWidth_Landscape 0
#define kFeedTableHeight_Landscape  0
#define kFeedTableX_Landscape  0
#define kFeedTableY_Landscape  0

@implementation FeedViewController
@synthesize feedTable   =   m_feedTable;
@synthesize feedType    =   m_feedType;
@synthesize frc_feeds   =   __frc_feeds;
@synthesize refreshHeader=  m_refreshHeader;
#pragma mark - Properties
- (NSFetchedResultsController*) frc_feeds {
    if (__frc_feeds != nil) {
        return __frc_feeds;
    }
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    
    NSPredicate *predicate = nil;
    
    if (m_feedType == -1) {
         predicate = [NSPredicate predicateWithFormat:@"userid=%@ AND user_hasread=%@" argumentArray:[NSArray arrayWithObjects:authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO],nil]];
    }
    else {
         predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@ AND user_hasread=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:m_feedType],authenticationManager.m_LoggedInUserID,[NSNumber numberWithBool:NO], nil]];
    }
   
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feeds = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    return __frc_feeds;
}




#pragma mark - Frames
- (CGRect) frameForFeedTable {
    if ([super deviceInPortraitOrientation]) {
        return CGRectMake(kFeedTableX_Portrait, kFeedTableY_Portrait, kFeedTableWidth_Portrait, kFeedTableHeight_Portrait);
    }
    else {
        return CGRectMake(kFeedTableX_Landscape, kFeedTableY_Landscape, kFeedTableWidth_Landscape, kFeedTableHeight_Landscape);
    }
}


- (void) commonInit {
    CGRect frameForTable = [self frameForFeedTable];
    self.feedTable = [[UITableView alloc]initWithFrame:frameForTable style:UITableViewStylePlain];
    
    self.refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.feedTable.bounds.size.height, self.view.frame.size.width, self.feedTable.bounds.size.height)];
    self.refreshHeader.delegate = self;
    
    self.feedTable.delegate = self;
    self.feedTable.dataSource = self;

    [self.view addSubview:self.feedTable];
    [self.feedTable addSubview:self.refreshHeader];
    
    [self.refreshHeader refreshLastUpdatedDate];
}

- (id) init {
    self = [super init];
    if (self) {
        m_feedType = -1;
        [self commonInit];
    }
    return self;
}

- (id) initWithFeedType:(int)feedType {
    self = [super init];
    if (self) {
        m_feedType = feedType;
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [self.feedTable release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager getInstance];
    [feedManager refreshFeed];
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    FeedManager* feedManager = [FeedManager getInstance];
    return [feedManager isRefreshingFeed];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - KlinkBaseViewController overrides
- (void) onFeedRefreshed:(NSNotification*) notification {
    [super onFeedRefreshed:notification];
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.feedTable];
}

#pragma mark - UITableViewDelegate
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = [[self.frc_feeds fetchedObjects]count];
    return count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UITableViewDataSource
- (void) configureCell:(UIFeedTableCellView*)cell atIndex:(int)index forFeedItem:(Feed*)feed {
    int feedType = [feed.type intValue];
    ImageManager* imageManager = [ImageManager getInstance];
    
    if (feedType == feed_CAPTION_VOTE) {
        Caption* caption = [DataLayer getObjectByType:feed.targetobjecttype withId:feed.targetid];
       
        if (caption != nil) {
            Photo* photo = [DataLayer getObjectByType:PHOTO withId:caption.photoid];
            if (photo != nil) {
                cell.imageView.image = nil;
                
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:cell forKey:an_FEEDTABLECELL];
                [userInfo setObject:feed.objectid forKey:an_OBJECTID];
                UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:userInfo atCallback:self];
                
                if (image != nil) {
                    cell.imageView.image = image;
                }
                
                cell.titleLabel.text = nil;
                cell.titleLabel.text = feed.message;
                
                cell.dateLabel.text = nil;
                cell.dateLabel.text = [DateTimeHelper formatShortDate:feed.datecreated];
                
            }
            else {
                //TODO: need to make a call to the cloud to retrieve the missing reference
            }
   
        }
        else {
            //TODO: need to make a call to the cloud to retrieve the missing reference
        }
    }
    else if (feedType == feed_PHOTO_VOTE) {
         Photo* photo = [DataLayer getObjectByType:feed.targetobjecttype withId:feed.targetid];
        if (photo != nil) {
            cell.imageView.image = nil;
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:cell forKey:an_FEEDTABLECELL];
            [userInfo setObject:feed.objectid forKey:an_OBJECTID];
            UIImage* image = [imageManager downloadImage:photo.thumbnailurl withUserInfo:userInfo atCallback:self];
            
            if (image != nil) {
                cell.imageView.image = image;
            }
            cell.titleLabel.text = nil;
            cell.titleLabel.text = feed.message;
            
            cell.dateLabel.text = nil;
            cell.dateLabel.text = [DateTimeHelper formatShortDate:feed.datecreated];
        }
        else {
            //todo ened to download photo if missing
        }
    }
    
}

- (UIFeedTableCellView*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* activityName = @"FeedViewController.cellForRowAtIndexPath:";
    UIFeedTableCellView* cell = nil;
    int index = indexPath.row;
    int feedCount = [[self.frc_feeds fetchedObjects]count];
    Feed* feedItem = nil;
    
    if (feedCount > 0 &&
        index < feedCount) {
        feedItem = [[self.frc_feeds fetchedObjects]objectAtIndex:index];
        if ([feedItem.type intValue] == feed_PHOTO_VOTE) {
            cell = (UIFeedTableCellView*)[tableView dequeueReusableCellWithIdentifier:cellid_PHOTO_VOTE];
            if (!cell) {
                cell = [[UIFeedTableCellView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid_PHOTO_VOTE];
            }
            cell.feedItem = feedItem;
            [self configureCell:cell atIndex:index forFeedItem:feedItem];
        }
        else if ([feedItem.type intValue] == feed_CAPTION_VOTE) {
            cell = (UIFeedTableCellView*)[tableView dequeueReusableCellWithIdentifier:cellid_CAPTION_VOTE];
            if (!cell) {
                cell = [[UIFeedTableCellView alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid_CAPTION_VOTE];

            }
            cell.feedItem = feedItem;
            [self configureCell:cell atIndex:index forFeedItem:feedItem];
        }
        else {
            NSString* message = [NSString stringWithFormat:@"Unrecognized feed type: %d for index %d",[feedItem.type intValue],index];
            [BLLog e:activityName withMessage:message];
        }
        
        
    }
  
    return cell;
    
    
}

#pragma mark - Image View Download
- (void) onImageDownload:(UIImage *)image withUserInfo:(NSDictionary *)userInfo {
    UIFeedTableCellView* cell = [userInfo objectForKey:an_FEEDTABLECELL];
    NSNumber* feedID = [userInfo objectForKey:an_OBJECTID];
    if (cell.feedItem != nil &&
        [cell.feedItem.objectid isEqualToNumber:feedID]) {
        //cell still being used to display the original feed id
        cell.imageView.image = image;
    }
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
    
    //we display our table of rows
    [self.feedTable reloadData];
    
    //add the button to refresh and clear
    UIBarButtonItem* clearButton = [[UIBarButtonItem alloc]initWithTitle:@"Clear All" style:UIBarButtonItemStylePlain target:self action:@selector(onClearAllSelected:)];
    self.navigationItem.rightBarButtonItem = clearButton;
    [clearButton release];
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
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

#pragma mark - UIBarButtonItem handler
- (void) onClearAllSelected:(id)sender {
    //clear all notifications
    NSArray* feedItems = [self.frc_feeds fetchedObjects];
    int count = [feedItems count];
    NSMutableSet* indexPathsToDelete = [[NSMutableSet alloc]init ];
    
    for (int i = 0; i < count ; i++) {
        Feed* feedItem = [feedItems objectAtIndex:i];
        feedItem.user_hasread = [NSNumber numberWithBool:YES];
        [feedItem commitChangesToDatabase:NO withPendingFlag:NO];
        
        //remove from the table
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathsToDelete addObject:indexPath];
    }
    
    [self.feedTable deleteRowsAtIndexPaths:[indexPathsToDelete allObjects] withRowAnimation:UITableViewRowAnimationTop];
    [indexPathsToDelete release];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
     
        [self.feedTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

@end
