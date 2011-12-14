//
//  EditorialVotingViewController.m
//  Platform
//
//  Created by Jasjeet Gill on 12/12/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "EditorialVotingViewController.h"
#import "Poll.h"
#import "PollData.h"
#import "Attributes.h"
#import "Macros.h"
#import "UIPagedViewSlider4.h"
#import "ImageManager.h"
#import "Page.h"
#import "Photo.h"
#import "Caption.h"
#import "UIVotePageView.h"
#import "Vote.h"
#import "Types.h"
#import "Response.h"

@implementation EditorialVotingViewController
@synthesize pagedViewSlider = m_pagedViewSlider;
@synthesize poll = m_poll;
@synthesize frc_pollData = __frc_pollData;
@synthesize poll_ID = m_pollID;

#define kITEM_WIDTH    150
#define kITEM_HEIGHT   150
#define kITEM_SPACING  10

#define kPHOTOID @"photoid"

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

- (id)commonInit {
    // Custom initialization
    self.pagedViewSlider.delegate = self;
    self.pagedViewSlider.tableView.pagingEnabled = YES;
    [self.pagedViewSlider initWithWidth:kITEM_WIDTH withHeight:kITEM_HEIGHT withSpacing:kITEM_SPACING useCellIdentifier:@"photo"]; 
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)dealloc
{
    self.poll = nil;
    self.pagedViewSlider = nil;
    
    [super dealloc];
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
    
    [self commonInit];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    NSString* activityName = @"EditorialViewController.viewWillAppear:";
    [super viewWillAppear:animated];
     
    if (self.poll_ID == nil || self.poll == nil) {
        LOG_EDITORVOTEVIEWCONTROLLER(1, @"%@No poll id was passed into view controller, nothing to render",activityName);
    }

    
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - NSFetchedResultsControllerDelegate
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //on insert of a new object
        [self.pagedViewSlider onNewItemInsertedAt:[newIndexPath row]];
    }
}

#pragma mark - UIPagedViewSlider2Delegate
- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider selectIndex:(int)index {
    //called when the user clicks on a particular image on the viewslider
    NSString* activityName = @"EditorialVotingViewController.selectIndex:";
    
    LOG_EDITORVOTEVIEWCONTROLLER(0, @"%@ user has voted for the page at index %d",activityName,index);
    
    int count = [[self.frc_pollData fetchedObjects]count];
    if (index > 0 && 
        index < count &&
        ![self.poll.hasvoted boolValue]) {
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
        [resourceContext save:YES onFinishCallback:callback];
        [callback release];
    }
}

- (UIView*) viewSlider:(UIPagedViewSlider2 *)viewSlider cellForRowAtIndex:(int)index withFrame:(CGRect)frame {
    
    int photoCount = [[self.frc_pollData fetchedObjects]count];
    if (photoCount > 0 && index < photoCount) {
        Page* page = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        //now we make the view
        CGRect frameForView = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIVotePageView* v = [[UIVotePageView alloc]initWithFrame:frameForView withPhotoID:page.objectid forPoll:self.poll.objectid];
       
        [self viewSlider:viewSlider configure:v forRowAtIndex:index withFrame:frame];
        [v autorelease];
        return v;
    }
    return nil;
}

- (void) viewSlider:(UIPagedViewSlider2 *)viewSlider configure:(UIVotePageView *)existingCell forRowAtIndex:(int)index withFrame:(CGRect)frame {
    
    int photoCount = [[self.frc_pollData fetchedObjects]count];
    if (photoCount > 0 && index < photoCount) {
        Page* page = [[self.frc_pollData fetchedObjects]objectAtIndex:index];
        
        [existingCell renderWithPage:page.objectid forPoll:self.poll.objectid];
        
    }
    
}

- (int) itemCountFor:(UIPagedViewSlider2 *)viewSlider {
    return [[self.frc_pollData fetchedObjects]count];
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
