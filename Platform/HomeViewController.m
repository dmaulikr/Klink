//
//  HomeViewController.m
//  Platform
//
//  Created by Bobby Gill on 10/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "HomeViewController.h"
//#import "DraftViewController.h"
//#import "ContributeViewController.h"
#import "CallbackResult.h"
//#import "ProductionLogViewController.h"
//#import "BookViewControllerBase.h"
//#import "NotificationsViewController.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "AuthenticationManager.h"
#import "PlatformAppDelegate.h"
#import "PageState.h"
#import "Macros.h"
#import "CloudEnumeratorFactory.h"
#import "UIStrings.h"

@implementation HomeViewController

@synthesize cloudDraftEnumerator    = m_cloudDraftEnumerator;
@synthesize frc_draft_pages         = __frc_draft_pages;
@synthesize btn_readButton          = m_btn_readButton;
@synthesize btn_productionLogButton = m_btn_productionLogButton;
@synthesize btn_writersLogButton    = m_btn_writersLogButton;
@synthesize lbl_numDrafts           = m_lbl_numDrafts;
@synthesize lbl_writersLogSubtext   = m_lbl_writersLogSubtext;
@synthesize lbl_numContributors     = m_lbl_numContributors;


#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<HomeViewControllerDelegate>)del
{
    m_delegate = del;
}

//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_draft_pages {
    NSString* activityName = @"HomeViewController.frc_draft_pages:";
    if (__frc_draft_pages != nil) {
        return __frc_draft_pages;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    PlatformAppDelegate* app = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    //add predicate to test for being published
    double doubleDateNow = [[NSDate date] timeIntervalSince1970];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    NSString* dateExpireAttributeNameStringValue = [NSString stringWithFormat:@"%@",DATEDRAFTEXPIRES];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d AND %K >= %f",stateAttributeNameStringValue, kDRAFT, dateExpireAttributeNameStringValue,doubleDateNow];

    
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
        LOG_HOMEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_draft_pages;
    
}

- (void)updateDraftCount {
    int numDraftsTotal = [[self.frc_draft_pages fetchedObjects]count];
    if (numDraftsTotal == 0) {
        self.lbl_numDrafts.text = [NSString stringWithFormat:@"Draft a new page"];
    }
    else {
        NSNumber* numDrafts = [NSNumber numberWithInt:numDraftsTotal];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
        [numberFormatter setGroupingSeparator:@","];
        NSString* numDraftsCommaString = [numberFormatter stringForObjectValue:numDrafts];
        [numberFormatter release];
        self.lbl_numDrafts.text = [NSString stringWithFormat:@"%@ draft pages in progress", numDraftsCommaString];
    }
}

- (void)updateWritersLogButtonText {
    // set the appropriate text for the Writer's log button
    NSString* writersLogBtnString = nil;
    if ([self.authenticationManager isUserAuthenticated]) {
        writersLogBtnString = [NSString stringWithFormat:ui_AUTH_WORKERSLOG, self.loggedInUser.username];
        int unreadNotifications = [User unopenedNotificationsFor:self.loggedInUser.objectid];
        self.lbl_writersLogSubtext.text = [NSString stringWithFormat:@"%d unread notifications",unreadNotifications];
    }
    else {
        writersLogBtnString = ui_UAUTH_WORKERSLOGS;
        self.lbl_writersLogSubtext.text = [NSString stringWithFormat:@"Become part of the effort"];
    }
    
    [self.btn_writersLogButton setTitle:writersLogBtnString forState:UIControlStateNormal];
    [self.btn_writersLogButton setTitle:writersLogBtnString forState:UIControlStateHighlighted];
}

- (void)updateLabels {
    // update the count of open drafts
    [self updateDraftCount];
    
    // set number of contributors label
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int numContributors = [settings.num_users intValue];
    
    if (numContributors == 0) {
        self.lbl_numContributors.text = [NSString stringWithFormat:@"& contributors"];
    }
    else {
        NSNumber* numContributors = settings.num_users;
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
        [numberFormatter setGroupingSeparator:@","];
        NSString* numContributorsCommaString = [numberFormatter stringForObjectValue:numContributors];
        [numberFormatter release];
        self.lbl_numContributors.text = [NSString stringWithFormat:@"%@ contributors", numContributorsCommaString];
    }
    
    [self.btn_readButton setTitle:ui_PUBLISHEDPAGES forState:UIControlStateNormal];    
    [self.btn_productionLogButton setTitle:ui_PRODUCTIONLOG forState:UIControlStateNormal];
    
    // set the appropriate text for the Writer's log button
    [self updateWritersLogButtonText];
    
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    
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

- (void)dealloc
{
    
    [super dealloc];
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
    NSString* activityName = @"HomeViewController.viewDidLoad:";
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending) {
        // in pre iOS 5 devices, we need to check the FRC and update UI
        // labels in viewDidLoad to populate the LeavesViewController
        
        if (self.cloudDraftEnumerator == nil) 
        {
            self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
            self.cloudDraftEnumerator.delegate = self;
        }
        
        if (!self.cloudDraftEnumerator.isLoading) 
        {
            //enumerator is not loading, so we can go ahead and reset it and run it
            
            if ([self.cloudDraftEnumerator canEnumerate]) 
            {
                LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
                [self.cloudDraftEnumerator enumerateUntilEnd:nil];
            }
            else
            {
                //the enumerator is not ready to run, but we reset it and away we go
                [self.cloudDraftEnumerator reset];
                [self.cloudDraftEnumerator enumerateUntilEnd:nil];
            }
        }
        
        /*if (self.cloudDraftEnumerator == nil) 
        {
            self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
            self.cloudDraftEnumerator.delegate = self;
        }
        
        if ([self.cloudDraftEnumerator canEnumerate]) 
        {
            LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
            [self.cloudDraftEnumerator enumerateUntilEnd:nil];
        }*/
        
        // refresh the notification feed
        Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
        BOOL isEnumeratingFeed = [[FeedManager instance]tryRefreshFeedOnFinish:callback];
        
        if (isEnumeratingFeed) 
        {
            LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing user's notification feed",activityName);
        }
        
        // update all the labels of the UI
        [self updateLabels];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.btn_readButton = nil;
    self.btn_productionLogButton = nil;
    self.btn_writersLogButton = nil;
    self.lbl_numDrafts = nil;
    self.lbl_writersLogSubtext = nil;
    self.lbl_numContributors = nil;
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void) viewWillAppear:(BOOL)animated {
    NSString* activityName = @"HomeViewController.viewWillAppear:";
    [super viewWillAppear:animated];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    //Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedDescending) {
        // in iOS 5 and above devices, we need to check the FRC and update UI
        // labels in viewWillAppear to populate up to date data for the UIPageViewController
        
        if (self.cloudDraftEnumerator == nil) 
        {
            self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
            self.cloudDraftEnumerator.delegate = self;
        }
        
        if (!self.cloudDraftEnumerator.isLoading) 
        {
            //enumerator is not loading, so we can go ahead and reset it and run it
            
            if ([self.cloudDraftEnumerator canEnumerate]) 
            {
                LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
                [self.cloudDraftEnumerator enumerateUntilEnd:nil];
            }
            else
            {
                //the enumerator is not ready to run, but we reset it and away we go
                [self.cloudDraftEnumerator reset];
                [self.cloudDraftEnumerator enumerateUntilEnd:nil];
            }
        }
        
        /*if (self.cloudDraftEnumerator == nil) 
         {
         self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
         self.cloudDraftEnumerator.delegate = self;
         }
         
         if ([self.cloudDraftEnumerator canEnumerate]) 
         {
         LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
         [self.cloudDraftEnumerator enumerateUntilEnd:nil];
         }*/
        
        // refresh the notification feed
        Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
        BOOL isEnumeratingFeed = [[FeedManager instance]tryRefreshFeedOnFinish:callback];
        
        if (isEnumeratingFeed) 
        {
            LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing user's notification feed",activityName);
        }
        
        // update all the labels of the UI
        [self updateLabels];
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    [self.delegate onReadButtonClicked:sender];
}

- (IBAction) onProductionLogButtonClicked:(id)sender {   
    [self.delegate onProductionLogButtonClicked:sender];
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    [self.delegate onWritersLogButtonClicked:sender];
}

#pragma mark - FeedRefreshCallback Handler
- (void) onFeedRefreshComplete:(CallbackResult*)result
{
    [self updateWritersLogButtonText];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"HomeViewController.controller.didChangeObject:";
    if (controller == self.frc_draft_pages) {
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            int count = [[self.frc_draft_pages fetchedObjects]count];
            LOG_HOMEVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
            // update the count of open drafts
            [self updateDraftCount];
        }
        else if (type == NSFetchedResultsChangeDelete) {
            // update the count of open drafts
            [self updateDraftCount];
        }
    }
    else {
        LOG_HOMEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
   
}

#pragma mark - Static Initializer
+ (HomeViewController*)createInstance {
    HomeViewController* homeViewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    [homeViewController autorelease];
    return homeViewController;
}

@end
