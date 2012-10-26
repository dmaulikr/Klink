//
//  BookLastPageViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 1/26/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "BookLastPageViewController.h"
#import "CloudEnumeratorFactory.h"
#import "PlatformAppDelegate.h"
#import "PageState.h"
#import "Macros.h"
#import "UIStrings.h"

@implementation BookLastPageViewController
@synthesize cloudDraftEnumerator    = m_cloudDraftEnumerator;
@synthesize frc_draft_pages         = __frc_draft_pages;
@synthesize btn_homeButton          = m_btn_homeButton;
@synthesize btn_tableOfContentsButton = m_btn_tableOfContentsButton;
@synthesize lbl_statementLabel      = m_lbl_statementLabel;
@synthesize btn_productionLogButton = m_btn_productionLogButton;
@synthesize lbl_numDrafts           = m_lbl_numDrafts;
@synthesize userID                  = m_userID;
@synthesize btn_userWritersLogButton = m_btn_userWritersLogButton;
@synthesize lbl_userWritersLogSubtext = m_lbl_userWritersLogSubtext;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<BookLastPageViewControllerDelegate>)del
{
    m_delegate = del;
}

//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_draft_pages {
    //NSString* activityName = @"BookLastViewController.frc_draft_pages:";
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
        //LOG_BOOKLASTPAGEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
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

- (void)updateDefaultBookLabels {
    // update the count of open drafts
    [self updateDraftCount];
    
    self.lbl_statementLabel.text = @"the next page of Bahndr has yet to be written...";
    
    [self.btn_productionLogButton setTitle:ui_PRODUCTIONLOG forState:UIControlStateNormal];
    
}

- (void)updateUserBookLabels {
    ResourceContext* resourceContext = [ResourceContext instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    
    self.lbl_statementLabel.text = [NSString stringWithFormat:@"%@'s next page in Bahndr has yet to be written...", user.username];
    
    [self.btn_userWritersLogButton setTitle:@"Back" forState:UIControlStateNormal];
    
    self.lbl_userWritersLogSubtext.text = [NSString stringWithFormat:@"%@'s profile", user.username];
}

- (void)render {
    NSString* activityName = @"BookLastPageViewController.render:";
    if (self.cloudDraftEnumerator == nil) 
    {
        self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
        self.cloudDraftEnumerator.delegate = self;
    }
    
    if ([self.cloudDraftEnumerator canEnumerate]) 
    {
        LOG_HOMEVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
        [self.cloudDraftEnumerator enumerateUntilEnd:nil];
    }
    
    
    // determine which type of last page to show, default or user specific
    if (self.userID != nil) {
        [self.btn_productionLogButton setHidden:YES];
        [self.lbl_numDrafts setHidden:YES];
        [self.btn_userWritersLogButton setHidden:NO];
        [self.lbl_userWritersLogSubtext setHidden:NO];
        
        // update all the labels of the last page for the user book case
        [self updateUserBookLabels];
    }
    else {
        [self.btn_userWritersLogButton setHidden:YES];
        [self.lbl_userWritersLogSubtext setHidden:YES];
        [self.btn_productionLogButton setHidden:NO];
        [self.lbl_numDrafts setHidden:NO];
        
        // update all the labels of the last page for the default book case
        [self updateDefaultBookLabels];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
    
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending) {
        // in pre iOS 5 devices, we need to check the FRC and update UI
        // labels in viewDidLoad to populate the LeavesViewController
        
        [self render];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.btn_homeButton = nil;
    self.btn_tableOfContentsButton = nil;
    self.btn_productionLogButton = nil;
    self.lbl_numDrafts = nil;
    self.lbl_statementLabel = nil;
    self.btn_userWritersLogButton = nil;
    self.lbl_userWritersLogSubtext = nil;
}

- (void) viewWillAppear:(BOOL)animated {
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
        
        [self render];
    }
    
    // Setup table of contents button
    UIImage* tableOfContentButtonBackground = [[UIImage imageNamed:@"button_roundrect_brown.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    UIImage* tableOfContentButtonHighlightedBackground = [[UIImage imageNamed:@"button_roundrect_brown_highlighted.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonBackground forState:UIControlStateNormal];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonHighlightedBackground forState:UIControlStateHighlighted];
    
    // Unhide the buttons
    [self.btn_homeButton setHidden:NO];
    [self.btn_tableOfContentsButton setHidden:NO];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Button Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    [self.delegate onHomeButtonPressed:sender];
}

- (IBAction) onTableOfContentsButtonPressed:(id)sender {
    [self.delegate onTableOfContentsButtonPressed:sender];
}

- (IBAction) onProductionLogButtonClicked:(id)sender {   
    [self.delegate onProductionLogButtonClicked:sender];
}

- (IBAction) onUserWritersLogButtonClicked:(id)sender {
    [self.delegate onUserWritersLogButtonClicked:sender];
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
+ (BookLastPageViewController*)createInstance {
    BookLastPageViewController* bookLastPageViewController = [[BookLastPageViewController alloc]initWithNibName:@"BookLastPageViewController" bundle:nil];
    bookLastPageViewController.userID = nil;
    [bookLastPageViewController autorelease];
    return bookLastPageViewController;
}

+ (BookLastPageViewController*)createInstanceWithUserID:(NSNumber *)userID {
    BookLastPageViewController* bookLastPageViewController = [[BookLastPageViewController alloc]initWithNibName:@"BookLastPageViewController" bundle:nil];
    bookLastPageViewController.userID = userID;
    [bookLastPageViewController autorelease];
    return bookLastPageViewController;
}

@end
