//
//  BookTableOfContentsViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 1/27/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "BookTableOfContentsViewController.h"
#import "Macros.h"
#import "Page.h"
#import "PageState.h"
#import "UITOCTableViewCell.h"
#import "BookViewControllerBase.h"
#import "BookViewControllerPageView.h"
#import "DateTimeHelper.h"
#import "NSDictionary-MutableDeepCopy.h"

#define kTOCTABLEVIEWCELLHEIGHT 55

@implementation BookTableOfContentsViewController
@synthesize frc_published_pages     = __frc_published_pages;
@synthesize allPages                = m_allPages;
@synthesize userID                  = m_userID;
@synthesize pagesSearch             = m_pagesSearch;
@synthesize months                  = m_months;
@synthesize monthsDeepCopy          = m_monthsDeepCopy;
@synthesize tbl_tOCTableView        = m_tbl_tOCTableView;
@synthesize btn_tableOfContentsButton   = m_btn_tableOfContentsButton;
@synthesize sb_searchBar            = m_sb_searchBar;
@synthesize btn_backgroundButton    = m_btn_backgroundButton;

#pragma mark - Property Definitions
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<BookTableOfContentsViewControllerDelegate>)del
{
    m_delegate = del;
}

#pragma mark - Properties
//this NSFetchedResultsController will query for all published pages
- (NSFetchedResultsController*) frc_published_pages {
    NSString* activityName = @"BookViewController.frc_published_pages:";
    if (__frc_published_pages != nil) {
        return __frc_published_pages;
    }
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATEPUBLISHED ascending:YES];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    
    NSPredicate* predicate;
    if (self.userID != nil) {
        //add predicate to gather only pages for a specific userID
        predicate = [NSPredicate predicateWithFormat:@"%K=%d AND (%K=%@ OR %K=%@)", stateAttributeNameStringValue, kPUBLISHED, FINISHEDILLUSTRATORID, self.userID, FINISHEDWRITERID, self.userID];
    }
    else {
        //add predicate to gather all published pages
        predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_published_pages = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_published_pages;
    
}

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location within the frc_photos for the photo with the id specified
    int retVal = 0;
    
    NSArray* fetchedObjects = [self.frc_published_pages fetchedObjects];
    int index = 0;
    for (Page* page in fetchedObjects) {
        if ([page.objectid isEqualToNumber:pageid]) {
            retVal = index;
            break;
        }
        index++;
    }
    return retVal;
}

#pragma mark - Custom Search Methods
- (void)resetSearch {
    NSMutableDictionary* allPagesCopy = [self.allPages mutableDeepCopy];
    self.pagesSearch = allPagesCopy;
    
    NSMutableArray* monthKeyArray = [[NSMutableArray alloc] init];
    [monthKeyArray addObjectsFromArray:self.monthsDeepCopy];
    self.months = monthKeyArray;
    [monthKeyArray release];
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    NSMutableArray* sectionsToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    
    NSString* pageTitle = nil;
    
    for (NSString* key in self.months) {
        NSMutableArray* array = [self.pagesSearch valueForKey:key];
        NSMutableArray* toRemove = [[NSMutableArray alloc] init];
        
        for (Page* page in array) {
            pageTitle = page.displayname;
            if ([pageTitle rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound)
                [toRemove addObject:page];
        }
        
        if ([array count] == [toRemove count])
            [sectionsToRemove addObject:key];
        
        [array removeObjectsInArray:toRemove];
        [toRemove release];
    }
    
    
    [self.months removeObjectsInArray:sectionsToRemove];
    [sectionsToRemove release];
    [self.tbl_tOCTableView reloadData];
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    
    //self.allPages = [[[NSMutableDictionary alloc] init] autorelease];
    self.months = [[[NSMutableArray alloc] init] autorelease];
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tbl_tOCTableView.rowHeight = kTOCTABLEVIEWCELLHEIGHT;
    
    // Set keyboard style to black
    for(UIView *subView in self.sb_searchBar.subviews)
        if([subView isKindOfClass: [UITextField class]])
            [(UITextField *)subView setKeyboardAppearance:UIKeyboardAppearanceAlert];
    
    // Navigation Bar Buttons
    UIBarButtonItem* leftButton = [[[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStyleBordered 
                                    target:self 
                                    action:@selector(onBackButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    /*// Set a custom border on the bottom of the search bar, so it's not so harsh
    UIView* bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.sb_searchBar.frame.size.height-1, self.sb_searchBar.frame.size.width, 1)];
    [bottomBorder setBackgroundColor:[UIColor colorWithWhite:200.0f/255.f alpha:1.0f]];
    [bottomBorder setOpaque:YES];
    [self.sb_searchBar addSubview:bottomBorder];
    [bottomBorder release];*/

    
    // Setup dictionary of draft titles and published month used for section sorting
    NSMutableDictionary* tempDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray* tempPageSection = [[NSMutableArray alloc] init];
    NSString* pageMonth = nil;
    NSString* monthKey = @"first";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM, YYY"];
    
    for (Page* page in [self.frc_published_pages fetchedObjects]) {
        
        pageMonth = [formatter stringFromDate:[DateTimeHelper parseWebServiceDateDouble:page.datepublished]];
        
        if ([monthKey isEqualToString:@"first"] || [pageMonth isEqualToString:monthKey]) {
            [tempPageSection addObject:page];
        }
        else {
            // we've reached a new month, save the current draft section to the dictionary 
            // as a new array then empty the temp array and add the next draft to it
            NSMutableArray* newPageSection = [NSMutableArray arrayWithArray:tempPageSection];
            //[self.allPages setObject:newPageSection forKey:monthKey];
            [tempDictionary setObject:newPageSection forKey:monthKey];
            
            // add this month to the dictionary key array
            [self.months addObject:monthKey];
            
            [tempPageSection removeAllObjects];
            [tempPageSection addObject:page];
        }
        
        monthKey = pageMonth;
    }
    
    // we've reached the end of the frc, add the last page section array and month key to the dictionary 
    NSMutableArray* lastPageSection = [NSMutableArray arrayWithArray:tempPageSection];
    //[self.allPages setObject:lastPageSection forKey:monthKey];
    [tempDictionary setObject:lastPageSection forKey:monthKey];
    [self.months addObject:monthKey];
    
    self.allPages = tempDictionary;
    [tempDictionary release];
    
    // make a deep copy of the months key array
    self.monthsDeepCopy = [[[NSMutableArray alloc] initWithArray:self.months copyItems:YES] autorelease];
    
    [formatter release];
    [tempPageSection release];
    
    [self resetSearch];
    [self.tbl_tOCTableView reloadData];
    [self.tbl_tOCTableView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.allPages = nil;
    self.pagesSearch = nil;
    self.months = nil;
    self.monthsDeepCopy = nil;
    
    self.tbl_tOCTableView = nil;
    self.btn_tableOfContentsButton = nil;
    
    self.sb_searchBar = nil;
    self.btn_backgroundButton = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Hide toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    // Setup table of contents button
    UIImage* tableOfContentButtonBackground = [[UIImage imageNamed:@"book_button_roundrect.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage* tableOfContentButtonHighlightedBackground = [[UIImage imageNamed:@"book_button_roundrect_highlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonBackground forState:UIControlStateNormal];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonHighlightedBackground forState:UIControlStateHighlighted];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    __frc_published_pages = nil;
    self.frc_published_pages = nil;
    self.userID = nil;
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
    //return 1;
    
    //return [self.months count];
    return ([self.months count] > 0) ? [self.months count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //int retVal = [[self.frc_published_pages fetchedObjects]count];
    //return retVal;
    
    if ([self.months count] == 0)
        return 0;
    NSString* month = [self.months objectAtIndex:section];
    NSArray* draftSection = [self.pagesSearch objectForKey:month];
    return [draftSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString* month = [self.months objectAtIndex:section];
    NSArray* pageSection = [self.pagesSearch objectForKey:month];
    
    int pageCount = [pageSection count];
    
    if ([indexPath row] < pageCount) {
        Page* page = [pageSection objectAtIndex:row];
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:[self indexOfPageWithID:page.objectid] + 2];
        
        UITOCTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UITOCTableViewCell cellIdentifier]];
        if (cell == nil) {
            cell = [[[UITOCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITOCTableViewCell cellIdentifier]] autorelease];
        }
        
        [cell renderDraftWithID:page.objectid withPageNumber:pageNumber];
        [pageNumber release];
        return cell;
    }
    else {
        //return nil;
        UITOCTableViewCell* cell = [[[UITOCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITOCTableViewCell cellIdentifier]] autorelease];
        return cell;
    }
    
    
    /*//Old way without month sections
    int pageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if ([indexPath row] < pageCount) {
        Page* page = [[self.frc_published_pages fetchedObjects] objectAtIndex:[indexPath row]];
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:[indexPath row] + 2];
        
        UITOCTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UITOCTableViewCell cellIdentifier]];
        if (cell == nil) {
            cell = [[[UITOCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITOCTableViewCell cellIdentifier]] autorelease];
        }
        
        [cell renderDraftWithID:page.objectid withPageNumber:pageNumber];
        [pageNumber release];
        return cell;
    }
    else {
        return nil;
    }*/
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.months count] == 0)
        return nil;
    NSString* month = [self.months objectAtIndex:section];
    return month;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    UIView* headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 54)] autorelease];
    //[headerView setBackgroundColor:[UIColor clearColor]];
    [headerView setBackgroundColor:[UIColor colorWithRed:181.0/255.0 green:164.0/255.0 blue:141.0/255.0 alpha:1.0]];
    
    UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:18];
    headerLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    headerLabel.shadowColor = [UIColor whiteColor];
    headerLabel.frame = CGRectMake(14, -15, 320.0, 54.0);
    headerLabel.textAlignment = UITextAlignmentLeft;
    
    if ([self.months count] == 0)
        headerLabel.text = nil;
    else
        headerLabel.text = [self.months objectAtIndex:section];
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54.0;
}*/

/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.months;
}*/

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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString* month = [self.months objectAtIndex:section];
    NSArray* pageSection = [self.pagesSearch objectForKey:month];
    
    int pageCount = [pageSection count];
    
    if ([indexPath row] < pageCount) {
        Page* page = [pageSection objectAtIndex:row];
        
        BookViewControllerBase* bookViewController = (BookViewControllerBase*)self.delegate;
        bookViewController.pageID = page.objectid;
        bookViewController.userID = self.userID;
        
        bookViewController.shouldOpenBookCover = NO;
        bookViewController.shouldOpenToSpecificPage = YES;
        bookViewController.shouldOpenToTitlePage = NO;
        bookViewController.shouldAnimatePageTurn = NO;
        
        [bookViewController renderPage];
        
        [self dismissModalViewControllerAnimated:YES];
        
        /*// We launch the BookViewController and open it up to the page we specified
        BookViewControllerBase* bookViewController;
        if (self.userID != nil) {
            bookViewController = [BookViewControllerBase createInstanceWithPageID:page.objectid withUserID:self.userID];
        }
        else {
            bookViewController = [BookViewControllerBase createInstanceWithPageID:page.objectid];
        }
        
        bookViewController.shouldOpenBookCover = NO;
        
        // Modal naviation
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];*/
        
    }
}

#pragma mark - Scroll View Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.sb_searchBar resignFirstResponder];
    return indexPath;
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // This will scroll the section header with the rest of the table and not anchor the section header to the top
    CGFloat sectionHeaderHeight = 54;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y <= 0) {
        self.sb_searchBar.frame = CGRectMake(0, scrollView.contentOffset.y, self.sb_searchBar.frame.size.width, self.sb_searchBar.frame.size.height);
    }
}

#pragma mark - Search Bar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchTerm = [searchBar text];
    
    [self.sb_searchBar setShowsCancelButton:NO animated:YES];
    [self.btn_backgroundButton setEnabled:NO];
    [self.sb_searchBar resignFirstResponder];
    //self.tbl_tOCTableView.allowsSelection = YES;
    //self.tbl_tOCTableView.scrollEnabled = YES;
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [self.tbl_tOCTableView reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.sb_searchBar setShowsCancelButton:YES animated:YES];
    [self.btn_backgroundButton setEnabled:YES];
    //self.tbl_tOCTableView.allowsSelection = NO;
    //self.tbl_tOCTableView.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.sb_searchBar setShowsCancelButton:NO animated:YES];
    [self.btn_backgroundButton setEnabled:NO];
    self.sb_searchBar.text = @"";
    [self resetSearch];
    [self.tbl_tOCTableView reloadData];
    [self.sb_searchBar resignFirstResponder];
    //self.tbl_tOCTableView.allowsSelection = YES;
    //self.tbl_tOCTableView.scrollEnabled = YES;
}

#pragma mark - Button Handlers
- (IBAction) onBackgroundButtonPressed:(id)sender {
    //[self searchBarCancelButtonClicked:nil];
    
    [self.sb_searchBar setShowsCancelButton:NO animated:YES];
    [self.btn_backgroundButton setEnabled:NO];
    [self.sb_searchBar resignFirstResponder];
}

#pragma mark Navigation Button Handlers
- (IBAction) onTOCButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializer
+ (BookTableOfContentsViewController*)createInstance {
    BookTableOfContentsViewController* bookTableOfContentsViewController = [[BookTableOfContentsViewController alloc]initWithNibName:@"BookTableOfContentsViewController" bundle:nil];
    bookTableOfContentsViewController.userID = nil;
    [bookTableOfContentsViewController autorelease];
    return bookTableOfContentsViewController;
}

+ (BookTableOfContentsViewController*)createInstanceWithUserID:(NSNumber*)userID {
    BookTableOfContentsViewController* bookTableOfContentsViewController = [[BookTableOfContentsViewController alloc]initWithNibName:@"BookTableOfContentsViewController" bundle:nil];
    bookTableOfContentsViewController.userID = userID;
    [bookTableOfContentsViewController autorelease];
    return bookTableOfContentsViewController;
}

@end
