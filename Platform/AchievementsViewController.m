//
//  AchievementsViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 6/7/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "AchievementsViewController.h"
#import "PlatformAppDelegate.h"
#import "Macros.h"
#import "Achievement.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "UIAchievementView.h"
#import "FlurryAnalytics.h"
#import "UITutorialView.h"
#import "UserDefaultSettings.h"

#define kIMAGEVIEW @"imageview"
#define kUSERID    @"userid"

@interface AchievementsViewController ()

@end

@implementation AchievementsViewController
@synthesize frc_achievements        = __frc_achievements;
@synthesize userID                  = m_userID;
@synthesize loadedAchievementID     = m_loadedAchievementID;
@synthesize achievementCloudEnumerator = m_achivementCloudEnumerator;
@synthesize sv_scrollView           = m_sv_scrollView;
@synthesize iv_profilePicture       = m_iv_profilePicture;


//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_achievements {
    NSString* activityName = @"AchievementsViewController.frc_achievements:";
    if (__frc_achievements != nil) {
        return __frc_achievements;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    PlatformAppDelegate* app = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ACHIEVEMENT inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    //add predicate to gather only achievements for a specific userID
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", USERID, self.userID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:100];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_achievements = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_ACHIEVEMENTSVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_achievements;
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) showProfilePicture {
    //Show profile picture
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.userID forKey:kUSERID];
    
    
    self.iv_profilePicture = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    ResourceContext* resourceContext = [ResourceContext instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    
    if (user.imageurl != nil && ![user.imageurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onProfilePictureImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:user.imageurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            self.iv_profilePicture.backgroundColor = [UIColor whiteColor];
            self.iv_profilePicture.image = image;
        }
    }
    else {
        self.iv_profilePicture.backgroundColor = [UIColor darkGrayColor];
        self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-large-highlighted.png"];
    }
    
    [self.navigationController.navigationBar addSubview:self.iv_profilePicture];
}

- (void)showHUDForAchievementsDownload {
//    PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
//    UIProgressHUDView* progressView = appDelegate.progressView;
//    progressView.delegate = self;
//    
//    NSNumber* heartbeat = [NSNumber numberWithInt:10];
//    
//    //we need to construct the appropriate success, failure and progress messages for the achievements download
//    NSString* failureMessage = @"Failed!\nCould not download awards.";
//    NSString* successMessage = @"Success!";
//    NSArray* progressMessage = [NSArray arrayWithObjects:@"Looking for awards...", @"Downloading awards...", @"Searching bookshelf...", @"Wow, quite the achiever...", nil];
//    
//    //ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
//    //NSNumber* maxDisplayTime = settings.http_timeout_seconds;
//    
//    NSNumber* maxDisplayTime = [NSNumber numberWithInt:120];
//    
//    [self showDeterminateProgressBarWithMaximumDisplayTime:maxDisplayTime withHeartbeat:heartbeat onSuccessMessage:successMessage onFailureMessage:failureMessage inProgressMessages:progressMessage];
    
    PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Looking for awards...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateAchievementsForUserWithID:(NSNumber*)userid 
{    
    if (self.achievementCloudEnumerator != nil) {
        [self.achievementCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.achievementCloudEnumerator = nil;
        self.achievementCloudEnumerator = [CloudEnumerator enumeratorForAchievements:userid];
        self.achievementCloudEnumerator.delegate = self;
        [self.achievementCloudEnumerator enumerateUntilEnd:nil];
    }
    
    [self showHUDForAchievementsDownload];
}

- (void) renderAchievements {
    int count = [[self.frc_achievements fetchedObjects]count];
    
    int rows = (count / 3) + 1;
    int defaultColumns = 3;
    int remainderColumns = count % 3;   // this will be used in the last row
    
    // constants for the frame of the achievements
    float leftMargin = 0.0;
    float topMarginRow1 = 7.0;
    float topMargin = 9.0;
    float innerMargin = 5.0;
    float achievmentWidth = 103.0;
    float achievmentHeight = 95.0;
    
    int index = 0;
    
    if (count > 0) {
        
        for (int r = 0; r < rows; r++) {
            for (int c = 0; c < defaultColumns; c++) {
                if (index < count) {
                    // Render the achievement
                    
                    // Setup the imageview
                    float x = leftMargin + c*(innerMargin + achievmentWidth);
                    float y = topMarginRow1 + r*(topMargin + achievmentHeight);
                    
                    CGRect frame = CGRectMake(x, y, achievmentWidth, achievmentHeight);
                    
                    UIImageView* iv_achievement = [[[UIImageView alloc] initWithFrame:frame] autorelease];
                    iv_achievement.tag = index + 1;     // we need to add 1 because a view's tag cannot be set to 0
                    iv_achievement.contentMode = UIViewContentModeScaleAspectFit;
                    
                    // Get the image for the acheivement
                    Achievement* achievement = [[self.frc_achievements fetchedObjects] objectAtIndex:index];
                    
                    ImageManager* imageManager = [ImageManager instance];
                    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:achievement.objectid forKey:OBJECTID]; 
                    [userInfo setValue:iv_achievement forKey:kIMAGEVIEW]; 
                    Callback* imageCallback = [Callback callbackForTarget:self selector:@selector(onAchievementImageDownloaded:) fireOnMainThread:YES];
                    imageCallback.context = userInfo;
                    
                    UIImage* image = [imageManager downloadImage:achievement.imageurl withUserInfo:nil atCallback:imageCallback];
                    
                    if (image != nil) 
                    {
                        //we found the image in the local cache
                        iv_achievement.image = image;
                    }
                    else {
                        // show the placeholder image
                        iv_achievement.image = [UIImage imageNamed:@"mallard-original-disabled.png"];
                    }
                    
                    // Create gesture recognizer for the achievement to handle a single tap
                    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAchievement:)] autorelease];
                    
                    // Set required taps and number of touches
                    [oneFingerTap setNumberOfTapsRequired:1];
                    [oneFingerTap setNumberOfTouchesRequired:1];
                    
                    // Add the gesture to the achievement image view
                    [iv_achievement addGestureRecognizer:oneFingerTap];
                    
                    // Enable gesture events on the achievement image view
                    [iv_achievement setUserInteractionEnabled:YES];
                    
                    [self.sv_scrollView addSubview:iv_achievement];
                    
                    [userInfo release];
                    
                    index++;
                }
                else {
                    // Now render a placeholder mallard for the next mallard to be achieved
                    UIImageView* iv_placeholder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mallard-original-disabled.png"]] autorelease];
                    //UIImageView* iv_placeholder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mallard-goddess.png"]] autorelease];
                    iv_placeholder.tag = 999;     // make it a large number that will never be reached
                    iv_placeholder.contentMode = UIViewContentModeScaleAspectFit;
                    
                    float x = leftMargin + (remainderColumns)*(innerMargin + achievmentWidth);
                    float y = topMarginRow1 + r*(topMargin + achievmentHeight);
                    iv_placeholder.frame = CGRectMake(x, y, achievmentWidth, achievmentHeight);
                    
                    // Create gesture recognizer for the achievement to handle a single tap
                    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAchievement:)] autorelease];
                    
                    // Set required taps and number of touches
                    [oneFingerTap setNumberOfTapsRequired:1];
                    [oneFingerTap setNumberOfTouchesRequired:1];
                    
                    // Add the gesture to the achievement image view
                    [iv_placeholder addGestureRecognizer:oneFingerTap];
                    
                    // Enable gesture events on the achievement image view
                    [iv_placeholder setUserInteractionEnabled:YES];
                    
                    [self.sv_scrollView addSubview:iv_placeholder];
                    break;
                }
            }
        }
    }
    else {
        // Render a single placeholder mallard for the first mallard to be achieved
        UIImageView* iv_placeholder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mallard-original-disabled.png"]] autorelease];
        //UIImageView* iv_placeholder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mallard-goddess.png"]] autorelease];
        iv_placeholder.tag = 999;     // make it a large number that will never be reached
        iv_placeholder.contentMode = UIViewContentModeScaleAspectFit;
        float x = leftMargin;
        float y = topMarginRow1;
        iv_placeholder.frame = CGRectMake(x, y, achievmentWidth, achievmentHeight);
        
        // Create gesture recognizer for the achievement to handle a single tap
        UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAchievement:)] autorelease];
        
        // Set required taps and number of touches
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the achievement image view
        [iv_placeholder addGestureRecognizer:oneFingerTap];
        
        // Enable gesture events on the achievement image view
        [iv_placeholder setUserInteractionEnabled:YES];
        
        [self.sv_scrollView addSubview:iv_placeholder];
    }
    
    // Update the scroll view size based on the number of achievments shown
    float scrollViewHeight = MAX(730, (rows+3)*(topMargin + achievmentHeight));
    self.sv_scrollView.contentSize = CGSizeMake(320, scrollViewHeight);
    
    [self.view setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set up the scroll view
    self.sv_scrollView.contentSize = CGSizeMake(320, 730);
    self.sv_scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bookshelf.png"]];
    
    // Apply the bookshelf nav bar background
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSLog(@"%f",version);
    UIImage *backgroundImage = [UIImage imageNamed:@"bookshelf_top.png"];
    if (version >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        //[self.navigationController.navigationBar.layer setContents:(id)backgroundImage.CGImage];
        [self.navigationController.navigationBar insertSubview:[[[UIImageView alloc] initWithImage:backgroundImage] autorelease] atIndex:1];
    }
    
    // Add custom styled Done button to nav bar
    UIButton *btn_rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_rightButton addTarget:self action:@selector(onDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];  
    btn_rightButton.frame = CGRectMake(0, 0, 52, 30);
    btn_rightButton.contentMode = UIViewContentModeCenter;
    
    btn_rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    btn_rightButton.titleLabel.textAlignment = UITextAlignmentCenter;
    btn_rightButton.titleLabel.textColor = [UIColor whiteColor];
    btn_rightButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    btn_rightButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    [btn_rightButton setTitle:@"Done" forState:UIControlStateNormal];
    
    UIImage* buttonImage = [[UIImage imageNamed:@"bookshelf_button.png"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
    [btn_rightButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_rightButton] autorelease];
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [@"~ Awards ~" sizeWithFont:[UIFont fontWithName:@"SnellRoundhand-Bold" size:28.0]];
    //CGSize labelSize = [@"Mallard & Co." sizeWithFont:[UIFont fontWithName:@"Copperplate-Bold" size:24.0]];
    //CGSize labelSize = [@"Mallard & Co." sizeWithFont:[UIFont fontWithName:@"Baskerville-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"~ Awards ~";
    titleLabel.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:28.0];
    //titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:24.0];
    //titleLabel.font = [UIFont fontWithName:@"Baskerville-Bold" size:20.0];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor brownColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    // emboss so that the label looks OK
    [titleLabel setShadowColor:[UIColor whiteColor]];
    [titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    
    // Add user profile pic to nav bar
    [self showProfilePicture];
    
    // Set up cloud enumerator for achievments
    self.achievementCloudEnumerator = [CloudEnumerator enumeratorForAchievements:self.userID];
    self.achievementCloudEnumerator.delegate = self;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.sv_scrollView = nil;
    self.iv_profilePicture = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Enumerate the achievements for this user
    [self enumerateAchievementsForUserWithID:self.userID];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logEvent:@"VIEWING_AWARDSVIEW" timed:YES];
    
    // Check if the controller should open with a specific achievement loaded
    if (self.loadedAchievementID != nil) {
        [self showAchievementWithID:self.loadedAchievementID];
    }
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDAWARDCABINETVC]==NO) 
    {
        [self onInfoButtonPressed:nil];
        [userDefaults setBool:YES forKey:setting_HASVIEWEDAWARDCABINETVC];
        [userDefaults synchronize];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [FlurryAnalytics endTimedEvent:@"VIEWING_AWARDSVIEW" withParameters:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Subview Handlers
- (void)showAchievementWithID:(NSNumber *)achievementID {
    //CGRect frame = CGRectMake(20, 20, 280, 356);
    CGRect frame = self.view.bounds;
    UIAchievementView* v_achievementView = [[UIAchievementView alloc] initWithFrame:frame];
    
    if (achievementID == nil) {
        ResourceContext* resourceContext = [ResourceContext instance];
        User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
        
        int nextAchievment = [user.achievementthreshold intValue];
        
        v_achievementView.lbl_description.text = [NSString stringWithFormat:@"This next mallard will be unlocked at %d gold coins. Keep Bahndring.", nextAchievment];
        v_achievementView.lbl_title.text = @"Mystery Mallard";
    }
    else {
        [v_achievementView renderAchievementsWithID:achievementID];
    }
    
    // Animate the showing of the view
    CATransition *loadViewIn = [CATransition animation];
    [loadViewIn setDuration:0.5];
    [loadViewIn setType:kCATransitionReveal];
    [loadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[v_achievementView layer]addAnimation:loadViewIn forKey:kCATransitionReveal];
    
    [self.view addSubview:v_achievementView];
    
    [v_achievementView release];
}


#pragma mark - UI Gesture Handlers
- (void)showAchievement:(UITapGestureRecognizer *)gestureRecognizer {
    [FlurryAnalytics logEvent:@"AWARDSVIEW_MALLARDVIEWED"];
    
    UIImageView* iv_achievement = (UIImageView *)gestureRecognizer.view;
    
    int index = iv_achievement.tag - 1;
    
    int count = [[self.frc_achievements fetchedObjects] count];
    
    if (count > 0 && index >= 0 && index != 998) {
        // Get the acheivement object
        Achievement* achievement = [[self.frc_achievements fetchedObjects] objectAtIndex:index];
        self.loadedAchievementID = achievement.objectid;
    }
    else {
        // User has not recieved an acheivment yet
        self.loadedAchievementID = nil;
    }

    [self showAchievementWithID:self.loadedAchievementID];
    
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSString* activityName = @"AchievementsViewController.controller.didChangeObject:";
//    if (controller == self.frc_achievements) {
//        if (type == NSFetchedResultsChangeInsert) {
//            [self displayAchievements];
//        }
//        else if (type == NSFetchedResultsChangeDelete) {
//            [self displayAchievements];
//        }
//    }
//    else {
//        LOG_ACHIEVEMENTSVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
//    }
}

#pragma mark - ImageManager Callbacks
- (void) onAchievementImageDownloaded:(CallbackResult*)callbackResult
{
    //the image for the achievement has been downloaded
    NSDictionary* userInfo = callbackResult.context;
    NSNumber* objectID = [userInfo valueForKey:OBJECTID];
    UIImageView* iv_achievement = (UIImageView *)[userInfo valueForKey:kIMAGEVIEW];
    ImageDownloadResponse* response = (ImageDownloadResponse*)callbackResult.response;
    
    if ([response.didSucceed boolValue] == YES) {
        ResourceContext* resourceContext = [ResourceContext instance];
        
        if (objectID != nil) {
            Achievement* achievementObject = (Achievement*)[resourceContext resourceWithType:ACHIEVEMENT withID:objectID];
            if (achievementObject != nil)
            {
                ImageManager* imageManager = [ImageManager instance];
                UIImage* image = [imageManager downloadImage:achievementObject.imageurl withUserInfo:nil atCallback:nil];
                iv_achievement.image = image;
            }
        }
    }
    else {
        // show the placeholder image
        iv_achievement.image = [UIImage imageNamed:@"mallard-original-disabled.png"];
    }
    
    [self.view setNeedsDisplay];
    
}

- (void)onProfilePictureImageDownloadComplete:(CallbackResult*)result {
    NSDictionary* userInfo = result.context;
    NSNumber* userID = [userInfo valueForKey:kUSERID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([userID isEqualToNumber:self.userID]) {
            //we only draw the image if this view hasnt been repurposed for another user
            self.iv_profilePicture.backgroundColor = [UIColor whiteColor];
            [self.iv_profilePicture performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
        }
        
        [self.view setNeedsDisplay];
    }
    else {
        // show the photo placeholder icon
        self.iv_profilePicture.backgroundColor = [UIColor darkGrayColor];
        self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-large-highlighted.png"];
        
        [self.view setNeedsDisplay];
    }
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"AchievementsViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucesful
        LOG_REQUEST(0, @"%@ Enumeration request was successful", activityName);
        
        [self renderAchievements];
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(0, @"%@ Enumeration request failure", activityName);
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    if (enumerator == self.achievementCloudEnumerator) {
        [self hideProgressBar];
        [self renderAchievements];
    }
}

#pragma mark - UIButton handlers
- (IBAction) onInfoButtonPressed:(id)sender
{
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewAwardCabinet"];
    [self.view addSubview:infoView];
    [infoView release];
}
#pragma mark - Static Initializers
+ (AchievementsViewController*)createInstance {
    AchievementsViewController* instance = [[[AchievementsViewController alloc]initWithNibName:@"AchievementsViewController" bundle:nil] autorelease];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    instance.userID = authenticationManager.m_LoggedInUserID;
    instance.loadedAchievementID = nil;
    return instance;
}

+ (AchievementsViewController*)createInstanceForUserWithID:(NSNumber *)userID {
    AchievementsViewController* instance = [[[AchievementsViewController alloc]initWithNibName:@"AchievementsViewController" bundle:nil] autorelease];
    instance.userID = userID;
    instance.loadedAchievementID = nil;
    return instance;
}

+ (AchievementsViewController*)createInstanceForUserWithID:(NSNumber *)userID preloadedWithAchievementIDorNil:(NSNumber *)achievementID {
    AchievementsViewController* instance = [[[AchievementsViewController alloc]initWithNibName:@"AchievementsViewController" bundle:nil] autorelease];
    instance.userID = userID;
    instance.loadedAchievementID = achievementID;
    return instance;
}

@end
