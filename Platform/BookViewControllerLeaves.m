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

#define kPAGEID @"pageid"
#define kPHOTOID @"photoid"

@implementation BookViewControllerLeaves
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

#pragma mark - Helper methods for iOS 4 page view workaround
- (UIImage *) imageWithView:(UIView *)view
{
    float scale = [[UIScreen mainScreen] scale];
    
    //CGSize imgContextSize = CGSizeMake(view.bounds.size.width*scale, view.bounds.size.height*scale);
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, scale);
    
    //UIGraphicsBeginImageContextWithOptions(imgContextSize, view.opaque, scale*2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    
    //CGSize imageSize = img.size;
    
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - LeavesViewController Delegate Methods (for iOS 3-4x)
- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
    int count = [[self.frc_published_pages fetchedObjects]count];
    return count;
}

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
    //we need to make a check to see how many objects we have left
    //if we are below a threshold, we need to execute a fetch to the server
    int count = [[self.frc_published_pages fetchedObjects]count];
    int lastIndex = count - 1;
    int pagesRemaining = lastIndex - pageIndex;
    [self evaluateAndEnumeratePagesFromCloud:pagesRemaining];

}

- (void) leavesView:(LeavesView *)leavesVie didTurnToPageAtIndex:(NSUInteger)index {
	
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
    // Return the page view controller for the given index
    int count = [[self.frc_published_pages fetchedObjects]count];
    
    if (count != 0 && index < count) {
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        //self.pageID = page.objectid;
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 2];
        
        PageViewController* pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
        //pageViewController.view.backgroundColor = [UIColor blackColor];
        pageViewController.view.backgroundColor = [UIColor clearColor];
        [pageNumber release];
        
        //[pageViewController.view drawRect:pageViewController.view.bounds];
        
        // NEW WAY:BEGIN directly draw the PageViewController's view to the passed in graphoic context
        CGRect viewRect = pageViewController.view.frame;
        
        CGContextTranslateCTM(ctx, 0.0, viewRect.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        [pageViewController.view.layer renderInContext:ctx];
        
        // adjust frames for draft attribution buttons
        self.btn_writtenBy.frame = pageViewController.btn_writtenBy.frame;
        self.btn_illustratedBy.frame = pageViewController.btn_illustratedBy.frame;
       
        // NEW WAY:END
        
        /*// OLD WAY:BEGIN use a UIImage representation of the PageViewController's view
        // Create an image out of the PageViewController
        UIImage *image = [self imageWithView:pageViewController.view];
        
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        CGAffineTransform transform = aspectFit(imageRect, CGContextGetClipBoundingBox(ctx));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, imageRect, [image CGImage]);
        // OLD WAY:END*/
        
        //[pageViewController release];
    }
}

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
   // NSString* activityName = @"BookViewControllerLeaves.controller.renderPage:";
    
    NSNumber* pageID = self.pageID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    int indexForPage = 0;
    
    if (self.pageID != nil  && [self.pageID intValue] != 0) {
        //the page id has been set, we will move to that page
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            //local store does contain the page
            Photo* photo = [page photoWithHighestVotes];
            self.topVotedPhotoID = photo.objectid;
            
            indexForPage = [self indexOfPageWithID:self.pageID];
            [self.leavesView setCurrentPageIndex:indexForPage];
        }
        else {
            //local store does not contain the page, we need to enumerate pages
            //[self.pageCloudEnumerator enumerateUntilEnd:nil];
        }
    }
    else {
        //need to find the latest page
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:NO];
        
        if (page != nil) {
            //local store does contain pages to enumerate
            self.pageID = page.objectid;
            indexForPage = [self indexOfPageWithID:self.pageID];
            [self.leavesView setCurrentPageIndex:indexForPage];
            
        }
        else {
            //no published pages
            [self.leavesView setCurrentPageIndex:0];
        }
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
    
    // Set the backgound image of the leave view to the book page
    //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"open_book_page_turn.png"]];
    //self.leavesView.backgroundColor = background;
    //[background release];
    
    // Add an invisible button to capture taps to hide/show the controls
    UIButton* invisibleShowHideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // set the size of the button to fit in the area between the next page and previous page touch areas of the LeavesView
    invisibleShowHideButton.frame = [self frameForShowHideButton];
    // add targets and actions
    //[invisibleButton setBackgroundColor:[UIColor redColor]];
    [invisibleShowHideButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    // add to a view
    [self.view addSubview:invisibleShowHideButton];
    
    
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
    
    self.btn_writtenBy = nil;
    self.btn_illustratedBy = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.leavesView reloadData];
    
    //[self renderPage];
    
    [self hideControlsAfterDelay:3];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.leavesView reloadData];
    
    [self renderPage];
    
    // Set the navigation bar and toolbar to the custom clear type
    // Background Image
    UIImage *barImage = [UIImage imageNamed:@"NavigationBar_clear.png"];
    
    // pre-iOS 5 method for changing bar backgounds
    UICustomNavigationBar *navigationBar = (UICustomNavigationBar *)[[self navigationController] navigationBar];
    [navigationBar setBackgroundImage:barImage];
    
    UICustomToolbar *toolbar = (UICustomToolbar *)[[self navigationController] toolbar];
    [toolbar setBackgroundImage:barImage];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // pre-iOS 5 method for changing bar backgounds
    UICustomNavigationBar *navigationBar = (UICustomNavigationBar *)[[self navigationController] navigationBar];
    [navigationBar setBackgroundImage:nil];
    
    UICustomToolbar *toolbar = (UICustomToolbar *)[[self navigationController] toolbar];
    [toolbar setBackgroundImage:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Callback Event Handlers
- (void) onPageViewPhotoDownloaded:(CallbackResult*)result {
    NSDictionary* userInfo = result.context;
    NSNumber* draftID = [userInfo valueForKey:kPAGEID];
    NSNumber* photoID = [userInfo valueForKey:kPHOTOID];
    
    if ([draftID isEqualToNumber:self.pageID]) { //&& [photoID isEqualToNumber:self.topVotedPhotoID]) {
        
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
            
            //[self.leavesView reloadData];
            
            //[self renderPage];
            
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
