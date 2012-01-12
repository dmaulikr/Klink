//
//  EditorialVotingViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EditorialVotingViewController.h"
#import "PollData.h"
#import "PollState.h"
#import "Attributes.h"
#import "Macros.h"
#import "Page.h"
#import "Vote.h"
#import "UIEditorialPageView.h"
#import "UIDraftTableViewCell.h"
#import "DateTimeHelper.h"
#import "PlatformAppDelegate.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"

@implementation EditorialVotingViewController
@synthesize poll            = m_poll;
@synthesize frc_pollData    = __frc_pollData;
@synthesize poll_ID         = m_pollID;
@synthesize ic_coverFlowView    = m_ic_coverFlowView;
//@synthesize btn_voteButton  = m_btn_voteButton;
@synthesize lbl_voteStatus  = m_lbl_voteStatus;
@synthesize deadline        = m_deadline;
//@synthesize userJustVoted   = m_userJustVoted;
@synthesize v_votingContainerView   = m_v_votingContainerView;
@synthesize iv_votingDraftView      = m_iv_votingDraftView;

#define ITEM_SPACING 313
//#define INCLUDE_PLACEHOLDERS YES
#define kDRAFTTITLE @"drafttitle"


#pragma mark - Deadline Date Timers
- (void) timeRemaining:(NSTimer *)timer {
    NSDate* now = [NSDate date];
    NSTimeInterval remaining = [self.deadline timeIntervalSinceDate:now];
    
    NSString* draftTitle = nil;
    if (timer.userInfo != nil) {
        draftTitle = [timer.userInfo valueForKey:kDRAFTTITLE];
    }
    
    if ([self.poll.hasvoted boolValue]) {
        self.lbl_voteStatus.text = [NSString stringWithFormat:@"Voting ends in %@. You voted for %@.", [DateTimeHelper formatTimeInterval:remaining], draftTitle];
        
    }
    else {
        self.lbl_voteStatus.text = [NSString stringWithFormat:@"Voting ends in %@", [DateTimeHelper formatTimeInterval:remaining]];
    }
}

- (NSString*) getVoteStatusStringForVote:(Vote*)vote {
    NSString* voteStatusString = nil;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    
    Page* draftVotedFor = (Page*)[resourceContext resourceWithType:PAGE withID:vote.targetid];
    NSString* draftTitle = draftVotedFor.displayname;
    
    if ([self.poll.state intValue] == kCLOSED) {
        // Show vote closed date and draft the user voted for
        voteStatusString = [NSString stringWithFormat:@"This poll closed on %@. You voted for %@.", [DateTimeHelper formatMediumDate:self.deadline], draftTitle];
    }
    else {
        // Show time since user has voted
        NSDate* now = [NSDate date];
        NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:[DateTimeHelper parseWebServiceDateDouble:vote.datecreated]];
        NSString* timeSinceVoted = nil;
        if (intervalSinceCreated < 1 ) {
            timeSinceVoted = @"a moment";
        }
        else {
            timeSinceVoted = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
        }
        
        voteStatusString = [NSString stringWithFormat:@"You voted for %@, %@ ago", draftTitle, timeSinceVoted];
    }
    
    return voteStatusString;
}


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

- (int) indexOfPageWithID:(NSNumber*)pageid {
    //returns the index location within the frc_pollData for the page with the id specified
    int retVal = -1;
    
    NSArray* fetchedObjects = [self.frc_pollData fetchedObjects];
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


#pragma mark - Initializers
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
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                   target:self
                                   action:@selector(onCancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"icon-globe.png"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onGlobeButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];

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
    self.deadline = nil;
    self.lbl_voteStatus = nil;
    self.v_votingContainerView = nil;
    self.iv_votingDraftView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* activityName = @"EditorialViewController.viewWillAppear:";
    if (self.poll_ID == nil || self.poll == nil) {
        LOG_EDITORVOTEVIEWCONTROLLER(1, @"%@No poll id was passed into view controller, nothing to render",activityName);
    }
    
    //if its the first time the user has opened the production log, we display a welcome message
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDEDITORIALVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Editorial Board" message:ui_WELCOME_EDITORIAL delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    
    // Setting the status bar orientation to landscape forces the view into landscape mode
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    
    // hide status bar
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    
    // Set the navigationbar title
    self.navigationItem.title = @"Editorial Review Board";
    
    //self.userJustVoted = NO;
    self.deadline = [DateTimeHelper parseWebServiceDateDouble:self.poll.dateexpires];
    int indexOfWinningDraft = [self indexOfPageWithID:self.poll.winningobjectid];
    
    if ([self.poll.hasvoted boolValue]) {
        // user has voted in this poll
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSArray* resourceValues = [[NSArray alloc] initWithObjects:self.poll_ID, self.loggedInUser.objectid, nil];
        NSArray* resourceAttributes = [[NSArray alloc] initWithObjects:@"pollid", @"creatorid", nil];
        
        Vote* vote = (Vote*)[resourceContext resourceWithType:VOTE withValuesEqual:resourceValues forAttributes:resourceAttributes sortBy:nil];
        
        int indexOfUserVotedDraft = [self indexOfPageWithID:vote.targetid];
        
        // Scroll to the appropriate draft and update the vote status label
        if ([self.poll.state intValue] == kCLOSED) {
            // Scroll to the winning draft
            if (indexOfWinningDraft >= 0 && indexOfWinningDraft < self.ic_coverFlowView.numberOfVisibleItems) {
                [self.ic_coverFlowView scrollToItemAtIndex:indexOfWinningDraft animated:YES];
            }
            else {
                // Set the coverflow carousel to start at the draft in the middle
                [self.ic_coverFlowView scrollToItemAtIndex:1 animated:YES];
            }
            
            // Update the vote status label
            self.lbl_voteStatus.text = [self getVoteStatusStringForVote:vote];
        }
        else {
            // Scroll to the draft that the user voted for
            if (indexOfUserVotedDraft >= 0 && indexOfUserVotedDraft < self.ic_coverFlowView.numberOfVisibleItems) {
                [self.ic_coverFlowView scrollToItemAtIndex:indexOfUserVotedDraft animated:YES];
            }
            else {
                // Set the coverflow carousel to start at the draft in the middle
                [self.ic_coverFlowView scrollToItemAtIndex:1 animated:YES];
            }
            
            // Update the vote status label with the deadline timer
            Page* draftVotedFor = (Page*)[resourceContext resourceWithType:PAGE withID:vote.targetid];
            NSString* draftTitle = draftVotedFor.displayname;
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", draftTitle] forKey:kDRAFTTITLE];
            
            self.lbl_voteStatus.text = @"";
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timeRemaining:)
                                           userInfo:userInfo
                                            repeats:YES];
            
        }
        
        [resourceValues release];
        [resourceAttributes release];
    }
    else {
        if ([self.poll.state intValue] == kCLOSED) {
            // Scroll to the winning draft
            if (indexOfWinningDraft >= 0 && indexOfWinningDraft < self.ic_coverFlowView.numberOfVisibleItems) {
                [self.ic_coverFlowView scrollToItemAtIndex:indexOfWinningDraft animated:YES];
            }
            else {
                // Set the coverflow carousel to start at the draft in the middle
                [self.ic_coverFlowView scrollToItemAtIndex:1 animated:YES];
            }
            
            self.lbl_voteStatus.text = [NSString stringWithFormat:@"This poll closed on %@. You didn't cast your vote.", [DateTimeHelper formatMediumDate:self.deadline]];
        }
        else {
            // Set the coverflow carousel to start at the draft in the middle
            [self.ic_coverFlowView scrollToItemAtIndex:1 animated:YES];
            
            // Update the vote status label with the deadline timer
            self.lbl_voteStatus.text = @"";
            [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(timeRemaining:)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // show status bar and navigation bar
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDEDITORIALVC]==NO) {
        [userDefaults setBool:YES forKey:setting_HASVIEWEDEDITORIALVC];
        [userDefaults synchronize];
    }
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Image from view object creator
- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
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
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    NSUInteger numPagesInPoll = [settings.poll_num_pages intValue];
    return numPagesInPoll;
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
        
        UIEditorialPageView* carouselItem = [[[UIEditorialPageView alloc] initWithFrame:frameForCarouselItem] autorelease];
        //UIEditorialPageView* carouselItem = [[[UIEditorialPageView alloc] init] autorelease];
        [carouselItem renderWithPageID:page.objectid withPollState:self.poll.state];
        
        [self.ic_coverFlowView addSubview:carouselItem];
        
        return carouselItem;
    }
    else {
        return nil;
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    // make sure the vote button is hidden until the user selects the currently centered carousel item
    
    // hide the vote button until scrolling ends
    //[self.btn_voteButton setAlpha:0];
    //[self.btn_voteButton setHidden:YES];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    /*// everytime the carousel moves to a new position we need to determine how to display the vote button
    if ([self.poll.hasvoted boolValue]) {
        // the user has voted in this poll already
        ResourceContext* resourceContext = [ResourceContext instance];
        
        NSArray* resourceValues = [[NSArray alloc] initWithObjects:self.poll_ID, self.loggedInUser.objectid, nil];
        NSArray* resourceAttributes = [[NSArray alloc] initWithObjects:@"pollid", @"creatorid", nil];
        
        Vote* vote = (Vote*)[resourceContext resourceWithType:VOTE withValuesEqual:resourceValues forAttributes:resourceAttributes sortBy:nil];
        
        int index = self.ic_coverFlowView.currentItemIndex;
        Page* page = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        if ([vote.targetid isEqualToNumber:page.objectid]) {
            // this is the page the user previously voted for, fade in the vote button
            [self.btn_voteButton setAlpha:0];
            [self.btn_voteButton setHidden:NO];
            
            [UIView animateWithDuration:0.35
                                  delay:0
                                options:( UIViewAnimationCurveEaseInOut )
                             animations:^{
                                 [self.btn_voteButton setAlpha:1];
                             }
                             completion:nil];
        }
        else {
            // this is not the page the user previously voted for, hide the vote button
            [self.btn_voteButton setHidden:YES];
        }
        
        [resourceValues release];
        [resourceAttributes release];
    }
    else {
        // the user has not voted in this poll yet, show the vote button for all pages
        [self.btn_voteButton setAlpha:0];
        [self.btn_voteButton setHidden:NO];
        
        [UIView animateWithDuration:0.35
                              delay:0
                            options:( UIViewAnimationCurveEaseInOut )
                         animations:^{
                             [self.btn_voteButton setAlpha:1];
                         }
                         completion:nil];
    }*/
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    NSString* activityName = @"EditorialVotingViewController.carousel:didSelectItemAtIndex:";
    
    /*//UIView* currentDraftView = [[[UIView alloc] initWithFrame:self.iv_votingDraftView.frame] autorelease];
    currentDraftView = self.ic_coverFlowView.currentItemView;
    //currentDraftView.frame = self.iv_votingDraftView.frame;
    //[self.iv_votingDraftView addSubview:currentDraftView];*/
    
    if ([carousel itemViewAtIndex:index] == self.ic_coverFlowView.currentItemView && [self.poll.state intValue] != kCLOSED) {
        if (![self.poll.hasvoted boolValue]) {
            // Create an image out of the view for the draft to be used in the voting view
            UIView* currentDraftView = self.ic_coverFlowView.currentItemView;
            UIImage* img_votingDraft = [self imageWithView:currentDraftView];
            [self.iv_votingDraftView setImage:img_votingDraft];
            
            // Fade in the vote casting view
            [self.lbl_voteStatus setAlpha:1];
            [self.v_votingContainerView setAlpha:0];
            [self.v_votingContainerView setHidden:NO];
            
            [UIView animateWithDuration:0.35
                                  delay:0.0
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 [self.lbl_voteStatus setAlpha:0];
                                 [self.v_votingContainerView setAlpha:1];
                             }
                             completion:nil];
        }
        else {
            NSString* message = nil;
            
            //notify user that they have already voted in this poll and their new vote has been dismissed
            if (self.loggedInUser) {
                message = [[NSString alloc] initWithFormat:@"%@, you have already voted in this poll.", self.loggedInUser.username];
            }
            else {
                message = [[NSString alloc] initWithFormat:@"You have already voted in this poll."];
            }
            
            LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@User has already voted in this poll, skipping voting",activityName);
            
            
            //show vote confirmation alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [message release];   
            [alert show];
            [alert release];
        }
    }
}

#pragma mark - Vote view button handlers 
- (IBAction)voteButtonPressed:(id)sender {
    NSString* activityName = @"EditorialVotingViewController.voteButtonPressed:";
    
    LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@ user has voted for the page at index %d",activityName,index);
    
    //[self.btn_voteButton setSelected:YES];

    NSString* message = nil;
    
    int count = [[self.frc_pollData fetchedObjects]count];
    
    int index = self.ic_coverFlowView.currentItemIndex;
    
    if (index >= 0 && index < count  && ![self.poll.hasvoted boolValue]) {
        
        //create a vote object
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        Page* targetPage = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        [Vote createVoteFor:self.poll_ID forTarget:targetPage.objectid withType:PAGE];
        
        //now we have a vote object
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onVoteSavedToCloud:)];
        callback.fireOnMainThread = YES;
        
        //we also update the local count for the page num votes for publish
        targetPage.numberofpublishvotes =[NSNumber numberWithInt:([targetPage.numberofpublishvotes intValue] + 1)];
        
        //we also mark the Poll object as this user having voted for it
        self.poll.hasvoted = [NSNumber numberWithBool:YES];
        //self.userJustVoted = YES;
        
        //lets save that shit to the cloud
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        progressView.delegate = self;
        [resourceContext save:YES onFinishCallback:callback trackProgressWith:progressView];
        [callback release];
        
        /*//notify user that their vote has been casted
        if (self.loggedInUser) {
            message = [[NSString alloc] initWithFormat:@"Thank you, %@, your vote has been cast.", self.loggedInUser.username];
        }
        else {
            message = [[NSString alloc] initWithFormat:@"Thank you, your vote has been cast."];
        }*/
        
        //lets display the progress view
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        [self showDeterminateProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        [message release];
        
    }
    else if ([self.poll.hasvoted boolValue]) {
        //notify user that they have already voted in this poll and their new vote has been dismissed
        if (self.loggedInUser) {
            message = [[NSString alloc] initWithFormat:@"%@, you have already voted for this poll.", self.loggedInUser.username];
        }
        else {
            message = [[NSString alloc] initWithFormat:@"You have already voted for this poll."];
        }
        
        LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@User has already voted for this poll, skipping voting",activityName);
        
        //show vote confirmation alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
        [message release];   
        [alert show];
        [alert release];
    }

}

- (IBAction)cancelVoteButtonPressed:(id)sender {    
    // Fade out the vote casting view
    [self.lbl_voteStatus setAlpha:0];
    [self.v_votingContainerView setAlpha:1];
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [self.lbl_voteStatus setAlpha:1];
                         [self.v_votingContainerView setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self.v_votingContainerView setHidden:YES];
                     }];
    
}

#pragma mark - MBProgressHUDDelegate
- (void) hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"EditorialVotingViewController.hudWasHidden";
    //we dismiss this controller if the operation succeeded
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    if (progressView.didSucceed) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        //otherwise we keep the current view open
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        //we unmark the userJustVoted flag so the user can try again
        //self.userJustVoted = NO;
        
        //now we need to display an alert telling the user their vote couldn't be cast and to try again
        NSString* message = [NSString stringWithFormat:@"Sorry, there was an error sending your vote to the server. Please try again."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
}

#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    /*if (self.userJustVoted) {
        [self dismissModalViewControllerAnimated:YES];
    }*/
}

#pragma mark - Navigation Bar button handler 
- (void)onCancelButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onGlobeButtonPressed:(id)sender {    
    // Here we should show the message with instructions
}

#pragma mark - Async Callback Handlers
- (void) onVoteSavedToCloud:(CallbackResult*)result {
    NSString* activityName = @"EditorialVotingViewController.onVoteSavedToCloud:";
    
    //we know that we need to look at a response object
    Response* response = result.response;
    
    if (response.didSucceed) {
        //vote submission succeeded
        LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@Vote submission to cloud succeeded",activityName);
        
        /*ResourceContext* resourceContext = [ResourceContext instance];
        
        NSArray* resourceValues = [[NSArray alloc] initWithObjects:self.poll_ID, self.loggedInUser.objectid, nil];
        NSArray* resourceAttributes = [[NSArray alloc] initWithObjects:@"pollid", @"creatorid", nil];
        
        Vote* vote = (Vote*)[resourceContext resourceWithType:VOTE withValuesEqual:resourceValues forAttributes:resourceAttributes sortBy:nil];
        
        // Update the vote status label 
        self.lbl_voteStatus.text = [self getVoteStatusStringForVote:vote];
        
        [resourceValues release];
        [resourceAttributes release];*/
        
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
