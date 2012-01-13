//
//  ProfileViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "DateTimeHelper.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "PlatformAppDelegate.h"
#import "UIPromptAlertView.h"
#import "UIProgressHUDView.h"
#import "CloudEnumerator.h"
#import "Macros.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"

@implementation ProfileViewController
@synthesize lbl_username            = m_lbl_username;
@synthesize lbl_employeeStartDate   = m_lbl_employeeStartDate;
@synthesize lbl_currentLevel        = m_lbl_currentLevel;
@synthesize lbl_currentLevelDate    = m_lbl_currentLevelDate;
@synthesize lbl_numPages            = m_lbl_numPages;
@synthesize lbl_numVotes            = m_lbl_numVotes;
@synthesize lbl_numSubmissions      = m_lbl_numSubmissions;
@synthesize lbl_pagesLabel          = m_lbl_pagesLabel;
@synthesize lbl_votesLabel          = m_lbl_votesLabel;
@synthesize lbl_submissionsLabel    = m_lbl_submissionsLabel;
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
@synthesize v_userSettingsContainer     = m_v_userSettingsContainer;
@synthesize sw_seamlessFacebookSharing  = m_sw_seamlessFacebookSharing;
@synthesize profileCloudEnumerator  = m_profileCloudEnumerator;
//@synthesize sw_facebookLogin            = m_sw_facebookLogin;
//@synthesize sw_twitterLogin             = m_sw_twitterLogin;

#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 22.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0
#define kMAXUSERNAMELENGTH 15


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
    
    // photos in the last 7 days
    float progressPhotos = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressPhotos = (float)[self.user.numberofphotoslw intValue] / (float)progressBarMaxValue;
    }
    //float progressPhotos = (float)2 / (float)progressBarMaxValue;
    self.iv_progressPhotos.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width, self.iv_progressPhotos.frame.origin.y,(progressPhotos * progressBarContainerWidth), self.iv_progressPhotos.frame.size.height);
    
    // captions in the last 7 days
    float progressCaptions = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressCaptions = (float)[self.user.numberofcaptionslw intValue] / (float)progressBarMaxValue;
    }
    //float progressCaptions = (float)4 / (float)progressBarMaxValue;
    self.iv_progressCaptions.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width +  + self.iv_progressPhotos.frame.size.width, self.iv_progressCaptions.frame.origin.y,(progressCaptions * progressBarContainerWidth), self.iv_progressCaptions.frame.size.height);
    
    
    /*
    if (totalSubmissionsLast7Days <= kEDITORMINIMUM) {
        // user hasn't met the minimum required subissions to be an editor,
        // make the editor threshold line 80% of the progress bar container

        // move the editor threshold line
        float editorMinimumLineXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + (kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM * progressBarContainerWidth) - editorMinimumLineMidPoint);
        self.iv_editorMinimumLine.frame = CGRectMake(editorMinimumLineXOrigin, self.iv_editorMinimumLine.frame.origin.y, self.iv_editorMinimumLine.frame.size.width, self.iv_editorMinimumLine.frame.size.height);
        float editorMinimumWidth = (float)self.iv_editorMinimumLine.frame.origin.x + (float)editorMinimumLineMidPoint - (float)kPROGRESSBARCONTAINERXORIGINOFFSET;
        
        // move the editor threshold label
        float editorMinimumLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + editorMinimumWidth - editorMinimumLabelMidPoint);
        self.lbl_editorMinimumLabel.frame = CGRectMake(editorMinimumLabelXOrigin, self.lbl_editorMinimumLabel.frame.origin.y, self.lbl_editorMinimumLabel.frame.size.width, self.lbl_editorMinimumLabel.frame.size.height);
        
        // now sequentially draw the progress bars for the draft, photo and caption counts for the last 7 days
        // drafts in the last 7 days
        //float progressDrafts = (float)[self.loggedInUser.numberofdraftscreatedlw intValue] / (float)kEDITORMINIMUM;
        float progressDrafts = (float)3 / (float)kEDITORMINIMUM;
        self.iv_progressDrafts.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET, self.iv_progressDrafts.frame.origin.y,(progressDrafts * editorMinimumWidth), self.iv_progressDrafts.frame.size.height);
        
        // photos in the last 7 days
        //float progressPhotos = (float)[self.loggedInUser.numberofphotoslw intValue] / (float)kEDITORMINIMUM;
        float progressPhotos = (float)3 / (float)kEDITORMINIMUM;
        self.iv_progressPhotos.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width, self.iv_progressPhotos.frame.origin.y,(progressPhotos * editorMinimumWidth), self.iv_progressPhotos.frame.size.height);
        
        // captions in the last 7 days
        //float progressCaptions = (float)[self.loggedInUser.numberofcaptionslw intValue] / (float)kEDITORMINIMUM;
        float progressCaptions = (float)4 / (float)kEDITORMINIMUM;
        self.iv_progressCaptions.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width +  + self.iv_progressPhotos.frame.size.width, self.iv_progressCaptions.frame.origin.y,(progressCaptions * editorMinimumWidth), self.iv_progressCaptions.frame.size.height);
    }
     */
    
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.lbl_username = nil;
    self.lbl_employeeStartDate = nil;
    self.lbl_currentLevel = nil;
    self.lbl_currentLevelDate = nil;
    self.lbl_numPages = nil;
    self.lbl_numVotes = nil;
    self.lbl_numSubmissions = nil;
    self.lbl_pagesLabel = nil;
    self.lbl_votesLabel = nil;
    self.lbl_submissionsLabel = nil;
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
    self.v_userSettingsContainer = nil;
    self.sw_seamlessFacebookSharing = nil;
    //self.sw_facebookLogin = nil;
    //self.sw_twitterLogin = nil;
    
}

- (void) render {
    //if the user is the currently logged in user, we then enable the user settings container
    if (self.loggedInUser.objectid && [self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        //yes it is
        self.v_userSettingsContainer.hidden = NO;
        
    }
    else {
        //no it isnt
        self.v_userSettingsContainer.hidden = YES;
    }
    self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];
    //self.sw_facebookLogin.on = [self.authenticationManager isUserAuthenticated];
    //self.sw_twitterLogin.on = [self.authenticationManager isUserAuthenticated];
    
    
    self.lbl_username.text = self.user.username;
    self.lbl_employeeStartDate.text = [NSString stringWithFormat:@"start date: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.user.datecreated]]];
    self.lbl_currentLevel.text = [self.user.iseditor boolValue] ? @"Editor" : @"Contributor";
    self.lbl_currentLevelDate.text = [NSString stringWithFormat:@"since: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.user.datebecameeditor]]];
    
    self.lbl_numPages.text = [self.user.numberofpagespublished stringValue];
    self.lbl_numVotes.text = [self.user.numberofvotes stringValue];
    
    int totalSubmissions = [self.user.numberofcaptions intValue]
    + [self.user.numberofphotos intValue]
    + [self.user.numberofdraftscreated intValue];
    self.lbl_numSubmissions.text = [NSString stringWithFormat:@"%d", totalSubmissions];
    
    self.lbl_draftsLast7Days.text = [self.user.numberofdraftscreatedlw stringValue];
    self.lbl_photosLast7Days.text = [self.user.numberofphotoslw stringValue];
    self.lbl_captionsLast7Days.text = [self.user.numberofcaptionslw stringValue];
    
    int totalLast7Days = [self.user.numberofcaptionslw intValue]
    + [self.user.numberofphotoslw intValue]
    + [self.user.numberofdraftscreatedlw intValue];
    self.lbl_totalLast7Days.text = [NSString stringWithFormat:@"%d", totalLast7Days];
    
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Profile" message:ui_WELCOME_PROFILE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];

    }
    
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    
    
    
    // Set the navigationbar title
    self.navigationItem.title = @"Writers's Log";
    
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
                                       initWithTitle:@"Account"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(onAccountButtonPressed:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        [leftButton release];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"ProfileViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        // Username change was successful
        self.lbl_username.text = self.loggedInUser.username;
        
    }
    else {
        NSString* duplicateUsername = self.loggedInUser.username;
        
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
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
        self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];
    }
    
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
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:@"Feedback!"];
        
        // Set up the recipients
        NSArray *toRecipients = [NSArray arrayWithObjects:@"contact@bluelabellabs.com",
                                 nil];
        
        [picker setToRecipients:toRecipients];
        
        // Present the mail composition interface
        [self presentModalViewController:picker animated:YES];
        [picker release]; // Can safely release the controller now.
    }
}

#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)onAccountButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Logout"
                                  otherButtonTitles:@"Change Username", @"Feedback", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark - UISwitch Handler
- (IBAction) onFacebookSeamlessSharingChanged:(id)sender 
{
    if ([self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        progressView.delegate = self;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        //  [resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        self.user.sharinglevel = [NSNumber numberWithBool:self.sw_seamlessFacebookSharing.on];
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        [self showDeterminateProgressBar:@"Updating your settings..." withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    }
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
+ (ProfileViewController*)createInstance {
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    //sets the user property to the curretly logged on user
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    instance.user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    instance.userID = authenticationManager.m_LoggedInUserID;
    return instance;
}

+ (ProfileViewController*)createInstanceForUser:(NSNumber *)userID {
    //returns an instance of the ProfileViewController configured for the specified user
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    instance.userID = userID;
    return instance;
    
}

@end
