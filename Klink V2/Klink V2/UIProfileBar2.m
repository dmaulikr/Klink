//
//  UIProfileBar2.m
//  Klink V2
//
//  Created by Jordan Gurrieri on 10/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UIProfileBar2.h"
#import "CameraButtonManager.h"
//#import "NotificationNames.h"
//#import "AuthenticationManager.h"
#import "User.h"
//#import "FeedTypes.h"
//#import "Feed.h"
#import "FeedManager.h"
//#import "FeedViewController.h"
#import "ImageManager.h"


@implementation UIProfileBar2

@synthesize lbl_userName;
@synthesize lbl_votes;
@synthesize lbl_captions;
@synthesize lbl_new_votes;
@synthesize lbl_new_captions;
@synthesize img_profilePic;
@synthesize btn_cameraButton;
@synthesize viewController = m_viewController;
@synthesize frc_loggedInUser = __frc_loggedInUser;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/


- (void)updateLabels {
    AuthenticationManager* authnManager = [AuthenticationManager getInstance];
    if ([authnManager isUserLoggedIn] == YES) {
        User* user = [[self.frc_loggedInUser fetchedObjects]objectAtIndex:0];
        
        self.lbl_userName.text = user.username;
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:self.img_profilePic forKey:an_IMAGEVIEW];
        UIImage* profileImage = [[ImageManager getInstance] downloadImage:user.thumbnailURL withUserInfo:userInfo atCallback:self];
        [self.img_profilePic setImage:profileImage];
        
        self.lbl_captions.text  = [user.numberofcaptions stringValue];
        self.lbl_votes.text = [user.numberofvotes stringValue];
        
        FeedManager* feedManager = [FeedManager getInstance];
        
        int newCaptionVotes = [feedManager.numberOfNewCaptionVotesInFeed intValue];
        int newPhotoVotes = [feedManager.numberOfNewPhotoVotesInFeed intValue];
        int newVotes = newCaptionVotes + newPhotoVotes;
        
        int newCaptions = [feedManager.numberOfNewCaptionsInFeed intValue];
        if (newCaptions == 0) {
            self.lbl_new_captions.text = [NSString stringWithFormat:@""];
        }
        else {
            self.lbl_new_captions.text = [NSString stringWithFormat:@"%d",newCaptions];
        }
        
        
        if (newVotes == 0) {
            self.lbl_new_votes.text = [NSString stringWithFormat:@""];
        }
        else {
            self.lbl_new_votes.text = [NSString stringWithFormat:@"%d",newVotes];
        }
        
        [self.lbl_new_captions setNeedsDisplay];
        [self.lbl_new_votes setNeedsDisplay];
        [self.lbl_captions setNeedsDisplay];
        [self.lbl_votes setNeedsDisplay];
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
        NSArray* bundle =  [[NSBundle mainBundle] loadNibNamed:@"UIProfileBar2" owner:self options:nil];
        
        UIView* profileBar2 = [bundle objectAtIndex:0];
        
        // Add custom backgound image to the view
        //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background-toolbar-black.png"]];
        //profileBar2.backgroundColor = background;
        //[background release];
        
        [self addSubview:profileBar2];
        //self.userInteractionEnabled = YES;
        
        
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

- (void)dealloc
{
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
    [self.frc_loggedInUser release];
    [lbl_userName release];
    [lbl_votes release];
    [lbl_captions release];
    [self.lbl_new_captions release];
    [self.lbl_new_votes release];
    [img_profilePic release];
    [btn_cameraButton release];
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.lbl_userName = nil;
    self.lbl_votes = nil;
    self.lbl_captions = nil;
    self.img_profilePic = nil;
    self.btn_cameraButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Handlers

- (IBAction) onCameraButtonPressed:(id)sender {
    CameraButtonManager* cameraButtonManager = [CameraButtonManager getInstanceWithViewController:self.viewController];
    [cameraButtonManager cameraButtonPressed:self];
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
        self.lbl_votes.text = [user.numberofvotes stringValue];
        
    }
    
}


@end
