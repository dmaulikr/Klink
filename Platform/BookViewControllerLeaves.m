//
//  BookViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/9/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerLeaves.h"
#import "PageViewController.h"
#import "Page.h"
#import "PageState.h"
#import "LeavesUtilities.h"

@implementation BookViewControllerLeaves
@synthesize iv_backgroundLeaves = m_iv_backgroundLeaves;


#pragma mark - Frames
- (CGRect) frameForPageViewController {
    return CGRectMake(0, 0, 302, 460);
}

- (CGRect) frameForShowHideButton {
    return CGRectMake(56, 0, 190, 460);
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
    return [[self.frc_published_pages fetchedObjects]count];
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
    // Return the page view controller for the given index
    int count = [[self.frc_published_pages fetchedObjects]count];
    
    if (count != 0 && index < count) {
        Page* page = [[self.frc_published_pages fetchedObjects]objectAtIndex:index];
        self.pageID = page.objectid;
        
        NSNumber* pageNumber = [[NSNumber alloc] initWithInt:index + 1];
        
        PageViewController* pageViewController = [PageViewController createInstanceWithPageID:page.objectid withPageNumber:pageNumber];
        pageViewController.view.backgroundColor = [UIColor blackColor];
        [pageNumber release];
        
        // Create an image out of the PageViewController
        UIImage *image = [self imageWithView:pageViewController.view];
        CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Adjust the leave view frame to be the size of the PageViewController
        //super.leavesView.frame = [self frameForPageViewController];
        
        CGAffineTransform transform = aspectFit(imageRect, CGContextGetClipBoundingBox(ctx));
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, imageRect, [image CGImage]);
        
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
		self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(hideControls) userInfo:nil repeats:NO] ;
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
    
    // Adjust the leave view frame to be the size of the PageViewController
    super.leavesView.frame = [self frameForPageViewController];
    
    
    // Add an invisible button to capture taps to hide/show the controls
    UIButton* invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // set the size of the button to fit in the area between the next page and previous page touch areas of the LeavesView
    invisibleButton.frame = [self frameForShowHideButton];
    // add targets and actions
    //[invisibleButton setBackgroundColor:[UIColor redColor]];
    [invisibleButton addTarget:self action:@selector(toggleControls) forControlEvents:UIControlEventTouchUpInside];
    // add to a view
    [self.view addSubview:invisibleButton];

    
    if (self.pageID != nil  && [self.pageID intValue] != 0) {
        //the page id has been set, we will move to that page
        int indexForPage = [self indexOfPageWithID:self.pageID];
        [self.leavesView setCurrentPageIndex:indexForPage];
    }
    else {
        //need to find the latest page
        ResourceContext* resourceContext = [ResourceContext instance];
        
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[NSString stringWithFormat:@"%d",kPUBLISHED] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:NO];
        
        if (page != nil) {
            //local store does contain pages to enumerate
            self.pageID = page.objectid;
            int indexForPage = [self indexOfPageWithID:self.pageID];
            [self.leavesView setCurrentPageIndex:indexForPage];
        }
        else {
            //no published pages
            [self.leavesView setCurrentPageIndex:0];
        }
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
