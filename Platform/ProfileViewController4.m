//
//  ProfileViewController4.m
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController4.h"
#import "DateTimeHelper.h"

#import "PlatformAppDelegate.h"
//#import "UIProgressHUDView.h"
//#import "CloudEnumerator.h"
//#import "Macros.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "SettingsViewController.h"
//#import <sys/utsname.h>
#import "PeopleListViewController.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"

#define kUSERID                    @"userid"

@implementation ProfileViewController4

@synthesize iv_profilePicture       = m_iv_profilePicture;
@synthesize lbl_username            = m_lbl_username;
//@synthesize lbl_employeeStartDate   = m_lbl_employeeStartDate;
@synthesize lbl_currentLevel        = m_lbl_currentLevel;
@synthesize lbl_currentLevelDate    = m_lbl_currentLevelDate;

@synthesize lbl_numPages            = m_lbl_numPages;
//@synthesize lbl_numVotes            = m_lbl_numVotes;
//@synthesize lbl_numSubmissions      = m_lbl_numSubmissions;
@synthesize lbl_numFollowers        = m_lbl_numFollowers;
@synthesize lbl_numFollowing        = m_lbl_numFollowing;
@synthesize lbl_pagesLabel          = m_lbl_pagesLabel;
@synthesize lbl_votesLabel          = m_lbl_votesLabel;
@synthesize lbl_submissionsLabel    = m_lbl_submissionsLabel;

@synthesize btn_numPages            = m_btn_numPages;
//@synthesize btn_numVotes            = m_btn_numVotes;
//@synthesize btn_numSubmissions      = m_btn_numSubmissions;
@synthesize btn_numFollowers        = m_btn_numFollowers;
@synthesize btn_numFollowing        = m_btn_numFollowing;
@synthesize btn_pagesLabel          = m_btn_pagesLabel;
@synthesize btn_followersLabel      = m_btn_followersLabel;
@synthesize btn_followingLabel      = m_btn_followingLabel;

@synthesize lbl_submissionsLast7DaysLabel = m_lbl_submissionsLast7DaysLabel;
@synthesize lbl_editorMinimumLabel  = m_lbl_editorMinimumLabel;
@synthesize lbl_userBestLabel       = m_lbl_userBestLabel;
@synthesize lbl_draftsLast7Days     = m_lbl_draftsLast7Days;
@synthesize lbl_photosLast7Days     = m_lbl_photosLast7Days;
@synthesize lbl_captionsLast7Days   = m_lbl_captionsLast7Days;
@synthesize lbl_totalLast7Days      = m_lbl_totalLast7Days;
@synthesize lbl_draftsLabel         = m_lbl_draftsLabel;
@synthesize lbl_photosLabel         = m_lbl_photosLabel;
@synthesize lbl_captionsLabel       = m_lbl_captionsLabel;
@synthesize lbl_totalLabel          = m_lbl_totalLabel;
@synthesize iv_progressBarContainer = m_iv_progressBarContainer;
@synthesize iv_progressDrafts       = m_iv_progressDrafts;
@synthesize iv_progressPhotos       = m_iv_progressPhotos;
@synthesize iv_progressCaptions     = m_iv_progressCaptions;
@synthesize iv_editorMinimumLine    = m_iv_editorMinimumLine;
@synthesize iv_userBestLine         = m_iv_userBestLine;
@synthesize user                    = m_user;
@synthesize userID                  = m_userID;
@synthesize v_leaderboardContainer  = m_v_leaderboardContainer;
@synthesize profileCloudEnumerator  = m_profileCloudEnumerator;
@synthesize v_followControlsContainer = m_v_followControlsContainer;
@synthesize btn_follow              = m_btn_follow;
@synthesize btn_unfollow            = m_btn_unfollow;

#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 22.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0


#pragma mark - Progress Bar methods 
- (void)drawProgressBar {
    
    int totalSubmissionsLast7Days = [self.user.numberofdraftscreatedlw intValue]
    + [self.user.numberofphotoslw intValue]
    + [self.user.numberofcaptionslw intValue];
    
    float progressBarContainerWidth = self.iv_progressBarContainer.frame.size.width - kPROGRESSBARCONTAINERINSETRIGHT;
    float editorMinimumLineMidPoint = (float)self.iv_editorMinimumLine.frame.size.width / (float)2;
    float editorMinimumLabelMidPoint = (float)self.lbl_editorMinimumLabel.frame.size.width / (float)2;
    float userBestLineMidPoint = (float)self.iv_userBestLine.frame.size.width / (float)2;
    float userBestLabelMidPoint = (float)self.lbl_userBestLabel.frame.size.width / (float)2;
    
    
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int editorMinimum = [settings.editor_minimum intValue];
    
    int userBest = [self.user.maxweeklyparticipation intValue];
    
    // determine which value will set the scale (max value) for the progress bar
    float progressBarMaxValue = MAX(MAX((float)userBest, (float)editorMinimum), (float)totalSubmissionsLast7Days);
    
    if (progressBarMaxValue == (float)userBest) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_USERBEST;
    }
    else if (progressBarMaxValue == (float)editorMinimum) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM;
    }
    else {
        // let the progress bar container be filled by the users current count of submissions
    }
    
    float scaleEditorMinimum = 0.0f;
    float scaleUserBest = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        scaleEditorMinimum = (float)editorMinimum / (float)progressBarMaxValue;
        scaleUserBest = (float)userBest / (float)progressBarMaxValue;
    }
    
    // move the editor threshold line
    float editorMinimumLineXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + (scaleEditorMinimum * progressBarContainerWidth) - editorMinimumLineMidPoint);
    self.iv_editorMinimumLine.frame = CGRectMake(editorMinimumLineXOrigin, self.iv_editorMinimumLine.frame.origin.y, self.iv_editorMinimumLine.frame.size.width, self.iv_editorMinimumLine.frame.size.height);
    float editorMinimumWidth = (float)self.iv_editorMinimumLine.frame.origin.x + (float)editorMinimumLineMidPoint - (float)kPROGRESSBARCONTAINERXORIGINOFFSET;
    
    // move the editor threshold label
    float editorMinimumLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + editorMinimumWidth - editorMinimumLabelMidPoint);
    self.lbl_editorMinimumLabel.frame = CGRectMake(editorMinimumLabelXOrigin, self.lbl_editorMinimumLabel.frame.origin.y, self.lbl_editorMinimumLabel.frame.size.width, self.lbl_editorMinimumLabel.frame.size.height);
    
    // move the user best threshold line
    float userBestLineXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + (scaleUserBest * progressBarContainerWidth) - userBestLineMidPoint);
    self.iv_userBestLine.frame = CGRectMake(userBestLineXOrigin, self.iv_userBestLine.frame.origin.y, self.iv_userBestLine.frame.size.width, self.iv_userBestLine.frame.size.height);
    float userBestWidth = (float)self.iv_userBestLine.frame.origin.x + (float)userBestLineMidPoint - (float)kPROGRESSBARCONTAINERXORIGINOFFSET;
    
    // move the user best threshold label
    float userBestLabelXOrigin = 0.0f;
    if ([self.user.maxweeklyparticipation intValue] == 0) {
        userBestLabelXOrigin = MIN(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + userBestWidth - userBestLabelMidPoint);
    }
    else {
        userBestLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + userBestWidth - userBestLabelMidPoint);
    }
    self.lbl_userBestLabel.frame = CGRectMake(userBestLabelXOrigin, self.lbl_userBestLabel.frame.origin.y, self.lbl_userBestLabel.frame.size.width, self.lbl_userBestLabel.frame.size.height);
    
    
    // now sequentially draw the progress bars for the draft, photo and caption counts for the last 7 days
    // drafts in the last 7 days
    float progressDrafts = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressDrafts = ((float)[self.user.numberofdraftscreatedlw intValue]) / (float)progressBarMaxValue;
    }
    //float progressDrafts = (float)3 / (float)progressBarMaxValue;
    self.iv_progressDrafts.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET, self.iv_progressDrafts.frame.origin.y,(progressDrafts * progressBarContainerWidth), self.iv_progressDrafts.frame.size.height);
    [self.iv_progressDrafts setHidden:NO];
    
    // photos in the last 7 days
    float progressPhotos = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressPhotos = (float)[self.user.numberofphotoslw intValue] / (float)progressBarMaxValue;
    }
    //float progressPhotos = (float)2 / (float)progressBarMaxValue;
    self.iv_progressPhotos.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width, self.iv_progressPhotos.frame.origin.y,(progressPhotos * progressBarContainerWidth), self.iv_progressPhotos.frame.size.height);
    [self.iv_progressPhotos setHidden:NO];
    
    // captions in the last 7 days
    float progressCaptions = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressCaptions = (float)[self.user.numberofcaptionslw intValue] / (float)progressBarMaxValue;
    }
    //float progressCaptions = (float)4 / (float)progressBarMaxValue;
    self.iv_progressCaptions.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width +  + self.iv_progressPhotos.frame.size.width, self.iv_progressCaptions.frame.origin.y,(progressCaptions * progressBarContainerWidth), self.iv_progressCaptions.frame.size.height);
    [self.iv_progressCaptions setHidden:NO];
    
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onDoneButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [@"Writers's Log" sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"Writers's Log";
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
    
    // Setup follow and unfollow buttons
    UIImage* followButtonImageNormal = [UIImage imageNamed:@"button_roundrect_blue.png"];
    UIImage* stretchablefollowButtonImageNormal = [followButtonImageNormal stretchableImageWithLeftCapWidth:73 topCapHeight:22];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageNormal forState:UIControlStateNormal];
    
    UIImage* followButtonImageSelected = [UIImage imageNamed:@"button_roundrect_lightgrey_selected.png"];
    UIImage* stretchablefollowButtonImageSelected = [followButtonImageSelected stretchableImageWithLeftCapWidth:73 topCapHeight:22];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageSelected forState:UIControlStateSelected];
    
    if (self.btn_follow.selected == YES) {
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    else {
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_profilePicture = nil;
    self.lbl_username = nil;
    //self.lbl_employeeStartDate = nil;
    self.lbl_currentLevel = nil;
    self.lbl_currentLevelDate = nil;
    self.lbl_numPages = nil;
    //self.lbl_numVotes = nil;
    //self.lbl_numSubmissions = nil;
    self.lbl_numFollowers = nil;
    self.lbl_numFollowing = nil;
    self.lbl_pagesLabel = nil;
    self.lbl_votesLabel = nil;
    self.lbl_submissionsLabel = nil;
    self.btn_numPages = nil;
    //self.btn_numVotes = nil;
    //self.btn_numSubmissions = nil;
    self.btn_numFollowers = nil;
    self.btn_numFollowing = nil;
    self.btn_pagesLabel = nil;
    self.btn_followersLabel = nil;
    self.btn_followingLabel = nil;
    self.lbl_submissionsLast7DaysLabel = nil;
    self.lbl_editorMinimumLabel = nil;
    self.lbl_userBestLabel = nil;
    self.lbl_draftsLast7Days = nil;
    self.lbl_photosLast7Days = nil;
    self.lbl_captionsLast7Days = nil;
    self.lbl_totalLast7Days = nil;
    self.lbl_draftsLabel = nil;
    self.lbl_photosLabel = nil;
    self.lbl_captionsLabel = nil;
    self.lbl_totalLabel = nil;
    self.iv_progressDrafts = nil;
    self.iv_progressPhotos = nil;
    self.iv_progressCaptions = nil;
    self.iv_editorMinimumLine = nil;
    self.iv_userBestLine = nil;
    self.iv_progressBarContainer = nil;
    self.v_leaderboardContainer = nil;
    self.v_followControlsContainer = nil;
    self.btn_follow = nil;
    self.btn_unfollow = nil;
    
}

- (void) render {
    //if the user is the currently logged in user, we then enable the leaderboard container, else show the follow controls container
    if (self.loggedInUser.objectid && [self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        //yes it is
        self.v_leaderboardContainer.hidden = NO;
        self.v_followControlsContainer.hidden = YES;
    }
    else {
        //no it isnt
        self.v_leaderboardContainer.hidden = YES;
        self.v_followControlsContainer.hidden = NO;
    }
    
    self.lbl_username.text = self.user.username;

    //Show current user level and date
    if ([self.user.iseditor boolValue]) {
        self.lbl_currentLevel.text = @"Editor";
        self.lbl_currentLevelDate.text = [NSString stringWithFormat:@"since: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.user.datebecameeditor]]];
    }
    else {
        self.lbl_currentLevel.text = @"Contributor";
       self.lbl_currentLevelDate.text = [NSString stringWithFormat:@"since: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.user.datecreated]]];
    }
    
    //Show profile picture
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.userID forKey:kUSERID];
    
    if (self.user.imageurl != nil && ![self.user.imageurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:self.user.imageurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            self.iv_profilePicture.image = image;
        }
    }
    else {
        self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-large-highlighted.png"];
    }
    
    /*self.lbl_numPages.text = [self.user.numberofpagespublished stringValue];
    //self.lbl_numVotes.text = [self.user.numberofvotes stringValue];
    self.lbl_numFollowers.text = [self.user.numberoffollowers stringValue];
    self.lbl_numFollowing.text = [self.user.numberfollowing stringValue];*/
    
    [self.btn_numPages setTitle:[self.user.numberofpagespublished stringValue] forState:UIControlStateNormal];
    [self.btn_numFollowers setTitle:[self.user.numberoffollowers stringValue] forState:UIControlStateNormal];
    [self.btn_numFollowing setTitle:[self.user.numberfollowing stringValue] forState:UIControlStateNormal];
    
    /*int totalSubmissions = [self.user.numberofcaptions intValue]
        + [self.user.numberofphotos intValue]
        + [self.user.numberofdraftscreated intValue];
    self.lbl_numSubmissions.text = [NSString stringWithFormat:@"%d", totalSubmissions];*/
    
    self.lbl_draftsLast7Days.text = [self.user.numberofdraftscreatedlw stringValue];
    self.lbl_photosLast7Days.text = [self.user.numberofphotoslw stringValue];
    self.lbl_captionsLast7Days.text = [self.user.numberofcaptionslw stringValue];
    
    /*int totalLast7Days = [self.user.numberofcaptionslw intValue]
        + [self.user.numberofphotoslw intValue]
        + [self.user.numberofdraftscreatedlw intValue];
    self.lbl_totalLast7Days.text = [NSString stringWithFormat:@"%d", totalLast7Days];*/
    self.lbl_totalLast7Days.text = [self.user.numberofpoints stringValue];
    
    self.lbl_userBestLabel.text = [NSString stringWithFormat:@"Best: %d", [self.user.maxweeklyparticipation intValue]];
    
    [self drawProgressBar];
}

- (void) refreshProfile:(NSNumber*)userid 
{
    //object doesnt exist in the store, we need to grab it from the cloud
    NSArray* objectIDs = [NSArray arrayWithObject:userid];
    NSArray* objectTypes = [NSArray arrayWithObject:USER];
    self.profileCloudEnumerator = nil;
    self.profileCloudEnumerator = [CloudEnumerator enumeratorForIDs:objectIDs withTypes:objectTypes];
    self.profileCloudEnumerator.delegate = self;
    [self.profileCloudEnumerator enumerateUntilEnd:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDPROFILEVC]==NO) {
        [userDefaults setBool:YES forKey:setting_HASVIEWEDPROFILEVC];
        [userDefaults synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //We show an alert view if this is the first time they have used this VC
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDPROFILEVC] == NO) 
    {
        //it is the first time, we show the alert screen
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Track your Bahndr impact..." message:ui_WELCOME_PROFILE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
    }
    
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Hide toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if (self.user == nil) {
        //we need to retrieve the id specified
        ResourceContext* resourceContext = [ResourceContext instance];
        self.user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
        [self refreshProfile:self.userID];
        
        if (self.user != nil) {
            [self render];             
        }
    }
    else {
        self.userID = self.user.objectid;
        [self refreshProfile:self.userID];
        [self render];
    }
    
    if (self.userID && self.loggedInUser.objectid && [self.userID isEqualToNumber:self.loggedInUser.objectid]) {
        // Only enable the Account button for the logged in user
        UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Settings"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(onAccountButtonPressed:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        [leftButton release];
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        // TO DO Disable/hide any profile objects that should not be presented or enabled for a user who is not logged in
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onAccountButtonPressed:(id)sender {
    SettingsViewController* settingsViewController = [SettingsViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:settingsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

#pragma mark - UIButton Handlers
- (IBAction) onFollowersButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceWithTitle:@"Followers"];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
}

- (IBAction) onFollowingButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceWithTitle:@"Following"];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
}

- (IBAction) onFollowButtonPressed:(id)sender {
    [self.btn_follow setSelected:!self.btn_follow.selected];
    if (self.btn_follow.selected == YES) {
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    else {
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    }
}

- (IBAction) onUnfollowButtonPressed:(id)sender {
    
}

#pragma mark - CloudEnumeratorDelegate

- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    ResourceContext* resourceContext = [ResourceContext instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    NSNumber* userid = user.objectid;
    
    self.user = user;
    self.userID = userid;
    if (self.user != nil && self.userID != nil) {
        [self render];
    }
    
    
}

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSDictionary* userInfo = result.context;
    NSNumber* userID = [userInfo valueForKey:kUSERID];
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        if ([userID isEqualToNumber:self.userID]) {
            //we only draw the image if this view hasnt been repurposed for another user
            [self.iv_profilePicture performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
        }
        
        [self.view setNeedsDisplay];
    }
    else {
        // show the photo placeholder icon
        self.iv_profilePicture.image = [UIImage imageNamed:@"icon-profile-large-highlighted.png"];
        
        [self.view setNeedsDisplay];
    }
    
}

#pragma mark - Static Initializers
+ (ProfileViewController4*)createInstance {
    ProfileViewController4* instance = [[[ProfileViewController4 alloc]initWithNibName:@"ProfileViewController4" bundle:nil]autorelease];
    //sets the user property to the curretly logged on user
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    instance.user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    instance.userID = authenticationManager.m_LoggedInUserID;
    return instance;
}

+ (ProfileViewController4*)createInstanceForUser:(NSNumber *)userID {
    //returns an instance of the ProfileViewController configured for the specified user
    ProfileViewController4* instance = [[[ProfileViewController4 alloc]initWithNibName:@"ProfileViewController4" bundle:nil]autorelease];
    instance.userID = userID;
    return instance;
}

@end
