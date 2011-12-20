//
//  EditorialVotingViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EditorialVotingViewController.h"
#import "PollData.h"
#import "Attributes.h"
#import "Macros.h"
#import "Page.h"
#import "Vote.h"
#import "UIEditorialPageView.h"
#import "UIDraftTableViewCell.h"

@implementation EditorialVotingViewController
@synthesize poll            = m_poll;
@synthesize frc_pollData    = __frc_pollData;
@synthesize poll_ID         = m_pollID;
@synthesize ic_coverFlowView    = m_ic_coverFlowView;
@synthesize btn_voteButton  = m_btn_voteButton;;

#define NUMBER_OF_VISIBLE_ITEMS 6
#define ITEM_SPACING 313
//#define INCLUDE_PLACEHOLDERS YES


#pragma mark - Properties
- (NSFetchedResultsController*)frc_pollData {
    NSString* activityName = @"EditorialVotingViewController.frc_pollData:";
    
    if (__frc_pollData != nil && 
        [self.authenticationManager isUserAuthenticated]) {
        return __frc_pollData;
    }
    else if (![self.authenticationManager isUserAuthenticated] ||
             self.poll == nil) {
        __frc_pollData = nil;
        return __frc_pollData;
    }
    else {
        
        ResourceContext* resourceContext = [ResourceContext instance];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:resourceContext.managedObjectContext];
        
        
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
        
        //we need all page objects where there is a polldata object for this poll that points to that page
        NSArray* pagesInPoll = self.poll.polldata;
        
        //we go through each poll data object and add it o the predicate
        NSString* pollQuery = nil;
        NSString* targetIDAttributeName = [NSString stringWithString:OBJECTID];
        for (int i = 0; i < [pagesInPoll count];i++) {
            PollData* pollData = [pagesInPoll objectAtIndex:i];
            if (i > 0) {
                pollQuery = [NSString stringWithFormat:@"%@ OR %@=%@",pollQuery,targetIDAttributeName,pollData.targetid];
            }
            else {
                pollQuery = [NSString stringWithFormat:@"%@=%@",targetIDAttributeName,pollData.targetid];
            }
            
        }
        
        
        LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@Constructed query for poll %@:%@",activityName,self.poll.objectid,pollQuery);
        
        //now we have the query for our predicate
        NSPredicate* predicate = [NSPredicate predicateWithFormat:pollQuery];
        
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        controller.delegate = self;
        self.frc_pollData = controller;
        
        
        NSError* error = nil;
        [controller performFetch:&error];
        if (error != nil)
        {
            LOG_EDITORVOTEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        [sortDescriptor release];
        [controller release];
        [fetchRequest release];
        
        return __frc_pollData;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.wantsFullScreenLayout = YES;
        
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
    
    self.ic_coverFlowView.type = iCarouselTypeCoverFlow2;
    self.ic_coverFlowView.contentOffset = CGSizeMake(0, 10);
    
    // Navigation Bar Buttons
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.ic_coverFlowView = nil;
    self.poll = nil;
    self.poll_ID = nil;
    self.frc_pollData = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"EditorialViewController.viewWillAppear:";
    if (self.poll_ID == nil || self.poll == nil) {
        LOG_EDITORVOTEVIEWCONTROLLER(1, @"%@No poll id was passed into view controller, nothing to render",activityName);
    }
    
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // Setting the status bar orientation to landscape forces the view into landscape mode
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    
    // Set the navigationbar title
    self.navigationItem.title = @"Editorial Review Board";
    
    // Set the coverflow carousel to start at the draft in the middle
    [self.ic_coverFlowView scrollToItemAtIndex:1 animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show status bar and navigation bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [[self.frc_pollData fetchedObjects]count];
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return NUMBER_OF_VISIBLE_ITEMS;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return ITEM_SPACING;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    int draftCount = [[self.frc_pollData fetchedObjects]count];
    if (draftCount > 0 && index < draftCount) 
    {
        Page* page = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        CGRect frameForCarouselItem = CGRectMake(0, 0, 273, 268);
        
        UIEditorialPageView* carouselItem = [[[UIEditorialPageView alloc] initWithFrame:frameForCarouselItem]autorelease];
        [carouselItem renderWithPageID:page.objectid];
        
        [self.ic_coverFlowView addSubview:carouselItem];
        
        return carouselItem;
    }
    else {
        return nil;
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    // make sure the vote button is hidden until the user selects the currently centered carousel item 
    [self.btn_voteButton setHidden:YES];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    if (self.ic_coverFlowView.currentItemIndex == index) {
        // toggle show/hide of the vote button
        BOOL isVoteButtonHidden = [self.btn_voteButton isHidden];
        [self.btn_voteButton setHidden:!isVoteButtonHidden];
    }
    else {
        // make sure the vote button is hidden until the user selects the currently centered carousel item
        [self.btn_voteButton setHidden:YES];
    }
}

#pragma mark - Vote button handler 
- (IBAction)voteButtonPressed:(id)sender {    
    //called when the user clicks on a particular image on the viewslider
    
    [self.btn_voteButton setSelected:YES];
    
    NSString* activityName = @"EditorialVotingViewController.voteButtonPressed:";
    
    LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@ user has voted for the page at index %d",activityName,index);
    
    int count = [[self.frc_pollData fetchedObjects]count];
    
    int index = self.ic_coverFlowView.currentItemIndex;
    
    if (index > 0 && index < count && ![self.poll.hasvoted boolValue]) {
        //create a vote object
        
        ResourceContext* resourceContext = [ResourceContext instance];
        Page* targetPage = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        [Vote createVoteFor:self.poll_ID forTarget:targetPage.objectid withType:PAGE];
        
        //now we have a vote object
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onVoteSavedToCloud:)];
        
        //we also update the local count for the page num votes for publish
        targetPage.numberofpublishvotes =[NSNumber numberWithInt:( [targetPage.numberofpublishvotes intValue] + 1)];
        
        //we also mark the Poll object as this user having voted for it
        self.poll.hasvoted = [NSNumber numberWithBool:YES];
        
        //lets save that shit to the cloud
        [resourceContext save:YES onFinishCallback:callback trackProgressWith:nil];
        [callback release];
        
        [self dismissModalViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    else if ([self.poll.hasvoted boolValue]) {
        LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@User has already voted for this poll, skipping voting",activityName);
    }
    
}

#pragma mark - Navigation Bar button handler 
- (void)onCancelButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Async Callback Handlers
- (void) onVoteSavedToCloud:(CallbackResult*)result {
    NSString* activityName = @"EditorialVotingViewController.onVoteSavedToCloud:";
    
    //we know that we need to look at a response object
    Response* response = result.response;
    if (response.didSucceed) {
        //vote submission succeeded
        LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@Vote submission to cloud succeeded",activityName);
    }
    else {
        //error case
        LOG_EDITORVOTEVIEWCONTROLLER(1,@"%@Vote submission to cloud failed due to errorcode:%@ and errormessage:%@",activityName,response.errorCode, response.errorMessage);
    }
}


#pragma mark - Static Initializers
+ (EditorialVotingViewController*) createInstanceForPoll:(NSNumber*)pollID {
    EditorialVotingViewController* retVal = [[EditorialVotingViewController alloc]initWithNibName:@"EditorialVotingViewController" bundle:nil];
    retVal.poll_ID = pollID;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Poll* poll = (Poll*)[resourceContext resourceWithType:POLL withID:pollID];
    retVal.poll = poll;
    [retVal autorelease];
    return retVal;
}

@end
