//
//  BookViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerLeaves.h"
#import "PageViewController.h"
#import "Macros.h"
#import "Page.h"
#import "PageState.h"
#import "LeavesUtilities.h"
#import "UIResourceLinkButton.h"
#import "ProfileViewController.h"
#import "Photo.h"
#import "Caption.h"
#import "EventManager.h"
#import "UICustomNavigationBar.h"
#import "UICustomToolbar.h"
#import "HomeViewController.h"
#import "UserDefaultSettings.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"

@implementation BookViewControllerLeaves
@synthesize invisibleReadButton = m_invisibleReadButton;
@synthesize invisibleProductionLogButton = m_invisibleProductionLogButton;
@synthesize invisibleWritersLogButton = m_invisibleWritersLogButton;
@synthesize iv_backgroundLeaves = m_iv_backgroundLeaves;
@synthesize btn_illustratedBy = m_btn_illustratedBy;
@synthesize btn_writtenBy = m_btn_writtenBy;

#pragma mark - Frames
- (CGRect) frameForPageViewController {
    return CGRectMake(0, 0, 302, 460);
}

- (CGRect) frameForShowHideButton {
    return CGRectMake(100, 0, 100, 460);
}

#pragma mark - Initializers
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


#pragma mark - LeavesViewController Delegate Methods (for iOS 3-4x)
- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    int count = publishedPageCount + 1;     // we add 1 to account for the title page of the book which is not in the frc
    return count;
}

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)index {
    if (index == 0) {
        // Do nothing, we are turning to the title page
    }
    else {
        index--;    // we need to subtract one from the index to account for the title page which is not in the frc
        
        int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
        
        //we need to make a check to see how many objects we have left
        //if we are below a threshold, we need to execute a fetch to the server
        int lastIndex = publishedPageCount - 1;        
        int pagesRemaining = lastIndex - index;
        [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];
        
        //Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        //self.pageID = page.objectid;
        
        //Photo* photo = [page photoWithHighestVotes];
        //self.topVotedPhotoID = photo.objectid;
    }

}

- (void) leavesView:(LeavesView *)leavesView didTurnToPageAtIndex:(NSUInteger)index {
    if (index == 0) {
        // we are now showing the title page, enable and show the title page buttons
        [self.invisibleReadButton setEnabled:YES];
        [self.invisibleProductionLogButton setEnabled:YES];
        [self.invisibleWritersLogButton setEnabled:YES];
        [self.invisibleReadButton setHidden:NO];
        [self.invisibleProductionLogButton setHidden:NO];
        [self.invisibleWritersLogButton setHidden:NO];
    }
    else {
        // we are still showing a regular page view, ensure the title page buttons are disabled and hidden
        [self.invisibleReadButton setEnabled:NO];
        [self.invisibleProductionLogButton setEnabled:NO];
        [self.invisibleWritersLogButton setEnabled:NO];
        [self.invisibleReadButton setHidden:YES];
        [self.invisibleProductionLogButton setHidden:YES];
        [self.invisibleWritersLogButton setHidden:YES];
        
        int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        if ((index - 1) < publishedPageCount) {
            // we update the userDefault setting for the last page viewed by the user,
            // 1 is subtracted from the index to account for the title page which is not in the frc
            [userDefaults setInteger:(index - 1) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
        }
        else {
            [userDefaults setInteger:(0) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
        }
        
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:(index - 1)];
        self.pageID = page.objectid;
        
        Photo* photo = [page photoWithHighestVotes];
        self.topVotedPhotoID = photo.objectid;
    }
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
    
    if (index == 0) {
        // Return the title page, HomeViewController
        HomeViewController* homeViewController = [HomeViewController createInstance];
        homeViewController.view.backgroundColor = [UIColor clearColor];
        
        // directly draw the HomeViewController's view to the passed in graphic context
        CGRect viewRect = homeViewController.view.frame;
        
        CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        [homeViewController.view.layer renderInContext:ctx];
    }
    else {
        // Return the page view controller for the given index
        index--;    // we need to subtract one to the index to account for the title page which is not in the frc
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        if (count != 0 && index < count) {
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
            
            NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 2];
            
            PageViewController* pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
            pageViewController.view.backgroundColor = [UIColor clearColor];
            [pageNumber release];
            
            // directly draw the PageViewController's view to the passed in graphic context
            CGRect viewRect = pageViewController.view.frame;
            
            CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            
            [pageViewController.view.layer renderInContext:ctx];
            
            // adjust frames for draft attribution buttons
            self.btn_writtenBy.frame = pageViewController.btn_writtenBy.frame;
            self.btn_illustratedBy.frame = pageViewController.btn_illustratedBy.frame;
            
        }
    }
}

#pragma mark - Button Handlers
#pragma mark Username button handler
- (void) onLinkButtonClicked:(id)sender {
    
    int currentIndex = self.leavesView.currentPageIndex;
    
    Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:currentIndex];
    Caption* caption = [page captionWithHighestVotes];
    Photo* photo = [page photoWithHighestVotes];
    
    NSNumber* userID = nil;
    
    if (sender == self.btn_writtenBy) {
        userID = caption.creatorid;
    }
    else {
        userID = photo.creatorid;
    }
    
    if (userID != nil) {
        ProfileViewController* pvc = [ProfileViewController createInstanceForUser:userID];
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:pvc];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
}

#pragma mark - Render Page from PageViewController
-(void)renderPage {
    //NSString* activityName = @"BookViewControllerLeaves.controller.renderPage:";
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    // we check the user default settings for the last page of the book the user viewed
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastViewedPublishedPageIndex = [userDefaults integerForKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
    
    int indexForPage = 0;
    
    // check to determine which page to render first
    if (self.shouldOpenToTitlePage) {
        // go to title page immidiately
        indexForPage = 0;
        [self.leavesView setCurrentPageIndex:0];
    }
    else if (publishedPageCount != 0) {
        if (self.pageID != nil  && [self.pageID intValue] != 0) {
            // the page id has been set, we will move to that page
            indexForPage = [self indexOfPageWithID:self.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            [self.leavesView setCurrentPageIndex:indexForPage];
        }
        else if (lastViewedPublishedPageIndex < publishedPageCount) {
            // we go to the last page the user viewed
            indexForPage = lastViewedPublishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            [self.leavesView setCurrentPageIndex:indexForPage];
        }
        else {
            //need to find the first page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:YES];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                indexForPage = [self indexOfPageWithID:self.pageID] + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                [self.leavesView setCurrentPageIndex:indexForPage];
            }
            else {
                //no published pages, go to title page
                [self.leavesView setCurrentPageIndex:0];
            }
        }
    }
    
    if (indexForPage == 0) {
        // we are about to move to the title page of the book, enable and show the title page buttons
        [self.invisibleReadButton setEnabled:YES];
        [self.invisibleProductionLogButton setEnabled:YES];
        [self.invisibleWritersLogButton setEnabled:YES];
        [self.invisibleReadButton setHidden:NO];
        [self.invisibleProductionLogButton setHidden:NO];
        [self.invisibleWritersLogButton setHidden:NO];
    }
    else {
        // we are about to move to a page view of the book that is not the title page, disable and hide the title page buttons
        [self.invisibleReadButton setEnabled:NO];
        [self.invisibleProductionLogButton setEnabled:NO];
        [self.invisibleWritersLogButton setEnabled:NO];
        [self.invisibleReadButton setHidden:YES];
        [self.invisibleProductionLogButton setHidden:YES];
        [self.invisibleWritersLogButton setHidden:YES];
    }

}

#pragma mark - Control Hiding / Showing
- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		self.controlVisibilityTimer = nil;
	}
}

- (void)hideControlsAfterDelay:(NSTimeInterval)delay {
    [self cancelControlHiding];
	if (!m_controlsHidden) {
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)setControlsHidden:(BOOL)hidden {
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	
	/*// Get status bar height if visible
     CGFloat statusBarHeight = 0;
     if (![UIApplication sharedApplication].statusBarHidden) {
     CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
     statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
     }
     
     // Status Bar
     if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
     [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
     } else {
     [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
     }
     
     // Get status bar height if visible
     if (![UIApplication sharedApplication].statusBarHidden) {
     CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
     statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
     }
     
     // Set navigation bar frame
     CGRect navBarFrame = self.navigationController.navigationBar.frame;
     navBarFrame.origin.y = statusBarHeight;
     self.navigationController.navigationBar.frame = navBarFrame;*/
    
    // Navigation and tool bars
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
    [self.navigationController.toolbar setAlpha:hidden ? 0 : 1];
    
	[UIView commitAnimations];
	
    // reset the controls hidden flag
    m_controlsHidden = hidden;
    
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay:5];
	
}

- (void)hideControls { 
    [self setControlsHidden:YES]; 
}

- (void)showControls { 
    [self cancelControlHiding];
    [self setControlsHidden:NO];
}

- (void)toggleControls {
    [self setControlsHidden:!m_controlsHidden]; 
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // resister a callback for for when the newly created PageViewController has completed the download of its photo
    Callback* pageViewPhotoDownloaded = [[Callback alloc]initWithTarget:self withSelector:@selector(onPageViewPhotoDownloaded:)];
    pageViewPhotoDownloaded.fireOnMainThread = YES;
    [self.eventManager registerCallback:pageViewPhotoDownloaded forSystemEvent:kPAGEVIEWPHOTODOWNLOADED];
    [pageViewPhotoDownloaded release];
    
    // Adjust the leave view frame to be the size of the PageViewController
    super.leavesView.frame = [self frameForPageViewController];
    
    // by default the book should always open to the title page on first load
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
    
    // Add an invisible button to capture taps to hide/show the controls
    UIButton* invisibleShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // set the size of the button to fit in the area between the next page and previous page touch areas of the LeavesView
    invisibleShowHideButton.frame = [self frameForShowHideButton];
    // add targets and actions
    //[invisibleButton setBackgroundColor:[UIColor redColor]];
    [invisibleShowHideButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    // add to a view
    [self.view addSubview:invisibleShowHideButton];
    
    
    
    // Add an invisible buttons to capture touches on HomePage buttons
    self.invisibleReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.invisibleProductionLogButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.invisibleWritersLogButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //self.invisibleReadButton.backgroundColor = [UIColor redColor];
    //self.invisibleProductionLogButton.backgroundColor = [UIColor redColor];
    //self.invisibleWritersLogButton.backgroundColor = [UIColor redColor];
    
    // set the frames of the buttons to match the frames on the HomeViewController layout
    self.invisibleReadButton.frame = CGRectMake(32, 183, 257, 66);
    self.invisibleProductionLogButton.frame = CGRectMake(32, 242, 257, 66);
    self.invisibleWritersLogButton.frame = CGRectMake(32, 301, 257, 66);
    
    // add button targets and actions
    [self.invisibleReadButton addTarget:self action:@selector(onReadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.invisibleProductionLogButton addTarget:self action:@selector(onProductionLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.invisibleWritersLogButton addTarget:self action:@selector(onWritersLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // add buttons to the view
    [self.view addSubview:self.invisibleReadButton];
    [self.view addSubview:self.invisibleProductionLogButton];
    [self.view addSubview:self.invisibleWritersLogButton];
    
    
    // add UIResourceLinkButtons for the userNames of page authors
    CGRect frameForWrittenBy = CGRectMake(161, 342, 129, 21);
    CGRect frameForIllustratedBy = CGRectMake(161, 363, 129, 21);
    
    UIResourceLinkButton* btn_writtenBy = [[UIResourceLinkButton alloc]initWithFrame:frameForWrittenBy];
    UIResourceLinkButton* btn_illustratedBy = [[UIResourceLinkButton alloc]initWithFrame:frameForIllustratedBy];
    
    self.btn_writtenBy = btn_writtenBy;
    self.btn_illustratedBy = btn_illustratedBy;
    
    [btn_illustratedBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn_writtenBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn_writtenBy];
    [self.view addSubview:btn_illustratedBy];
    
    [btn_writtenBy release];
    [btn_illustratedBy release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.invisibleReadButton = nil;
    self.invisibleProductionLogButton = nil;
    self.invisibleWritersLogButton = nil;
    self.btn_writtenBy = nil;
    self.btn_illustratedBy = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self hideControlsAfterDelay:3];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.leavesView reloadData];
    
    [self renderPage];
    
    // Set the navigation bar and toolbar to the custom clear type
    // Background Image
    UIImage* barImage = [UIImage imageNamed:@"NavigationBar_clear.png"];
    
    // pre-iOS 5 method for changing bar backgrounds
    //UINavigationBar* navigationBar = self.navigationController.navigationBar;
    //UICustomNavigationBar* customNavigationBar = (UICustomNavigationBar *)navigationBar;
    //[customNavigationBar setBackgroundImage:barImage];
    
    //UICustomToolbar* toolbar = (UICustomToolbar *)[[self navigationController] toolbar];
    //[toolbar setBackgroundImage:barImage];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // pre-iOS 5 method for changing bar backgounds
    //UICustomNavigationBar *navigationBar = (UICustomNavigationBar *)[[self navigationController] navigationBar];
    //[navigationBar setBackgroundImage:nil];
    
    //UICustomToolbar *toolbar = (UICustomToolbar *)[[self navigationController] toolbar];
    //[toolbar setBackgroundImage:nil];
    
    
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = NO;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Navigation Bar Button Handlers
- (void) onHomeButtonPressed:(id)sender {
    [super onHomeButtonPressed:sender];
    
    // we are about to move to the title page of the book, enable and show the title page buttons
    [self.invisibleReadButton setEnabled:YES];
    [self.invisibleProductionLogButton setEnabled:YES];
    [self.invisibleWritersLogButton setEnabled:YES];
    [self.invisibleReadButton setHidden:NO];
    [self.invisibleProductionLogButton setHidden:NO];
    [self.invisibleWritersLogButton setHidden:NO];
    
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = YES;
    
    [self.leavesView setCurrentPageIndex:0];
    
}

#pragma mark - UI Event Handlers
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    [super onReadButtonClicked:sender];
    
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = YES;
    
    [self renderPage];
    
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    [super onProductionLogButtonClicked:sender];
    
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    //called when the writer's log button is pressed
    [super onWritersLogButtonClicked:sender];
    
    self.shouldOpenToTitlePage = YES;
    self.shouldAnimatePageTurn = NO;
    
}


#pragma mark - Callback Event Handlers
- (void) onPageViewPhotoDownloaded:(CallbackResult*)result {
    NSDictionary* userInfo = result.response;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    //if ([draftID isEqualToNumber:self.pageID]) {
    if ([draftID isEqualToNumber:self.pageID] && [photoID isEqualToNumber:self.topVotedPhotoID]) {
        
        [self.leavesView reloadData];
        
        [self renderPage];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"BookViewControllerLeaves.controller.didChangeObject:";
    if (controller == self.frc_published_pages) {
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a page
            
        }
    }
    else {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    [super onEnumerateComplete:userInfo];
    
    // NSString* activityName = @"BookViewControllerLeaves.controller.onEnumerateComplete:";
    
    [self.leavesView reloadData];
    
    [self renderPage];
    
}


#pragma mark - Static Initializers
+ (BookViewControllerLeaves*) createInstance {
    BookViewControllerLeaves* instance = [[BookViewControllerLeaves alloc]initWithNibName:@"BookViewControllerLeaves" bundle:nil];
    [instance autorelease];
    return instance;
}

+ (BookViewControllerLeaves*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerLeaves* vc = [BookViewControllerLeaves createInstance];
    vc.pageID = pageID;
    return vc;
}


@end
