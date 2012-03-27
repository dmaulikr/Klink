//
//  BookViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerLeaves.h"
#import "Macros.h"
#import "Page.h"
#import "PageState.h"
#import "LeavesUtilities.h"
#import "UIResourceLinkButton.h"
#import "ProfileViewController.h"
#import "Photo.h"
#import "Caption.h"
#import "EventManager.h"
#import "UserDefaultSettings.h"

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"

@implementation BookViewControllerLeaves
@synthesize controlVisibilityTimer  = m_controlVisibilityTimer;
@synthesize btn_illustratedBy       = m_btn_illustratedBy;
@synthesize btn_writtenBy           = m_btn_writtenBy;

@synthesize btn_readButton          = m_btn_readButton;
@synthesize btn_productionLogButton = m_btn_productionLogButton;
@synthesize btn_writersLogButton    = m_btn_writersLogButton;

@synthesize btn_userReadButton      = m_btn_userReadButton;
@synthesize btn_userWritersLogButton = m_btn_userWritersLogButton;
@synthesize btn_userWritersLogButtonLastPage = m_btn_userWritersLogButtonLastPage;

@synthesize btn_homeButton          = m_btn_homeButton;
@synthesize btn_tableOfContentsButton = m_btn_tableOfContentsButton;
@synthesize btn_zoomOutPhoto        = m_btn_zoomOutPhoto;
@synthesize btn_facebookButton      = m_btn_facebookButton;
@synthesize btn_twitterButton       = m_btn_twitterButton;


#pragma mark - Frames
- (CGRect) frameForBookPageViewController {
    return CGRectMake(0, 0, 302, 460);
}

- (CGRect) frameForShowHideButton {
    return CGRectMake(100, 0, 100, 460);
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
	
    [self.btn_homeButton setAlpha:hidden ? 0 : 1];
    [self.btn_tableOfContentsButton setAlpha:hidden ? 0 : 1];
    [self.btn_zoomOutPhoto setAlpha:hidden ? 0 : 1];
    [self.btn_facebookButton setAlpha:hidden ? 0 : 1];
    [self.btn_twitterButton setAlpha:hidden ? 0 : 1];
    
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


#pragma mark - Book Page and Home Page Button Helpers
- (void) bringBookPageButtonsToFront {
    [self.view bringSubviewToFront:self.btn_homeButton];
    [self.view bringSubviewToFront:self.btn_tableOfContentsButton];
    [self.view bringSubviewToFront:self.btn_zoomOutPhoto];
    [self.view bringSubviewToFront:self.btn_facebookButton];
    [self.view bringSubviewToFront:self.btn_twitterButton];
}

- (void) sendBookPageButtonsToBack {
    [self.view sendSubviewToBack:self.btn_homeButton];
    [self.view sendSubviewToBack:self.btn_tableOfContentsButton];
    [self.view sendSubviewToBack:self.btn_zoomOutPhoto];
    [self.view sendSubviewToBack:self.btn_facebookButton];
    [self.view sendSubviewToBack:self.btn_twitterButton];
}

- (void) bringHomePageButtonsToFront {
    // determine which set of title page buttons to show, default or user specific
    if (self.userID != nil) {
        [self.view bringSubviewToFront:self.btn_userReadButton];
        [self.view bringSubviewToFront:self.btn_userWritersLogButton];
    }
    else {
        [self.view bringSubviewToFront:self.btn_readButton];
        [self.view bringSubviewToFront:self.btn_productionLogButton];
        [self.view bringSubviewToFront:self.btn_writersLogButton];
    }
}

- (void) sendHomePageButtonsToBack {
    // determine which set of title page buttons to hide, default or user specific
    if (self.userID != nil) {
        [self.view sendSubviewToBack:self.btn_userReadButton];
        [self.view sendSubviewToBack:self.btn_userWritersLogButton];
    }
    else {
        [self.view sendSubviewToBack:self.btn_readButton];
        [self.view sendSubviewToBack:self.btn_productionLogButton];
        [self.view sendSubviewToBack:self.btn_writersLogButton];
    }
}

- (void) bringLastPageButtonsToFront {
    // determine which set of last page buttons to show, default or user specific
    if (self.userID != nil) {
        [self.view bringSubviewToFront:self.btn_userWritersLogButtonLastPage];
    }
    else {
        [self.view bringSubviewToFront:self.btn_productionLogButton];
    }
    
    [self.view bringSubviewToFront:self.btn_homeButton];
    [self.view bringSubviewToFront:self.btn_tableOfContentsButton];
}

- (void) sendLastPageButtonsToBack {
    // determine which set of last page buttons to hide, default or user specific
    if (self.userID != nil) {
        [self.view sendSubviewToBack:self.btn_userWritersLogButtonLastPage];
    }
    else {
        [self.view sendSubviewToBack:self.btn_productionLogButton];
    }
    
    [self.view sendSubviewToBack:self.btn_homeButton];
    [self.view sendSubviewToBack:self.btn_tableOfContentsButton];
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
    int count = publishedPageCount + 2;     // we add 2 to account for the title page and last placeholder page of the book which are not in the frc
    return count;
}

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)index {
    // hide the book and home page view buttons
    //[self sendBookPageButtonsToBack];
    //[self sendHomePageButtonsToBack];
    //[self sendLastPageButtonsToBack];
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index == 0) {
        // Do nothing, we are turning to the title page
    }
    else if (index == publishedPageCount + 1) {
        // Do nothing, we are turning to the last placeholder page
    }
    else {
        if (index < self.leavesView.currentPageIndex) {
            // paging backwards, need to make sure view reloads
            self.shouldOpenToSpecificPage = YES;
        }
        
        index--;    // we need to subtract one from the index to account for the title page which is not in the frc
        
        //we need to make a check to see how many objects we have left
        //if we are below a threshold, we need to execute a fetch to the server
        int lastIndex = publishedPageCount - 1;        
        int pagesRemaining = lastIndex - index;
        [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];
        
    }

}

- (void) leavesView:(LeavesView *)leavesView didTurnToPageAtIndex:(NSUInteger)index {
    
    NSUInteger publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index == 0) {
        // we are now showing the title page
        
        // hide the book page view buttons and show the home page buttons
        [self sendBookPageButtonsToBack];
        [self sendLastPageButtonsToBack];
        [self bringHomePageButtonsToFront];
    }
    else if (index == publishedPageCount + 1) {
        // we are now showing the title page
        
        // hide the book and home page view buttons and show the last placeholder page buttons
        [self sendBookPageButtonsToBack];
        [self sendHomePageButtonsToBack];
        [self bringLastPageButtonsToFront];
        
        [self showControls];
    }
    else {
        // we are still showing a regular page view
        
        // show the book page view buttons and hide the home page buttons
        [self sendHomePageButtonsToBack];
        [self sendLastPageButtonsToBack];
        [self bringBookPageButtonsToFront];
        
        [self showControls];
        [self hideControlsAfterDelay:2.5];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        if (publishedPageCount != NSNotFound && index != NSNotFound) {
            
            NSUInteger publishedPageIndex = index - 1;  // 1 is subtracted from the index to account for the title page which is not in the frc
            
            if (publishedPageIndex < publishedPageCount) {
                
                Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:publishedPageIndex];
                self.pageID = page.objectid;
                
                ResourceContext* resourceContext = [ResourceContext instance];
                
                Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:page.finishedphotoid];
                self.topVotedPhotoID = photo.objectid;
                
                Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:page.finishedcaptionid];
                self.topVotedCaptionID = caption.objectid;
                
                // we update the userDefault setting for the last page viewed by the user
                [userDefaults setInteger:publishedPageIndex forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
                
                // mark this page as the page that the book should open to
                self.shouldOpenToSpecificPage = YES;
            }
            else {
                [userDefaults setInteger:(0) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
            }
        }
        else {
            [userDefaults setInteger:(0) forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
        }
    }
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (index == 0) {
        // Return the title page, HomeViewController
        HomeViewController* homeViewController;
        if (self.userID != nil) {
            homeViewController = [HomeViewController createInstanceWithUserID:self.userID];
        }
        else {
            homeViewController = [HomeViewController createInstance];
        }
        homeViewController.view.backgroundColor = [UIColor clearColor];
        homeViewController.delegate = self;
        
        // directly draw the HomeViewController's view to the passed in graphic context
        CGRect viewRect = homeViewController.view.frame;
        
        CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        [homeViewController.view.layer renderInContext:ctx];
    }
    else if (index == publishedPageCount + 1) {
        // Return the last page placeholder, BookLastPageViewController
        BookLastPageViewController* bookLastPageViewController;
        if (self.userID != nil) {
            bookLastPageViewController = [BookLastPageViewController createInstanceWithUserID:self.userID];
        }
        else {
            bookLastPageViewController = [BookLastPageViewController createInstance];
        }
        bookLastPageViewController.delegate = self;
        bookLastPageViewController.view.backgroundColor = [UIColor clearColor];
        bookLastPageViewController.delegate = self;
        
        // directly draw the BookLastPageViewController's view to the passed in graphic context
        CGRect viewRect = bookLastPageViewController.view.frame;
        
        CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        [bookLastPageViewController.view.layer renderInContext:ctx];
    }
    else {
        // render the book page view controller for the given index
        index--;    // we need to subtract one to the index to account for the title page which is not in the frc
        
        if (publishedPageCount != 0 && index < publishedPageCount) {
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
            
            NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 2];
            
            BookPageViewController* bookPageViewController = [BookPageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
            bookPageViewController.delegate = self;
            bookPageViewController.view.backgroundColor = [UIColor clearColor];
            [pageNumber release];
            
            // directly draw the BookPageViewController's view to the passed in graphic context
            CGRect viewRect = bookPageViewController.view.frame;
            
            CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
            CGContextScaleCTM(ctx, 1.0, -1.0);
            
            [bookPageViewController.view.layer renderInContext:ctx];
            
            // adjust frames for draft attribution buttons
            self.btn_writtenBy.frame = bookPageViewController.btn_writtenBy.frame;
            self.btn_illustratedBy.frame = bookPageViewController.btn_illustratedBy.frame;
            
        }
    }
}

#pragma mark Override of LeaveView setCurrentPageIndex: method
- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex {
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    if (aCurrentPageIndex == 0) {
        // hide the book page view buttons and show the home page buttons
        [self sendBookPageButtonsToBack];
        [self sendLastPageButtonsToBack];
        [self bringHomePageButtonsToFront];
    }
    else if (aCurrentPageIndex == publishedPageCount + 1) {
        // hide the book and home page view buttons and show the last placeholder page buttons
        [self sendBookPageButtonsToBack];
        [self sendHomePageButtonsToBack];
        [self bringLastPageButtonsToFront];
    }
    else {
        // show the book page view buttons and hide the home page buttons
        [self sendHomePageButtonsToBack];
        [self sendLastPageButtonsToBack];
        [self bringBookPageButtonsToFront];
        
        [self hideControlsAfterDelay:2.5];
    }
    
    [self.leavesView setCurrentPageIndex:aCurrentPageIndex];
}


#pragma mark - Render Page from BookPageViewController
-(void)renderPage {
    [super renderPage];
    
    int publishedPageCount = [[self.frc_published_pages fetchedObjects]count];
    
    // we check the user default settings for the last page of the book the user viewed
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastViewedPublishedPageIndex = [userDefaults integerForKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
    
    int indexForPage = 0;
    
    // check to determine which page to render first
    if (self.shouldOpenToTitlePage) {
        // go to title page immidiately
        indexForPage = 0;
        [self setCurrentPageIndex:indexForPage];
    }
    else if (publishedPageCount != 0) {
        if (self.shouldOpenToSpecificPage) {
            // cancel further opening to this specific page
            //self.shouldOpenToSpecificPage = NO;
            
            if (self.pageID != nil  && [self.pageID intValue] != 0) {
                // the page id has been set, we will move to that page
                NSUInteger publishedPageIndex = [self indexOfPageWithID:self.pageID];
                indexForPage = publishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                
                // we update the userDefault setting for the last page viewed by the user to be this page
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:publishedPageIndex forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
                
                [self setCurrentPageIndex:indexForPage];
            }
            else {
                // No page specified, go to last placeholder page immidiately
                indexForPage = publishedPageCount + 1;
                [self setCurrentPageIndex:indexForPage];
            }
        }
        else if (lastViewedPublishedPageIndex < publishedPageCount) {
            // we go to the last page the user viewed
            Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:lastViewedPublishedPageIndex];
            self.pageID = page.objectid;
            
            indexForPage = lastViewedPublishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
            [self setCurrentPageIndex:indexForPage];
        }
        else {
            //need to find the first page
            ResourceContext* resourceContext = [ResourceContext instance];
            
            Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:YES];
            
            if (page != nil) {
                //local store does contain pages to enumerate
                self.pageID = page.objectid;
                NSUInteger publishedPageIndex = [self indexOfPageWithID:self.pageID];
                indexForPage = publishedPageIndex + 1;  // we add 1 to the index to account for the title page of the book which is not in the frc
                
                // we update the userDefault setting for the last page viewed by the user to be this page
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setInteger:publishedPageIndex forKey:setting_LASTVIEWEDPUBLISHEDPAGEINDEX];
                
                [self setCurrentPageIndex:indexForPage];
            }
            else {
                //no published pages, go to last placeholder page immidiately
                indexForPage = publishedPageCount + 1;
                [self setCurrentPageIndex:indexForPage];
            }
        }
    }
    else {
        //no published pages, go to last page placeholder immidiately
        indexForPage = publishedPageCount + 1;
        [self setCurrentPageIndex:indexForPage];
    }
    
    if ((indexForPage != 0) && (indexForPage != (publishedPageCount + 1))) {
        // we are about to render a published page from the book
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        self.topVotedPhotoID = page.finishedphotoid;
        self.topVotedCaptionID = page.finishedcaptionid;
    }
}

#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // resister a callback for for when the newly created BookPageViewController has completed the download of its photo
    Callback* pageViewPhotoDownloaded = [[Callback alloc]initWithTarget:self withSelector:@selector(onPageViewPhotoDownloaded:)];
    pageViewPhotoDownloaded.fireOnMainThread = YES;
    [self.eventManager registerCallback:pageViewPhotoDownloaded forSystemEvent:kPAGEVIEWPHOTODOWNLOADED];
    [pageViewPhotoDownloaded release];
    
    // Adjust the leave view frame to be the size of the BookPageViewController
    super.leavesView.frame = [self frameForBookPageViewController];
    
    // Add an invisible button to capture taps to hide/show the controls
    UIButton* invisibleShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // set the size of the button to fit in the area between the next page and previous page touch areas of the LeavesView
    invisibleShowHideButton.frame = [self frameForShowHideButton];
    // add targets and actions
    //[invisibleButton setBackgroundColor:[UIColor redColor]];
    [invisibleShowHideButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    // add to a view
    [self.view addSubview:invisibleShowHideButton];
    
    
    // add UIResourceLinkButtons for the userNames of page authors
    CGRect frameForWrittenBy = CGRectMake(161, 342, 129, 21);
    CGRect frameForIllustratedBy = CGRectMake(161, 363, 129, 21);
    
    UIResourceLinkButton* btn_writtenBy = [[UIResourceLinkButton alloc]initWithFrame:frameForWrittenBy];
    UIResourceLinkButton* btn_illustratedBy = [[UIResourceLinkButton alloc]initWithFrame:frameForIllustratedBy];
    
    [btn_illustratedBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn_writtenBy addTarget:self action:@selector(onLinkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn_writtenBy = btn_writtenBy;
    self.btn_illustratedBy = btn_illustratedBy;
    
    [self.view addSubview:self.btn_writtenBy];
    [self.view addSubview:self.btn_illustratedBy];
    
    [btn_writtenBy release];
    [btn_illustratedBy release];
    
    // Send book buttons to back until a page is loaded
    [self sendHomePageButtonsToBack];
    [self sendBookPageButtonsToBack];
    [self sendLastPageButtonsToBack];
    
    // Bring the book cover subview to the front
    [self.view bringSubviewToFront:self.iv_bookCover];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.btn_writtenBy = nil;
    self.btn_illustratedBy = nil;
    self.btn_readButton = nil;
    self.btn_productionLogButton = nil;
    self.btn_writersLogButton = nil;
    self.btn_homeButton = nil;
    self.btn_tableOfContentsButton = nil;
    self.btn_zoomOutPhoto = nil;
    self.btn_facebookButton = nil;
    self.btn_twitterButton = nil;
    
    if (self.controlVisibilityTimer) {
		[self.controlVisibilityTimer invalidate];
		self.controlVisibilityTimer = nil;
	}
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup table of contents button
    UIImage* tableOfContentButtonBackground = [[UIImage imageNamed:@"book_button_roundrect.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage* tableOfContentButtonHighlightedBackground = [[UIImage imageNamed:@"book_button_roundrect_highlighted.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonBackground forState:UIControlStateNormal];
    [self.btn_tableOfContentsButton setBackgroundImage:tableOfContentButtonHighlightedBackground forState:UIControlStateHighlighted];
    
    [self.leavesView reloadData];
    
    [self renderPage];
    
    if (self.shouldOpenBookCover) {
        // Bring the book cover subview to the front
        [self.view bringSubviewToFront:self.iv_bookCover];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Button Handlers
#pragma mark Book Page Delegate Methods
- (void) onHomeButtonPressed:(id)sender {
    [super onHomeButtonPressed:sender];
    
    // setup the book animations for when we return to book
    self.shouldCloseBookCover = NO;
    self.shouldOpenBookCover = NO;
    self.shouldOpenToTitlePage = NO;
    self.shouldAnimatePageTurn = YES;
    
    [self setCurrentPageIndex:0];
    
}

- (void) onFacebookButtonPressed:(id)sender {   
    [super onFacebookButtonPressed:sender];
}

- (void) onTwitterButtonPressed:(id)sender {
    [super onTwitterButtonPressed:sender];
}

- (void) onLinkButtonClicked:(id)sender {
    [super onLinkButtonClicked:sender];
    
    int currentIndex = self.leavesView.currentPageIndex - 1;  // we need to subtract one to the index to account for the title page which is not in the frc
    
    if (currentIndex < [[self.frc_published_pages fetchedObjects]count]) {
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
            // setup the book animations for when we return to book
            self.shouldCloseBookCover = NO;
            self.shouldOpenBookCover = NO;
            self.shouldOpenToTitlePage = NO;
            self.shouldAnimatePageTurn = NO;
            
            ProfileViewController* pvc = [ProfileViewController createInstanceForUser:userID];
            UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:pvc];
            navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:navigationController animated:YES];
            
            [navigationController release];
        }
    }
}

- (IBAction) onTableOfContentsButtonPressed:(id)sender {
    [super onTableOfContentsButtonPressed:sender];
    
    BookTableOfContentsViewController* bookTableOfContentsViewController;
    if (self.userID != nil) {
        bookTableOfContentsViewController = [BookTableOfContentsViewController createInstanceWithUserID:self.userID];
    }
    else {
        bookTableOfContentsViewController = [BookTableOfContentsViewController createInstance];
    }
    bookTableOfContentsViewController.delegate = self;
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookTableOfContentsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (IBAction) onZoomOutPhotoButtonPressed:(id)sender {
    [super onZoomOutPhotoButtonPressed:sender];
}

- (void) showNotificationViewController 
{
    [super showNotificationViewController];
}

#pragma mark Home Page Delegate Methods
- (IBAction) onReadButtonClicked:(id)sender {
    //called when the read button is pressed
    [super onReadButtonClicked:sender];
    
    [self renderPage];
    
}

- (IBAction) onProductionLogButtonClicked:(id)sender {
    //called when the production log button is pressed
    [super onProductionLogButtonClicked:sender];
    
}

- (IBAction) onWritersLogButtonClicked:(id)sender {
    //called when the writer's log button is pressed
    [super onWritersLogButtonClicked:sender];
    
}

- (IBAction) onUserWritersLogButtonClicked:(id)sender {
    //called when the writer's log button is pressed from the user specific book
    [super onUserWritersLogButtonClicked:sender];
}


#pragma mark - Callback Event Handlers
- (void) onPageViewPhotoDownloaded:(CallbackResult*)result {
    //NSDictionary* userInfo = result.response;
    //NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    //NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    /*int count = [[self.frc_published_pages fetchedObjects]count];
    int nextPageIndex = self.leavesView.currentPageIndex;
    
    if (count != 0 && nextPageIndex > -1 && nextPageIndex < count) {
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:nextPageIndex];
        NSNumber* nextDraftID = page.objectid;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Photo* photo = (Photo*)[resourceContext resourceWithType:PHOTO withID:page.finishedphotoid];
        NSNumber* nextTopVotedPhotoID = photo.objectid;
        
        if (draftID!=nil && photoID!=nil && self.pageID!=nil && self.topVotedPhotoID!=nil) {
            if ([draftID isEqualToNumber:nextDraftID] && [photoID isEqualToNumber:nextTopVotedPhotoID]) {
                
                self.shouldOpenToTitlePage = NO;
                self.shouldOpenToSpecificPage = YES;
                self.shouldAnimatePageTurn = YES;
                
                [self.leavesView reloadData];
                
                [self renderPage];
            }
        }
    }*/
    
    /*if (draftID!=nil && photoID!=nil && self.pageID!=nil && self.topVotedPhotoID!=nil) {
        if ([draftID isEqualToNumber:self.pageID] && [photoID isEqualToNumber:self.topVotedPhotoID]) {
            
            self.shouldOpenToTitlePage = NO;
            self.shouldOpenToSpecificPage = YES;
            self.shouldAnimatePageTurn = YES;
            
            [self.leavesView reloadData];
            
            [self renderPage];
        }
    }*/
    
    [self.leavesView reloadData];
    
    [self renderPage];
    
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
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo 
{
    [super onEnumerateComplete:enumerator withResults:results withUserInfo:userInfo];
    
    // NSString* activityName = @"BookViewControllerLeaves.controller.onEnumerateComplete:";
    
    if (enumerator == self.pageCloudEnumerator) {
        if ([results count] > 0) {
            [self.leavesView reloadData];
            
            [self renderPage];
        }
    }
    
    //[self.leavesView reloadData];
    
    //[self renderPage];
    
}


#pragma mark - Static Initializers
+ (BookViewControllerLeaves*) createInstance {
    BookViewControllerLeaves* instance = [[BookViewControllerLeaves alloc]initWithNibName:@"BookViewControllerLeaves" bundle:nil];
    // by default the book should always open to the title page on first load
    instance.shouldOpenToTitlePage = YES;
    instance.shouldOpenToSpecificPage = NO;
    instance.shouldAnimatePageTurn = NO;
    [instance autorelease];
    return instance;
}

+ (BookViewControllerLeaves*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerLeaves* vc = [BookViewControllerLeaves createInstance];
    vc.pageID = pageID;
    vc.shouldOpenToTitlePage = NO;
    vc.shouldOpenToSpecificPage = YES;
    vc.shouldAnimatePageTurn = YES;
    return vc;
}


@end
