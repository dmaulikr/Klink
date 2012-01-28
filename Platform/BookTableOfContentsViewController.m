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

#define kTOCTABLEVIEWCELLHEIGHT 55

@implementation BookTableOfContentsViewController
@synthesize frc_published_pages = __frc_published_pages;
@synthesize tbl_tOCTableView    = m_tbl_tOCTableView;
@synthesize btn_tableOfContentsButton   = m_btn_tableOfContentsButton;


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
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:YES];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",stateAttributeNameStringValue, kPUBLISHED];
    
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
    
    // Navigation Bar Buttons
    UIBarButtonItem* leftButton = [[[UIBarButtonItem alloc]
                                    initWithTitle:@"Back"
                                    style:UIBarButtonItemStyleBordered 
                                    target:self 
                                    action:@selector(onBackButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = leftButton;

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
    int retVal = [[self.frc_published_pages fetchedObjects]count];
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    int pageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if ([indexPath row] < pageCount) {
        Page* page = [[self.frc_published_pages fetchedObjects] objectAtIndex:[indexPath row]];
        
        // We launch the BookViewController and open it up to the page we specified
        BookViewControllerBase* bookViewController = [BookViewControllerBase createInstanceWithPageID:page.objectid];
        //BookViewControllerBase* bookViewController = self.delegate;
        bookViewController.shouldOpenBookCover = NO;
        
        // Modal naviation
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
        
    }
}

#pragma mark - Button Handlers
#pragma mark Navigation Button Handlers
- (IBAction) onTOCButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Static Initializer
+ (BookTableOfContentsViewController*)createInstance {
    BookTableOfContentsViewController* bookTableOfContentsViewController = [[BookTableOfContentsViewController alloc]initWithNibName:@"BookTableOfContentsViewController" bundle:nil];
    [bookTableOfContentsViewController autorelease];
    return bookTableOfContentsViewController;
}

@end
