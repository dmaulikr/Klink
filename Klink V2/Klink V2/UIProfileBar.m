//
//  UIProfileBar.m
//  Klink V2
//
//  Created by Bobby Gill on 7/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProfileBar.h"
#import "NotificationNames.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "FeedTypes.h"
#import "Feed.h"
#import "FeedManager.h"
#import "FeedViewController.h"

@implementation UIProfileBar
@synthesize lbl_rank;
@synthesize lbl_votes;
@synthesize lbl_captions;
@synthesize frc_loggedInUser = __frc_loggedInUser;
@synthesize lbl_new_votes;
@synthesize lbl_new_captions;
@synthesize viewController = m_viewController;

- (void)updateLabels {
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    if ([authnManager isUserLoggedIn] == YES) {
        User* user = [[self.frc_loggedInUser fetchedObjects]objectAtIndex:0];
        FeedManager* feedManager = [FeedManager getInstance];
        
        self.lbl_captions.text  = [user.numberofcaptions stringValue];
        self.lbl_rank.text = [user.rank stringValue];
        self.lbl_votes.text = [user.numberofvotes stringValue];
        
        int newCaptionVotes = [feedManager.numberOfNewCaptionVotesInFeed intValue];
        int newPhotoVotes = [feedManager.numberOfNewPhotoVotesInFeed intValue];
        int newVotes = newCaptionVotes + newPhotoVotes;
        
        int newCaptions = [feedManager.numberOfNewCaptionsInFeed intValue];
        if (newCaptions == 0) {
            self.lbl_new_captions.text = [NSString stringWithFormat:@""];
        }
        else {
            self.lbl_new_captions.text = [NSString stringWithFormat:@"%d new",newCaptions];
        }
        
        
        if (newVotes == 0) {
            self.lbl_new_votes.text = [NSString stringWithFormat:@""];
        }
        else {
            self.lbl_new_votes.text = [NSString stringWithFormat:@"%d new",newVotes];
        }
        
        [self.lbl_new_captions setNeedsDisplay];
        [self.lbl_new_votes setNeedsDisplay];
        [self.lbl_captions setNeedsDisplay];
        [self.lbl_votes setNeedsDisplay];
        [self.lbl_rank setNeedsDisplay];
    }
}


- (NSFetchedResultsController*)frc_loggedInUser {
    
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_loggedInUser = nil;
        return nil;
    }
    
    if (__frc_loggedInUser != nil) {
        return __frc_loggedInUser;
    }

   
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:USER inManagedObjectContext:appContext];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"objectid=%@",authenticationManager.m_LoggedInUserID];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_loggedInUser = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];

    
    return __frc_loggedInUser;
    
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UIProfileBar" owner:self options:nil];
        
        UIView* profileBar = [bundle objectAtIndex:0];
        [self addSubview:profileBar];
        self.userInteractionEnabled = YES;
//        CGRect frameForButton = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//        UIButton *button = [[UIButton alloc]initWithFrame:frameForButton];
//        [button addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventAllEvents];
//        [self addSubview:button];
        
//        [button release];
        
        //register for global events
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
        [notificationCenter addObserver:self selector:@selector(onNewCaptionVoteFeedItem:) name:n_NEW_FEED_CAPTION_VOTE object:nil];
        [notificationCenter addObserver:self selector:@selector(onNewPhotoVoteFeedItem:) name:n_NEW_FEED_PHOTO_VOTE object:nil];
        [notificationCenter addObserver:self selector:@selector(onNewCaptionFeedItem:) name:n_NEW_FEED_CAPTION object:nil];
        [notificationCenter addObserver:self selector:@selector(onFeedItemRead:) name:n_FEED_ITEM_CLEARED object:nil];
        [self updateLabels];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [self.frc_loggedInUser release];
    [self.lbl_new_captions release];
    [self.lbl_new_votes release];
    [self.lbl_captions release];
    [self.lbl_rank release];
    [self.lbl_votes release];
    [super dealloc];
}

#pragma mark - Tap handler
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.viewController != nil) {
        FeedViewController* fvc = [[FeedViewController alloc]init];
        [self.viewController.navigationController pushViewController:fvc animated:YES];
    }
}


#pragma mark - System Event Handlers
- (void) onFeedItemRead : (NSNotification*)notification {
    [self updateLabels];
}
-(void)onUserLoggedIn:(NSNotification*)notification {
    [self updateLabels];
}

-(void)onUserLoggedOut:(NSNotification*)notification {
    self.frc_loggedInUser = nil;
}

- (void)onNewCaptionFeedItem:(NSNotification*)notification {
    [self updateLabels];
}

-(void) onNewCaptionVoteFeedItem:(NSNotification*)notification {
       [self updateLabels];    
}

-(void) onNewPhotoVoteFeedItem:(NSNotification*)notification {
    [self updateLabels];
}

- (void) onUserUpdated:(User*)user {
    
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    
    if ([authnManager isUserLoggedIn]==YES &&
        [user.objectid isEqualToNumber:authnManager.m_LoggedInUserID]) {
        
        
            //at this point we know the user object has changed, now lets update the scores
            self.lbl_captions.text  = [user.numberofcaptions stringValue];
            self.lbl_rank.text = [user.rank stringValue];
            self.lbl_votes.text = [user.numberofvotes stringValue];
        
    }

}




@end
