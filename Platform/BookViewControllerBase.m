//
//  BookViewControllerBase.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/22/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BookViewControllerBase.h"
#import "Macros.h"
#import "Page.h"
#import "CloudEnumeratorFactory.h"
#import "UINotificationIcon.h"
#import "SocialSharingManager.h"
#import "PageState.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "PlatformAppDelegate.h"
#import "BookViewControllerPageView.h"
#import "BookViewControllerLeaves.h"
#import "CloudEnumerator.h"

@implementation BookViewControllerBase
@synthesize pageID              = m_pageID;
@synthesize frc_published_pages = __frc_published_pages;
@synthesize pageCloudEnumerator = m_pageCloudEnumerator;
@synthesize controlVisibilityTimer = m_controlVisibilityTimer;
@synthesize tb_facebookButton       = m_tb_facebookButton;
@synthesize tb_twitterButton        = m_tb_twitterButton;
@synthesize tb_bookmarkButton       = m_tb_bookmarkButton;
@synthesize tb_notificationButton  = m_tb_notificationButton;
@synthesize iv_background           = m_iv_background;
@synthesize captionCloudEnumerator  = m_captionCloudEnumerator;


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
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d",STATE, kPUBLISHED];
    
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

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location within the frc_published_photos for the photo with the id specified
    NSArray* fetchedObjects = [self.frc_published_pages fetchedObjects];
    int index = 0;
    for (Page* page in fetchedObjects) {
        
        if ([page.objectid isEqualToNumber:pageid]) {
           
            break;
        }
        index++;
    }
    return index;
}

#pragma mark - Toolbar buttons
- (NSArray*) toolbarButtonsForViewController {
    //returns an array with the toolbar buttons for this view controller
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    
    // initialize button spacers
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem* fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];

    //add Facebook share button
   UIBarButtonItem* fb = [[UIBarButtonItem alloc]
                              initWithImage:[UIImage imageNamed:@"icon-facebook.png"]
                              style:UIBarButtonItemStylePlain
                              target:self
                              action:@selector(onFacebookButtonPressed:)];
    self.tb_facebookButton  = fb;
    [fb release];
    [retVal addObject:self.tb_facebookButton];
    
    //add flexible space for button spacing
    [retVal addObject:flexibleSpace];
    
    //add Twitter share button
    UIBarButtonItem* tb = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:@"icon-twitter-t.png"]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(onTwitterButtonPressed:)];
    self.tb_twitterButton = tb;
    [tb release];
    [retVal addObject:self.tb_twitterButton];
    
    //add fixed space for button spacing
    fixedSpace1.width = 66;
    [retVal addObject:fixedSpace1];
    
    //add bookmark button
    UIBarButtonItem* bkb = [[UIBarButtonItem alloc]
                                       initWithImage:[UIImage imageNamed:@"icon-ribbon2.png"]
                                       style:UIBarButtonItemStylePlain
                                       target:self 
                                       action:@selector(onBookmarkButtonPressed:)];
    self.tb_bookmarkButton = bkb;
    [bkb release];
    [retVal addObject:self.tb_bookmarkButton];
    
    //add fixed space for button spacing
    fixedSpace2.width = 13;
    [retVal addObject:fixedSpace2];
    
    //check to see if the user is logged in or not
    if ([self.authenticationManager isUserAuthenticated]) {
        //we only add a notification icon for user's that have logged in
        
        //add flexible space for button spacing
        [retVal addObject:flexibleSpace];
        
        UINotificationIcon* notificationIcon = [UINotificationIcon notificationIconForPageViewControllerToolbar];
        self.tb_notificationButton = [[[UIBarButtonItem alloc]initWithCustomView:notificationIcon]autorelease];
        
        [retVal addObject:self.tb_notificationButton];
    }
    [flexibleSpace release];
    [fixedSpace1 release];
    [fixedSpace2 release];
    return retVal;
}

#pragma mark - Toolbar Button Helpers
- (void) disableFacebookButton {
    self.tb_facebookButton.enabled = NO;
}

- (void) enableFacebookButton {
    self.tb_facebookButton.enabled = YES;
}

- (void) disableTwitterButton {
    self.tb_twitterButton.enabled = NO;
}

- (void) enableTwitterButton {
    self.tb_twitterButton.enabled = YES;
}

#pragma mark - Toolbar Button Event Handlers
- (void) onFacebookButtonPressed:(id)sender {   
    //we check to ensure the user is logged in to Facebook first
    if (![self.authenticationManager isUserAuthenticated]) {
        //user is not logged in, must log in first
        [self authenticate:YES withTwitter:NO onFinishSelector:@selector(onFacebookButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            Caption* caption = [page captionWithHighestVotes];
            
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            //ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            progressView.delegate = self;

            [sharingManager shareCaptionOnFacebook:caption.objectid onFinish:nil trackProgressWith:progressView];
            [self disableFacebookButton];
        }
    }
}

- (void) onTwitterButtonPressed:(id)sender {
    //we check to ensure the user is logged in to Twitter first
    if (![self.authenticationManager isUserAuthenticated] ||
        ![[self.authenticationManager contextForLoggedInUser]hasTwitter]) {
        //user is not logged in, must log in first
        [self authenticate:NO withTwitter:YES onFinishSelector:@selector(onTwitterButtonPressed:) onTargetObject:self withObject:sender];
    }
    else {
        SocialSharingManager* sharingManager = [SocialSharingManager getInstance];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:self.pageID];
        
        if (page != nil) {
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            //ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            progressView.delegate = self;
            
            Caption* caption = [page captionWithHighestVotes];
            [sharingManager shareCaptionOnTwitter:caption.objectid onFinish:nil trackProgressWith:progressView];
            [self disableTwitterButton];
        }
    }

}

- (void) onBookmarkButtonPressed:(id)sender {
    
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    //self.pageCloudEnumerator = [[CloudEnumeratorFactory instance]enumeratorForPages];
    //self.pageCloudEnumerator.delegate = self;
    //return self;
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

#pragma mark - MBProgressHUD Delegate Methods
- (void) hudWasHidden:(MBProgressHUD *)hud 
{
        //todo: implement this
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // NSString* activityName = @"BookViewControllerBase.viewDidLoad:";
    
    self.pageCloudEnumerator = [CloudEnumerator enumeratorForPages];
    self.pageCloudEnumerator.delegate = self;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"BookViewControllerBase.viewWillAppear:";
    
    //here we check to see how many items are in the FRC, if it is 0,
    //then we initiate a query against the cloud.
    int count = [[self.frc_published_pages fetchedObjects] count];
    if (count == 0) {
        //there are no published page objects in local store, update from cloud
        //will need to thow up a progress dialog to show user of download
        LOG_BOOKVIEWCONTROLLER(0, @"%@No local drafts found, initiating query against cloud",activityName);
        [self.pageCloudEnumerator enumerateUntilEnd:nil];
        
        //TODO: need to make a call to a centrally hosted busy indicator view
    }
    
    // Toolbar: we update the toolbar items each time the view controller is shown
    NSArray* toolbarItems = [self toolbarButtonsForViewController];
    [self setToolbarItems:toolbarItems];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"BookViewController.controller.didChangeObject:";
    if (controller == self.frc_published_pages) {
        
        int count = [[self.frc_published_pages fetchedObjects]count];
        
        Resource* resource = (Resource*)anObject;
        
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            LOG_BOOKVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            
        }
        else if (type == NSFetchedResultsChangeDelete) {
            //deletion of a page
            LOG_BOOKVIEWCONTROLLER(0, @"%@deleted a resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
        }
        
    }
    else {
        LOG_BOOKVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(NSDictionary*)userInfo {
    NSString* activityName = @"BookViewController.onEnumerateComplete:";
    //on this method we need to enumerate all the captions that are part of the pages
    //to do this, we enumerate through each page and extract the finished caption ID
    //and make a fixed ID enumerate call to it.
    self.captionCloudEnumerator = nil;
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSMutableArray* captionList = [[NSMutableArray alloc]init];
    NSMutableArray* captionTypeList = [[NSMutableArray alloc]init];
    
    for (Page* page in [self.frc_published_pages fetchedObjects]) {
        if (page.finishedcaptionid != nil) {
            //we check to see if ti exists in the local store
            id caption = [resourceContext resourceWithType:CAPTION withID:page.finishedcaptionid];
            if (caption == nil) {
                //caption isnt in local store, add it to the list of captions to be downloaded
                [captionList addObject:page.finishedcaptionid];
                [captionTypeList addObject:CAPTION];
            }
           
        }
    }
    
    //at this point we have all the captions that are in the frc
    LOG_BOOKVIEWCONTROLLER(0, @"%@ Enumerating %d missing captions from the cloud",activityName,[captionList count]);
    self.captionCloudEnumerator = [CloudEnumerator enumeratorForIDs:captionList withTypes:captionTypeList];
    
    [self.captionCloudEnumerator enumerateUntilEnd:nil];
    [captionList release];
    [captionTypeList release];
}

#pragma mark - Static Initializers
+ (BookViewControllerBase*) createInstance {
    //BookViewControllerBase* instance = [[BookViewControllerBase alloc]initWithNibName:@"BookViewControllerBase" bundle:nil];
    //[instance autorelease];
    //return instance;
    
    // Determine which supported book view controller type to return
	if (NSClassFromString(@"UIPageViewController")) {
		// iOS 5 UIPageViewController style with native page curling
        BookViewControllerPageView* pageViewInstance = [[BookViewControllerPageView alloc]initWithNibName:@"BookViewControllerPageView" bundle:nil];
        [pageViewInstance autorelease];
        return pageViewInstance;
	}
    else {
		// iOS 3-4x LeaveViewController style with custom page curling
        BookViewControllerLeaves* leavesInstance = [[BookViewControllerLeaves alloc]initWithNibName:@"BookViewControllerLeaves" bundle:nil];
        [leavesInstance autorelease];
        return leavesInstance;
	}
}

+ (BookViewControllerBase*) createInstanceWithPageID:(NSNumber *)pageID {
    BookViewControllerBase* vc = [BookViewControllerBase createInstance];
    vc.pageID = pageID;
    return vc;
}


@end
