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

#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 22.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0
//#define kMAXUSERNAMELENGTH 15


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
    
}

- (void) render {
    //if the user is the currently logged in user, we then enable the leaderboard container
    if (self.loggedInUser.objectid && [self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        //yes it is
        self.v_leaderboardContainer.hidden = NO;
    }
    else {
        //no it isnt
        self.v_leaderboardContainer.hidden = YES;
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
    
    self.lbl_numPages.text = [self.user.numberofpagespublished stringValue];
    //self.lbl_numVotes.text = [self.user.numberofvotes stringValue];
    self.lbl_numFollowers.text = [self.user.numberoffollowers stringValue];
    self.lbl_numFollowing.text = [self.user.numberfollowing stringValue];
    
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


/*#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    //NSString* activityName = @"ProfileViewController4.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        // Username change was successful
        self.lbl_username.text = self.loggedInUser.username;
        
    }
    else {
        NSString* duplicateUsername = self.loggedInUser.username;
        
        //we need to undo the operation that was last performed
        //LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        // Show the Change Username alert view again
        UIPromptAlertView* alert = [[UIPromptAlertView alloc]
                                    initWithTitle:@"Change Username"
                                    message:[NSString stringWithFormat:@"\n\n\"%@\" is not available. Please try another username.", duplicateUsername]
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Change", nil];
        [alert setMaxTextLength:kMAXUSERNAMELENGTH];
        [alert show];
        [alert release];
        
        // handle fail on change of seamless sharing option
        //self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];
    }
    
}


#pragma mark - Feedback Mail Helper

NSString*	
machineName4()
{
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
    
}
- (void)composeFeedbackMail {
    // Get version information about the app and phone to prepopulate in the email
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleVersion"];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString* deviceType = machineName4();
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"%@ Feedback!", appName]];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"contact@bluelabellabs.com", nil];
    [picker setToRecipients:toRecipients];
    
    NSString *messageHeader = [NSString stringWithFormat:@"I'm using %@ version %@ on my %@ running iOS %@.\n\n--- Please add your message below this line ---", appName, appVersionNum, deviceType, currSysVer];
    [picker setMessageBody:messageHeader isHTML:NO];
    
    // Present the mail composition interface
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

#pragma mark - MailComposeController Delegate
// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIPromptAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString* enteredText = [alertView enteredText];
        
        // Change the current logged in user's username
        self.loggedInUser.username = enteredText;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        //we start a new undo group here
        [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        
        //after this point, the platforms should automatically begin syncing the data back to the cloud
        //we now show a progress bar to monitor this background activity
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        PlatformAppDelegate* delegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = delegate.progressView;
        progressView.delegate = self;
        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        
        NSString* progressIndicatorMessage = [NSString stringWithFormat:@"Checking availability..."];
        
        [self showProgressBar:progressIndicatorMessage withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        if ([self.authenticationManager isUserAuthenticated]) {
            [self.authenticationManager logoff];
        }
        [self dismissModalViewControllerAnimated:YES];
    }
    else if (buttonIndex == 1) {
        // Change Username button pressed
        UIPromptAlertView* alert = [[UIPromptAlertView alloc]
                                    initWithTitle:@"Change Username"
                                    message:@"\n\nPlease enter your preferred username."
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    otherButtonTitles:@"Change", nil];
        [alert setMaxTextLength:kMAXUSERNAMELENGTH];
        [alert show];
        [alert release];
        
    }
    else if (buttonIndex == 2) {
        // Feedback button pressed
        [self composeFeedbackMail];
    }
}
*/


#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onAccountButtonPressed:(id)sender {
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Logout"
                                  otherButtonTitles:@"Change Username", @"Feedback", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];*/
    
    SettingsViewController* settingsViewController = [SettingsViewController createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:settingsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

#pragma mark - UISwitch Handler
/*- (IBAction) onFacebookSeamlessSharingChanged:(id)sender 
 {
 if ([self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
 PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
 UIProgressHUDView* progressView = appDelegate.progressView;
 progressView.delegate = self;
 
 ResourceContext* resourceContext = [ResourceContext instance];
 //[resourceContext.managedObjectContext.undoManager beginUndoGrouping];
 //self.user.sharinglevel = [NSNumber numberWithBool:self.sw_seamlessFacebookSharing.on];
 [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
 
 ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
 
 [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:@"Updating your settings..."]];
 //     [self showDeterminateProgressBar:@"Updating your settings..." withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
 
 }
 }*/

#pragma mark - UIButton Handlers
- (IBAction) onFollowersButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceWithTitle:@"Followers"];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
}

- (IBAction) onFollowingButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceWithTitle:@"Following"];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
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




#pragma mark - MBProgressHUD Delegate
/*- (void) hudWasHidden:(MBProgressHUD *)hud {
 [self hideProgressBar];
 
 UIProgressHUDView* pv = (UIProgressHUDView*)hud;
 
 if (!pv.didSucceed) {
 //there was an error upon submission
 //we undo the request that was attempted to be made
 //        ResourceContext* resourceContext = [ResourceContext instance];
 //        [resourceContext.managedObjectContext.undoManager undo];
 //        
 //        NSError* error = nil;
 //        [resourceContext.managedObjectContext save:&error];
 
 self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];
 
 }
 }*/

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
    //returns an instance of the ProfileViewController4 configured for the specified user
    ProfileViewController4* instance = [[[ProfileViewController4 alloc]initWithNibName:@"ProfileViewController4" bundle:nil]autorelease];
    instance.userID = userID;
    return instance;
}

@end
