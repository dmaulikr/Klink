//
//  RequestSummaryViewController.m
//  Platform
//
//  Created by Jasjeet Gill on 5/30/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "RequestSummaryViewController.h"
#import "AuthenticationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "LeaderboardEntry.h"
#import "LeaderboardViewController.h"
#import "ObjectChange.h"
#import "Achievement.h"
#import "ImageManager.h"
#import "AchievementsViewController.h"
#import "Flurry.h"
#import "UITutorialView.h"
#import "UserDefaultSettings.h"

@implementation RequestSummaryViewController
@synthesize user                        = m_user;
@synthesize userID                      = m_userID;
@synthesize v_pointsProgressBar         = m_v_pointsProgressBar;
@synthesize lbl_pbUpdating              = m_lbl_pbUpdating;
@synthesize v_leaderboard3Up            = m_v_leaderboard3Up;
@synthesize btn_leaderboard3UpButton    = m_btn_leaderboard3UpButton;
@synthesize v_leaderboardContainer      = m_v_leaderboardContainer;
@synthesize iv_progressDrafts           = m_iv_progressDrafts;
@synthesize iv_progressPhotos           = m_iv_progressPhotos;
@synthesize iv_progressPoints           = m_iv_progressPoints;
@synthesize iv_progressCaptions         = m_iv_progressCaptions;
@synthesize iv_progressBarContainer     = m_iv_progressBarContainer;
@synthesize request                     = m_request;
@synthesize friendsLeaderboardCloudEnumerator   = m_friendsLeaderboardCloudEnumerator;
@synthesize friendsLeaderboard          = m_friendsLeaderboard;
@synthesize v_scoreChangeView           = m_v_scoreChangeView;
@synthesize v_scoreChangeContainer      = m_v_scoreChangeContainer;
@synthesize v_achievementsContainer     = m_v_achievementsContainer;
@synthesize v_newAchievementContainer   = m_v_newAchievementContainer;
@synthesize v_noNewAchievementContainer = m_v_noNewAchievementContainer;
@synthesize lbl_achievementTitle        = m_lbl_achievementTitle;
@synthesize iv_achievementImage         = m_iv_achievementImage;
@synthesize userCloudEnumerator      = m_userCloudEnumerator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];
    
    // Add a done button to the navigation bar
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onDoneButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.friendsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kPEOPLEIKNOW];
    self.friendsLeaderboardCloudEnumerator.delegate = self;
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.v_pointsProgressBar = nil;
    self.lbl_pbUpdating = nil;
    self.v_leaderboardContainer = nil;
    self.v_leaderboard3Up = nil;
    self.v_scoreChangeView = nil;
    self.btn_leaderboard3UpButton = nil;
    self.iv_progressBarContainer = nil;
    self.iv_progressDrafts = nil;
    self.iv_progressPhotos = nil;
    self.iv_progressCaptions = nil;
    self.iv_progressPoints = nil;
    self.iv_achievementImage = nil;
    self.lbl_achievementTitle = nil;
    self.v_scoreChangeContainer = nil;
    self.v_achievementsContainer = nil;
    self.v_newAchievementContainer = nil;
    self.v_noNewAchievementContainer = nil;
}

- (void) enumerateUser:(NSNumber*)userid 
{
    if (self.userCloudEnumerator != nil) {
        [self.userCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.userCloudEnumerator = nil;
        self.userCloudEnumerator = [CloudEnumerator enumeratorForUser:userid];
        self.userCloudEnumerator.delegate = self;
        [self.userCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateLeaderboards:(NSNumber*)userid 
{
        
    self.friendsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kPEOPLEIKNOW];
    self.friendsLeaderboardCloudEnumerator.delegate = self;
    
    [self.friendsLeaderboardCloudEnumerator enumerateUntilEnd:nil];
}

- (BOOL) didEarnNewAchievement {
    //returns a boolean indicating whether the user earned a new achievement
    //fromt he request stored internally
    BOOL retVal = NO;
    NSArray* consequentialInserts = self.request.consequentialInserts;
    
    if (consequentialInserts != nil &&
        [consequentialInserts count] > 0) 
    {
        //we check if any of the consequential inserts were achievements objects
        for (ObjectChange* oc in consequentialInserts)
        {
            if ([oc.targetobjecttype isEqualToString:ACHIEVEMENT])
            {
                //we have an achievement
                retVal = YES;
                break;
            }
        }
        
    }

    return retVal;
}

- (NSArray*) achievementsEarnedInRequest 
{
    //returns an array containing all achievements earned from this request
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    for (ObjectChange* oc in self.request.consequentialInserts)
    {
        if ([oc.targetobjecttype isEqualToString:ACHIEVEMENT])
        {
            Achievement* achievement = (Achievement*)[resourceContext resourceWithType:ACHIEVEMENT withID:oc.targetobjectid];
            
            //lets check to make sure achievement was earned by current logged in user
            if ([achievement.userid isEqualToNumber:self.userID])
            {
                //yes this eachievement was earned by the current user
                [retVal addObject:achievement];
            }
        }
    }
    return retVal;
}

//this method will analyze the request and display any achievement related information to the user
- (void) renderAchievements {
    [self.lbl_pbUpdating setHidden:YES];
    
    //we first see if the user has gained any achievements at all
    
    BOOL didEarnAchievement = [self didEarnNewAchievement];
    NSArray* achievements = [self achievementsEarnedInRequest];
    
    if (didEarnAchievement &&
        [achievements count] > 0)
    {
        //we have a new achievement to render to the user
        self.v_noNewAchievementContainer.hidden = YES;
        self.v_newAchievementContainer.hidden = NO;
        
        Achievement* firstAchievement = [achievements objectAtIndex:0];
        
        ImageManager* imageManager = [ImageManager instance];
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:firstAchievement.objectid forKey:OBJECTID];            
        Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onAchievementImageDownloaded:) fireOnMainThread:YES];
        imageCallback.context = userInfo;
        
        UIImage* image = [imageManager downloadImage:firstAchievement.imageurl withUserInfo:nil atCallback:imageCallback];
        
        if (image != nil) 
        {
            //we found the image in the local cache
            self.iv_achievementImage.image = image;
        }

        if ([achievements count] > 1)
        {
            //earned more than one achievement
                        
            //we set the title
            self.lbl_achievementTitle.text = [NSString stringWithFormat:@"Nice Bahndring, you just earned %d new mallards for your hard work!",[achievements count]];
            
        }
        else if ([achievements count] == 1)
        {
            //earned only one achievement
            if ([firstAchievement.type intValue] == 0) 
            {
                //for regular point threshold rewards
                self.lbl_achievementTitle.text = [NSString stringWithFormat:@"You just earned the %@ mallard!",firstAchievement.title];
            }
            else 
            {
                //for editor achievements and other non point threshold rewards
                self.lbl_achievementTitle.text = [NSString stringWithFormat:@"%@",firstAchievement.title];
            }
        }
        [userInfo release];
    }
    else {
        //we do not have any new achievements to show to the user
        self.v_newAchievementContainer.hidden = YES;
        self.v_noNewAchievementContainer.hidden = NO;
        
        //let us render the progress bar
        CGRect frame = self.v_pointsProgressBar.frame;
        [self.v_pointsProgressBar removeFromSuperview]; // remove any previously displayed progress bar views
        UIPointsProgressBar* progressBar = [[UIPointsProgressBar alloc] initWithFrame:frame];
        [progressBar renderProgressBarForUserWithID:self.userID];
        self.v_pointsProgressBar = progressBar;
        [self.v_noNewAchievementContainer addSubview:self.v_pointsProgressBar];
        [progressBar release];
    }
    
    // Create gesture recognizer for the achievements container to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAchievements)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the achievements and progress bar containers
    [self.v_achievementsContainer addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the achievements and progress bar containers
    [self.v_achievementsContainer setUserInteractionEnabled:YES];
    
}

- (void) render {
    //we then need to render the score change view
    CGRect frame = self.v_scoreChangeView.frame;
    [self.v_scoreChangeView removeFromSuperview]; // remove any previously displayed views
    UIScoreChangeView* scoreChangeView = [[UIScoreChangeView alloc]initWithFrame:frame];
    self.v_scoreChangeView = scoreChangeView;
    [scoreChangeView release];
    [scoreChangeView renderCompletedRequest:self.request];
    [self.v_scoreChangeContainer addSubview:self.v_scoreChangeView];
    
    //we then need to render the achievements view
    [self renderAchievements];
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    // Set title
    CGSize labelSize = [@"Success!" sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"Success!";
    titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];

    // Add rounded corners to leaderboard custom button
    self.btn_leaderboard3UpButton.layer.cornerRadius = 8;
    [self.btn_leaderboard3UpButton.layer setMasksToBounds:YES];
    
    // Set highlight state background color of leaderboard custom buttons
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *lightGreyImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.btn_leaderboard3UpButton setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
    
    // Ensure we have the latest data for this user
    [self enumerateUser:self.userID];
    
    [self enumerateLeaderboards:self.userID];
    
    [self render];
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"VIEWING_REQUESTSUMMARYVIEW" timed:YES];
    
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDREQUESTSUMMARYVC]==NO) 
    {
        [self onInfoButtonPressed:nil];
        [userDefaults setBool:YES forKey:setting_HASVIEWEDREQUESTSUMMARYVC];
        [userDefaults synchronize];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"VIEWING_REQUESTSUMMARYVIEW" withParameters:nil];
    
    // Remove the subviews added in viewWillAppear because they will be rendered again when the view reappears
    [self.v_scoreChangeView removeFromSuperview];
    [self.v_pointsProgressBar removeFromSuperview];
    //    [self.v_leaderboard3Up removeFromSuperview];
    //    [self.btn_leaderboard3UpButton removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void) onDoneButtonPressed: (id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onInfoButtonPressed:(id)sender {
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewRequestSummary"];
    infoView.view.frame = self.view.frame;
    [self.view addSubview:infoView];
    [infoView release];
}


- (void) showLeaderBoardOfType:(int)type {
    CGRect frame = self.v_leaderboard3Up.frame;
    
    UILeaderboard3Up* leaderboard = [[UILeaderboard3Up alloc] initWithFrame:frame];
    self.v_leaderboard3Up = leaderboard;
    [leaderboard release];
    
    if (type == kPEOPLEIKNOW) {
        // We need to build the array of leaderboard entries for the 3upLeaderboard on the profile
        NSMutableArray *threeUpEntryArray = [[NSMutableArray alloc]init];
        
        int count = [self.friendsLeaderboard.entries count];
        
        LeaderboardEntry *entry;
        
        for (int i = 0; i < self.friendsLeaderboard.entries.count; i++) {
            
            entry = [self.friendsLeaderboard.entries objectAtIndex:i];
            
            if ([self.authenticationManager isUserAuthenticated] && self.loggedInUser != nil) {
                // We search for the index of the logged in user's entry, then take the entry before and after that index
                if ([entry.userid isEqualToNumber:self.loggedInUser.objectid]) {
                    int k = i - 1;
                    int j = i + 1;
                    LeaderboardEntry* entry1 = nil;
                    LeaderboardEntry* entry2 = nil;
                    LeaderboardEntry* entry3 = nil;
                    
                    
                    if (k >= 0) {
                        entry1 = [self.friendsLeaderboard.entries objectAtIndex:k];
                        [threeUpEntryArray addObject:entry1];
                    }
                    
                    [threeUpEntryArray addObject:entry];
                    
                    if (j < [self.friendsLeaderboard.entries count])
                    {
                        entry2 = [self.friendsLeaderboard.entries objectAtIndex:j];
                        [threeUpEntryArray addObject:entry2];
                    }
                    
                    if (i == 0 && count >= 3) {
                        // User is the leader
                        entry3 = [self.friendsLeaderboard.entries objectAtIndex:i + 2];
                        [threeUpEntryArray addObject:entry3];
                    }
                    
                    [self.v_leaderboard3Up renderLeaderboardWithEntries:threeUpEntryArray forLeaderboard:self.friendsLeaderboard.objectid forUserWithID:self.loggedInUser.objectid];
                    
                    break;
                }
            }
            else {
                // We search for the index of this user profile in user's entry, then take the entry before and after that index
                if ([entry.userid isEqualToNumber:self.userID]) {
                    int k = i - 1;
                    int j = i + 1;
                    LeaderboardEntry* entry1 = nil;
                    LeaderboardEntry* entry2 = nil;
                    LeaderboardEntry* entry3 = nil;
                    
                    
                    if (k >= 0) {
                        entry1 = [self.friendsLeaderboard.entries objectAtIndex:k];
                        [threeUpEntryArray addObject:entry1];
                    }
                    
                    [threeUpEntryArray addObject:entry];
                    
                    if (j < [self.friendsLeaderboard.entries count])
                    {
                        entry2 = [self.friendsLeaderboard.entries objectAtIndex:j];
                        [threeUpEntryArray addObject:entry2];
                    }
                    
                    if (i == 0 && count >= 3) {
                        // User is the leader
                        entry3 = [self.friendsLeaderboard.entries objectAtIndex:i + 2];
                        [threeUpEntryArray addObject:entry3];
                    }
                    
                    [self.v_leaderboard3Up renderLeaderboardWithEntries:threeUpEntryArray forLeaderboard:self.friendsLeaderboard.objectid forUserWithID:self.userID];
                    
                    break;
                }
            }
        }
        
        [threeUpEntryArray release];
    }
    
    // Reset the frame of the leaderboard button height now that the leaderboard has been rendered
    CGRect leaderboardButtonFrame = CGRectMake(self.btn_leaderboard3UpButton.frame.origin.x, self.btn_leaderboard3UpButton.frame.origin.y, self.btn_leaderboard3UpButton.frame.size.width, self.v_leaderboard3Up.view.frame.size.height);
    [self.btn_leaderboard3UpButton setFrame:leaderboardButtonFrame];
    
    // Make sure any previous subviews of this type are not present
    [self.v_leaderboard3Up removeFromSuperview];
    [self.btn_leaderboard3UpButton removeFromSuperview];
    
    // Add these subviews to the view
    
    [self.v_leaderboardContainer addSubview:self.v_leaderboard3Up];
    [self.v_leaderboardContainer addSubview:self.btn_leaderboard3UpButton];
}

- (IBAction) onLeaderboardButtonPressed:(id)sender
{
    //called when a user clicks on the leaderboard button
    LeaderboardViewController* leaderBoardViewController = [LeaderboardViewController createInstanceFor:self.friendsLeaderboard.objectid forUserID:self.userID];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Summary" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    [self.navigationController pushViewController:leaderBoardViewController animated:YES];
}

- (void)showAchievements {
    AchievementsViewController* achievementsViewController;
    
    // We need to determine if an achievement should be preloaded
    BOOL didEarnAchievement = [self didEarnNewAchievement];
    NSArray* achievements = [self achievementsEarnedInRequest];
    
    if (didEarnAchievement && [achievements count] > 0) {
        Achievement* firstAchievement = [achievements objectAtIndex:0];
        
        achievementsViewController = [AchievementsViewController createInstanceForUserWithID:self.userID preloadedWithAchievementIDorNil:firstAchievement.objectid];
    }
    else {
        achievementsViewController = [AchievementsViewController createInstanceForUserWithID:self.userID];
    }
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:achievementsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

#pragma mark - ImageManager call back
- (void) onAchievementImageDownloaded:(CallbackResult*)callbackResult
{
    //the image for the achievement has been downloaded
    NSDictionary* userInfo = callbackResult.context;
    NSNumber* objectID = [userInfo valueForKey:OBJECTID];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (objectID != nil) {
        Achievement* achievementObject = (Achievement*)[resourceContext resourceWithType:ACHIEVEMENT withID:objectID];
        if (achievementObject != nil)
        {
            ImageManager* imageManager = [ImageManager instance];
            UIImage* image = [imageManager downloadImage:achievementObject.imageurl withUserInfo:nil atCallback:nil];
            self.iv_achievementImage.image = image;
        }
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator *)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    ResourceContext* resourceContext = [ResourceContext instance];
    if (enumerator == self.userCloudEnumerator) {
        [self render];
    }
    else if (enumerator == self.friendsLeaderboardCloudEnumerator)
    {
        // Get the leaderboad object from the resource context
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kPEOPLEIKNOW], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.friendsLeaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        
        [self showLeaderBoardOfType:kPEOPLEIKNOW];
    }
}

+ (id) createForRequests:(NSArray*)requests
{
    RequestSummaryViewController* rvc = [[RequestSummaryViewController alloc]initWithNibName:@"RequestSummaryViewController" bundle:nil];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    rvc.userID = authenticationManager.m_LoggedInUserID;
    rvc.user = (User*)[resourceContext resourceWithType:USER withID:rvc.userID];
    rvc.request = [requests objectAtIndex:0];;
    
    [rvc autorelease];
    
    return rvc;
}

@end
