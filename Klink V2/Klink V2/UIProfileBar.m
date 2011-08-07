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
@implementation UIProfileBar
@synthesize lbl_rank;
@synthesize lbl_votes;
@synthesize lbl_captions;
@synthesize frc_loggedInUser = __frc_loggedInUser;
@synthesize frc_feed_photovotes=__frc_feed_photovotes;
@synthesize frc_feed_captionvotes = __frc_feed_captionvotes;
@synthesize lbl_new_votes;
@synthesize lbl_new_captions;

- (void)updateLabels {
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    if ([authnManager isUserLoggedIn] == YES) {
        User* user = [[self.frc_loggedInUser fetchedObjects]objectAtIndex:0];
        self.lbl_captions.text  = [user.numberofcaptions stringValue];
        self.lbl_rank.text = [user.rank stringValue];
        self.lbl_votes.text = [user.numberofvotes stringValue];
        
        int newCaptions = [[self.frc_feed_captionvotes fetchedObjects]count];
        int newVotes = [[self.frc_feed_photovotes fetchedObjects]count];

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

- (NSFetchedResultsController*)frc_feed_captionvotes {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_feed_captionvotes = nil;
        return nil;
    }
    
    if (__frc_feed_captionvotes != nil) {
        return __frc_feed_captionvotes;
    }
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_CAPTION_VOTE],authenticationManager.m_LoggedInUserID, nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feed_captionvotes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_captionvotes;
    
}

- (NSFetchedResultsController*)frc_feed_photovotes {
    AuthenticationManager* authenticationManager = [AuthenticationManager getInstance];
    
    if ([authenticationManager isUserLoggedIn]==NO) {
        __frc_feed_photovotes = nil;
        return nil;
    }
    
    if (__frc_feed_photovotes != nil) {
        return __frc_feed_photovotes;
    }
    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tn_FEED inManagedObjectContext:appContext];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type=%@ AND userid=%@" argumentArray:[NSArray arrayWithObjects:[NSNumber numberWithInt:feed_PHOTO_VOTE],authenticationManager.m_LoggedInUserID, nil]];
    
    
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:an_OBJECTID ascending:NO];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:appContext sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    
    self.frc_feed_photovotes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    [controller release];
    [fetchRequest release];
    
    
    return __frc_feed_photovotes;

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
                
        
        //register for global events
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedIn:) name:n_USER_LOGGED_IN object:nil];
        [notificationCenter addObserver:self selector:@selector(onUserLoggedOut:) name:n_USER_LOGGED_OUT object:nil];
        
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
    [self.frc_feed_photovotes release];
    [self.frc_feed_captionvotes release];
    [self.frc_loggedInUser release];
    [self.lbl_new_captions release];
    [self.lbl_new_votes release];
    [self.lbl_captions release];
    [self.lbl_rank release];
    [self.lbl_votes release];
    [super dealloc];
}

#pragma mark - System Event Handlers
-(void)onUserLoggedIn:(NSNotification*)notification {
    [self updateLabels];
}

-(void)onUserLoggedOut:(NSNotification*)notification {
    self.frc_loggedInUser = nil;
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

-(void) onNewPhotoFeedItem:(Feed*)feed {
    //need to get a total count of Feed items of this type
    [self updateLabels];
}

-(void) onNewCaptionFeedItem:(Feed*)feed {
    [self updateLabels];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    if (controller == self.frc_feed_captionvotes) {
        if (type == NSFetchedResultsChangeInsert) {
            Feed* feed = (Feed*)anObject;
            [self onNewCaptionFeedItem:feed];
        }
    }
    else if (controller == self.frc_feed_photovotes) {
        if (type == NSFetchedResultsChangeInsert) {
            Feed* feed = (Feed*)anObject;
            [self onNewPhotoFeedItem:feed];
        }
    }
    else if (controller == self.frc_loggedInUser) {
        User* user = (User*)anObject;
        
        if (type == NSFetchedResultsChangeUpdate) {
            [self onUserUpdated:user];
        }
    }
    
        
    
}


@end
