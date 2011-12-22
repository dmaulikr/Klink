//
//  ProfileViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 12/6/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "DateTimeHelper.h"

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


#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 22.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0

#define kEDITORMINIMUM 10
#define kUSERBEST 6

#pragma mark - Progress Bar methods 
- (void)drawProgressBar {    
    int totalSubmissionsLast7Days = [self.loggedInUser.numberofdraftscreatedlw intValue]
    + [self.loggedInUser.numberofphotoslw intValue]
    + [self.loggedInUser.numberofcaptionslw intValue];
    
    float progressBarContainerWidth = self.iv_progressBarContainer.frame.size.width - kPROGRESSBARCONTAINERINSETRIGHT;
    float editorMinimumLineMidPoint = (float)self.iv_editorMinimumLine.frame.size.width / (float)2;
    float editorMinimumLabelMidPoint = (float)self.lbl_editorMinimumLabel.frame.size.width / (float)2;
    float userBestLineMidPoint = (float)self.iv_userBestLine.frame.size.width / (float)2;
    float userBestLabelMidPoint = (float)self.lbl_userBestLabel.frame.size.width / (float)2;
    
    // TEMP DELETE THE LINE BELOW, USED FOR TESTING
    //totalSubmissionsLast7Days = 0;
    
    // determine which value will set the scale (max value) for the progress bar
    float progressBarMaxValue = MAX(MAX((float)kUSERBEST, (float)kEDITORMINIMUM), (float)totalSubmissionsLast7Days);
    
    if (progressBarMaxValue == kUSERBEST) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_USERBEST;
    }
    else if (progressBarMaxValue == kEDITORMINIMUM) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM;
    }
    else {
        // let the progress bar container be filled by the users current count of submissions
    }
    
    
    float scaleEditorMinimum = (float)kEDITORMINIMUM / (float)progressBarMaxValue;
    float scaleUserBest = (float)kUSERBEST / (float)progressBarMaxValue;
    
    
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
    float userBestLabelXOrigin = MAX(kPROGRESSBARCONTAINERXORIGINOFFSET, kPROGRESSBARCONTAINERXORIGINOFFSET + userBestWidth - userBestLabelMidPoint);
    self.lbl_userBestLabel.frame = CGRectMake(userBestLabelXOrigin, self.lbl_userBestLabel.frame.origin.y, self.lbl_userBestLabel.frame.size.width, self.lbl_userBestLabel.frame.size.height);
    
    
    // now sequentially draw the progress bars for the draft, photo and caption counts for the last 7 days
    // drafts in the last 7 days
    float progressDrafts = (float)[self.loggedInUser.numberofdraftscreatedlw intValue] / (float)progressBarMaxValue;
    //float progressDrafts = (float)3 / (float)progressBarMaxValue;
    self.iv_progressDrafts.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET, self.iv_progressDrafts.frame.origin.y,(progressDrafts * progressBarContainerWidth), self.iv_progressDrafts.frame.size.height);
    
    // photos in the last 7 days
    float progressPhotos = (float)[self.loggedInUser.numberofphotoslw intValue] / (float)progressBarMaxValue;
    //float progressPhotos = (float)2 / (float)progressBarMaxValue;
    self.iv_progressPhotos.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET + self.iv_progressDrafts.frame.size.width, self.iv_progressPhotos.frame.origin.y,(progressPhotos * progressBarContainerWidth), self.iv_progressPhotos.frame.size.height);
    
    // captions in the last 7 days
    float progressCaptions = (float)[self.loggedInUser.numberofcaptionslw intValue] / (float)progressBarMaxValue;
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
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    
    // set custom font on views with text
    [self.lbl_username setFont:[UIFont fontWithName:@"TravelingTypewriter" size:21]];
    [self.lbl_employeeStartDate setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_currentLevel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:16]];
    [self.lbl_currentLevelDate setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_numPages setFont:[UIFont fontWithName:@"TravelingTypewriter" size:21]];
    [self.lbl_numVotes setFont:[UIFont fontWithName:@"TravelingTypewriter" size:21]];
    [self.lbl_numSubmissions setFont:[UIFont fontWithName:@"TravelingTypewriter" size:21]];
    [self.lbl_pagesLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    [self.lbl_votesLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    [self.lbl_submissionsLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:13]];
    [self.lbl_submissionsLast7DaysLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:15]];
    [self.lbl_editorMinimumLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:11]];
    [self.lbl_userBestLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:11]];
    [self.lbl_draftsLast7Days setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_photosLast7Days setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_captionsLast7Days setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_totalLast7Days setFont:[UIFont fontWithName:@"TravelingTypewriter" size:14]];
    [self.lbl_draftsLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_photosLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_captionsLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    [self.lbl_totalLabel setFont:[UIFont fontWithName:@"TravelingTypewriter" size:12]];
    
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set status bar style to black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Navigation bar
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:nil];
    
    // Set the navigationbar title
    self.navigationItem.title = @"Writers's Log";
    
    // Set up the labels
    if (self.loggedInUser) {
        self.lbl_username.text = self.loggedInUser.displayname;
        self.lbl_employeeStartDate.text = [NSString stringWithFormat:@"start date: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.loggedInUser.datecreated]]];
        self.lbl_currentLevel.text = self.loggedInUser.iseditor ? @"Editor" : @"Contributor";
        self.lbl_currentLevelDate.text = [NSString stringWithFormat:@"since: %@", [DateTimeHelper formatMediumDate:[DateTimeHelper parseWebServiceDateDouble:self.loggedInUser.datebecameeditor]]];
        self.lbl_numPages.text = [self.loggedInUser.numberofpagespublished stringValue];
        self.lbl_numVotes.text = [self.loggedInUser.numberofvotes stringValue];
        
        int totalSubmissions = [self.loggedInUser.numberofdraftscreatedlw intValue]
                                + [self.loggedInUser.numberofphotoslw intValue]
                                 + [self.loggedInUser.numberofcaptionslw intValue];
        self.lbl_numSubmissions.text = [NSString stringWithFormat:@"%d", totalSubmissions];
        
        self.lbl_draftsLast7Days.text = [self.loggedInUser.numberofdraftscreatedlw stringValue];
        self.lbl_photosLast7Days.text = [self.loggedInUser.numberofphotoslw stringValue];
        self.lbl_captionsLast7Days.text = [self.loggedInUser.numberofcaptionslw stringValue];
        self.lbl_totalLast7Days.text = [NSString stringWithFormat:@"%d", totalSubmissions];
        
        [self drawProgressBar];
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

#pragma mark - Static Initializers
+ (ProfileViewController*)createInstance {
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    return instance;
}

@end
