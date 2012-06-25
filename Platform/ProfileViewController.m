//
//  ProfileViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProfileViewController.h"
#import "DateTimeHelper.h"
#import "PlatformAppDelegate.h"
#import "Macros.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "SettingsViewController.h"
#import "PeopleListViewController.h"
#import "Follow.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "PeopleListType.h"
#import "BookViewControllerBase.h"
#import "LeaderboardTypes.h"
#import "LeaderboardRelativeTo.h"
#import "LeaderboardViewController.h"
#import "AchievementsViewController.h"
#import "UITutorialView.h"
#import "FlurryAnalytics.h"

#define kUSERID                    @"userid"


@implementation ProfileViewController

@synthesize iv_profilePicture       = m_iv_profilePicture;
@synthesize btn_changeProfilePicture = m_btn_changeProfilePicture;
@synthesize cameraActionSheet       = m_cameraActionSheet;

@synthesize lbl_username            = m_lbl_username;
@synthesize lbl_currentLevel        = m_lbl_currentLevel;
@synthesize lbl_currentLevelDate    = m_lbl_currentLevelDate;

@synthesize btn_numPages            = m_btn_numPages;
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
@synthesize lbl_pointsLast7Days     = m_lbl_pointsLast7Days;

@synthesize user                    = m_user;
@synthesize userID                  = m_userID;

@synthesize iv_progressBarContainer = m_iv_progressBarContainer;
@synthesize iv_progressDrafts       = m_iv_progressDrafts;
@synthesize iv_progressPhotos       = m_iv_progressPhotos;
@synthesize iv_progressCaptions     = m_iv_progressCaptions;
@synthesize iv_progressPoints       = m_iv_progressPoints;
@synthesize iv_editorMinimumLine    = m_iv_editorMinimumLine;
@synthesize iv_userBestLine         = m_iv_userBestLine;

@synthesize v_pointsProgressBar          = m_v_pointsProgressBar;

@synthesize v_leaderboardContainer  = m_v_leaderboardContainer;
@synthesize v_leaderboard3Up        = m_v_leaderboard3Up;
@synthesize btn_follow              = m_btn_follow;
@synthesize btn_leaderboard3UpButton = m_btn_leaderboard3UpButton;

@synthesize allLeaderboard          = m_allLeaderboard;
@synthesize friendsLeaderboard      = m_friendsLeaderboard;
@synthesize pairsLeaderboard         = m_pairsLeaderboard;

@synthesize profileCloudEnumerator              = m_profileCloudEnumerator;
@synthesize allLeaderboardCloudEnumerator       = m_allLeaderboardCloudEnumerator;
@synthesize friendsLeaderboardCloudEnumerator   = m_friendsLeaderboardCloudEnumerator;
@synthesize pairsLeaderboardCloudEnumerator     = m_pairsLeaderboardCloudEnumerator;

//#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.2
//#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.1
#define kPROGRESSBARCONTAINERXORIGINOFFSET 22.0
#define kPROGRESSBARCONTAINERINSETRIGHT 4.0

#define kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM 1.1
#define kPROGRESSBARCONTAINERBUFFER_USERBEST 1.0
#define kPROGRESSBARCONTAINERINSETPOINTSLABEL 40.0


#pragma mark - Progress Bar methods 
- (void)drawProgressBar {
    
    int pointsLast7Days = [self.user.numberofpointslw intValue];
    //int pointsLast7Days = 200;  // used for testing
    
    float progressBarContainerWidth = self.iv_progressBarContainer.frame.size.width - kPROGRESSBARCONTAINERINSETPOINTSLABEL;
    float editorMinimumLineMidPoint = (float)self.iv_editorMinimumLine.frame.size.width / (float)2;
    float editorMinimumLabelMidPoint = (float)self.lbl_editorMinimumLabel.frame.size.width / (float)2;
    float userBestLineMidPoint = (float)self.iv_userBestLine.frame.size.width / (float)2;
    float userBestLabelMidPoint = (float)self.lbl_userBestLabel.frame.size.width / (float)2;
    
    
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    int editorMinimum = [settings.editor_minimum intValue];
    
    int userBest = [self.user.maxweeklyparticipation intValue];
    
    // determine which value will set the scale (max value) for the progress bar
    float progressBarMaxValue = MAX(MAX((float)userBest, (float)editorMinimum), (float)pointsLast7Days);
    
    if (progressBarMaxValue == (float)userBest) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_USERBEST;
    }
    else if (progressBarMaxValue == (float)editorMinimum) {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container 
        progressBarMaxValue = (float)progressBarMaxValue * (float)kPROGRESSBARCONTAINERBUFFER_EDITORMINIMUM;
    }
    else {
        // extend the max value of the progress bar to leave an appropriate whitespace buffer in the container for the points label
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
    
    
    // now draw the progress bar of the points count for the last 7 days
    float progressPoints = 0.0f;
    if ((float)progressBarMaxValue != 0.0) {
        progressPoints = ((float)pointsLast7Days) / (float)progressBarMaxValue;
    }
    //progressPoints = (float)20 / (float)progressBarMaxValue;
    self.iv_progressPoints.frame = CGRectMake(kPROGRESSBARCONTAINERXORIGINOFFSET, self.iv_progressPoints.frame.origin.y,(progressPoints * progressBarContainerWidth), self.iv_progressPoints.frame.size.height);
    [self.iv_progressPoints setHidden:NO];
    
}

/*- (void)drawProgressBar {
    
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
    
}*/

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
    
    /*// Setup follow and unfollow buttons
    UIImage* followButtonImageNormal = [UIImage imageNamed:@"button_roundrect_blue.png"];
    UIImage* stretchablefollowButtonImageNormal = [followButtonImageNormal stretchableImageWithLeftCapWidth:73 topCapHeight:22];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageNormal forState:UIControlStateNormal];
    
    UIImage* followButtonImageSelected = [UIImage imageNamed:@"button_roundrect_lightgrey_selected.png"];
    UIImage* stretchablefollowButtonImageSelected = [followButtonImageSelected stretchableImageWithLeftCapWidth:73 topCapHeight:22];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageSelected forState:UIControlStateSelected];*/
    
    // Setup follow and unfollow buttons
    UIImage* followButtonImageNormal = [UIImage imageNamed:@"button_standardcontrol_blue.png"];
    UIImage* stretchablefollowButtonImageNormal = [followButtonImageNormal stretchableImageWithLeftCapWidth:26 topCapHeight:10];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageNormal forState:UIControlStateNormal];
    
    UIImage* followButtonImageSelected = [UIImage imageNamed:@"button_standardcontrol_lightgrey_selected.png"];
    UIImage* stretchablefollowButtonImageSelected = [followButtonImageSelected stretchableImageWithLeftCapWidth:26 topCapHeight:10];
    [self.btn_follow setBackgroundImage:stretchablefollowButtonImageSelected forState:UIControlStateSelected];
    
    // Add rounded corners to leaderboard custom button
    self.btn_leaderboard3UpButton.layer.cornerRadius = 8;
    
    // Add border to custom leaderboard button
    //[self.btn_leaderboard3UpButton.layer setBorderColor: [[UIColor clearColor] CGColor]];
    //[self.btn_leaderboard3UpButton.layer setBorderWidth: 1.0];
    
    // Add mask on custom buttons
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
    
    
    // Set up cloud enumerator for leaderboards
    self.allLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kALL];
    self.friendsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kPEOPLEIKNOW];
    self.allLeaderboardCloudEnumerator.delegate = self;
    self.friendsLeaderboardCloudEnumerator.delegate = self;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.iv_profilePicture = nil;
    self.lbl_username = nil;
    self.lbl_currentLevel = nil;
    self.lbl_currentLevelDate = nil;
    self.btn_numPages = nil;
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
    self.lbl_pointsLast7Days = nil;
    self.iv_progressDrafts = nil;
    self.iv_progressPhotos = nil;
    self.iv_progressCaptions = nil;
    self.iv_progressPoints = nil;
    self.iv_editorMinimumLine = nil;
    self.iv_userBestLine = nil;
    self.iv_progressBarContainer = nil;
    self.v_leaderboardContainer = nil;
    self.v_leaderboard3Up = nil;
    self.btn_follow = nil;
    self.v_pointsProgressBar = nil;
    
}

- (void) showProfilePicture {
    //Show profile picture
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.userID forKey:kUSERID];
    
    if (self.user.imageurl != nil && ![self.user.imageurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        UIImage* image = [imageManager downloadImage:self.user.imageurl withUserInfo:nil atCallback:callback];
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
}

- (void) showLeaderBoardOfType:(int)type {
    CGRect frame = self.v_leaderboard3Up.frame;
    
    UILeaderboard3Up* leaderboard = [[UILeaderboard3Up alloc] initWithFrame:frame];
    self.v_leaderboard3Up = leaderboard;
    [leaderboard release];
    
    /*if (type == kALL) {
        // We need to build the array of leaderboard entries for the 3upLeaderboard on the profile
        NSMutableArray *threeUpEntryArray = [[NSMutableArray alloc]init];
        
        LeaderboardEntry *entry;
        for (int i = 0; i < self.allLeaderboard.entries.count; i++) {
            
            entry = [self.allLeaderboard.entries objectAtIndex:i];
            
            // We search for the index of the logged in user's entry, then take the entry before and after that index
            if ((self.loggedInUser != nil) && [entry.userid isEqualToNumber:self.loggedInUser.objectid]) 
            {
                int k = i - 1;
                int j = i + 1;
                LeaderboardEntry* entry1 = nil;
                LeaderboardEntry* entry2 = nil;

                if (k >= 0) {
                    entry1 = [self.allLeaderboard.entries objectAtIndex:k];
                    [threeUpEntryArray addObject:entry1];
                }
                
                [threeUpEntryArray addObject:entry];
                
                if (j < [self.allLeaderboard.entries count])
                {
                    entry2 = [self.allLeaderboard.entries objectAtIndex:j];
                    [threeUpEntryArray addObject:entry2];
                }
                break;

            }
        }
        
        [self.v_leaderboard3Up renderLeaderboardWithEntries:threeUpEntryArray forLeaderboard:self.allLeaderboard.objectid forUserWithID:self.userID];
        [threeUpEntryArray release];
    }
    else */
    if (type == kPEOPLEIKNOW) {
        // We need to build the array of leaderboard entries for the 3upLeaderboard on the profile
        NSMutableArray *threeUpEntryArray = [[NSMutableArray alloc]init];
        
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
                    
                    [self.v_leaderboard3Up renderLeaderboardWithEntries:threeUpEntryArray forLeaderboard:self.friendsLeaderboard.objectid forUserWithID:self.userID];
                    
                    break;
                }
            }
        }
        
        [threeUpEntryArray release];
    }
    else if (type == kONEPERSON)
    {
        if ([self.authenticationManager isUserAuthenticated] && self.loggedInUser != nil) {
            [self.v_leaderboard3Up renderLeaderboardWithEntries:self.pairsLeaderboard.entries forLeaderboard:self.pairsLeaderboard.objectid forUserWithID:self.loggedInUser.objectid];
        }
        else {
            [self.v_leaderboard3Up renderLeaderboardWithEntries:self.pairsLeaderboard.entries forLeaderboard:self.pairsLeaderboard.objectid forUserWithID:self.userID];
        }
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

- (void) render {    
    //if the user is the currently logged in user, we then enable the leaderboard container, and show the follow button
    if ([self.loggedInUser.objectid longValue] == [self.userID longValue]) {
        //yes it is
        self.v_leaderboardContainer.hidden = NO;
        self.btn_follow.hidden = YES;
    }
    else if ([self.authenticationManager isUserAuthenticated]) {
        //no it isnt, but the user is logged in
        self.v_leaderboardContainer.hidden = NO;
        self.btn_follow.hidden = NO;
        
        //set the appropriate state for the follow button
        if (![Follow doesFollowExistFor:self.userID withFollowerID:self.loggedInUser.objectid]) {
            //logged in user does not follow this person, enable the follow button
            [self.btn_follow setSelected:NO];
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        }
        else {
            //logged in user does follow this person, set follow button as selected already
            [self.btn_follow setSelected:YES];
            [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        }
    }
    else {
        //user is not logged in
        self.v_leaderboardContainer.hidden = NO;
        self.btn_follow.hidden = YES;
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
    [self showProfilePicture];
    
    [self.btn_numPages setTitle:[self.user.numberofpagespublished stringValue] forState:UIControlStateNormal];
    [self.btn_numFollowers setTitle:[self.user.numberoffollowers stringValue] forState:UIControlStateNormal];
    [self.btn_numFollowing setTitle:[self.user.numberfollowing stringValue] forState:UIControlStateNormal];
    
    /*self.lbl_draftsLast7Days.text = [self.user.numberofdraftscreatedlw stringValue];
    self.lbl_photosLast7Days.text = [self.user.numberofphotoslw stringValue];
    self.lbl_captionsLast7Days.text = [self.user.numberofcaptionslw stringValue];
    
    int totalLast7Days = [self.user.numberofcaptionslw intValue]
        + [self.user.numberofphotoslw intValue]
        + [self.user.numberofdraftscreatedlw intValue];
    self.lbl_totalLast7Days.text = [NSString stringWithFormat:@"%d", totalLast7Days];
    //self.lbl_totalLast7Days.text = [self.user.numberofpoints stringValue];*/
    
    //self.lbl_pointsLast7Days.text = [self.user.numberofpointslw stringValue];
    //self.lbl_pointsLast7Days.text = @"100000";
    
    //self.lbl_userBestLabel.text = [NSString stringWithFormat:@"Best: %d", [self.user.maxweeklyparticipation intValue]];
    
    // Show the progress bar
    //[self drawProgressBar];
    CGRect frame = self.v_pointsProgressBar.frame;
    UIPointsProgressBar* progressBar = [[UIPointsProgressBar alloc] initWithFrame:frame];
    [progressBar renderProgressBarForUserWithID:self.userID];
    self.v_pointsProgressBar = progressBar;
    [self.view addSubview:self.v_pointsProgressBar];
    [progressBar release];
    //[self.v_pointsProgressBar setHidden:YES];
    
    // Create gesture recognizer for the points progress bar view to handle a single tap
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAchievements)] autorelease];
    
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    
    // Add the gesture to the points progress bar view view
    [self.v_pointsProgressBar addGestureRecognizer:oneFingerTap];
    
    //enable gesture events on the points progress bar view
    [self.v_pointsProgressBar setUserInteractionEnabled:YES];
}


- (void) enumerateUser:(NSNumber*)userid 
{
    //object doesnt exist in the store, we need to grab it from the cloud
    //NSArray* objectIDs = [NSArray arrayWithObject:userid];
    //NSArray* objectTypes = [NSArray arrayWithObject:USER];
    
    if (self.profileCloudEnumerator != nil) {
        [self.profileCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.profileCloudEnumerator = nil;
        self.profileCloudEnumerator = [CloudEnumerator enumeratorForUser:userid];
        self.profileCloudEnumerator.delegate = self;
        [self.profileCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumeratePairsLeaderboard
{
    //will take the current userid and the logged inuserid and request a pairs leaderboard for them
    if (self.pairsLeaderboardCloudEnumerator != nil)
    {
        [self.pairsLeaderboardCloudEnumerator enumerateUntilEnd:nil];
    }
    else
    {
        self.pairsLeaderboardCloudEnumerator = nil;
        self.pairsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForPairsLeaderboard:self.loggedInUser.objectid ofType:kWEEKLY forTarget:self.userID];
        self.pairsLeaderboardCloudEnumerator.delegate = self;
        
        [self.pairsLeaderboardCloudEnumerator enumerateUntilEnd:nil];
        
    }
}

- (void) enumerateLeaderboards:(NSNumber*)userid 
{
    self.allLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kALL];
    self.allLeaderboardCloudEnumerator.delegate = self;
    
    [self.allLeaderboardCloudEnumerator enumerateUntilEnd:nil];
    
    self.friendsLeaderboardCloudEnumerator = [CloudEnumerator enumeratorForLeaderboard:self.userID ofType:kWEEKLY relativeTo:kPEOPLEIKNOW];
    self.friendsLeaderboardCloudEnumerator.delegate = self;
    
    [self.friendsLeaderboardCloudEnumerator enumerateUntilEnd:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //We show an alert view if this is the first time they have used this VC
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([userDefaults boolForKey:setting_HASVIEWEDPROFILEVC] == NO) 
//    {
//        //it is the first time, we show the alert screen
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Track your Bahndr impact..." message:ui_WELCOME_PROFILE delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//        
//        [alert show];
//        [alert release];
//        
//    }
    
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
    
    // Ensure we have the user object for this profile
    if (self.user == nil) {
        // Enumerate the User object for this profile
        [self enumerateUser:self.userID];
    }
    
    // Enumerate the leaderboards for this user
    if ([self.authenticationManager isUserAuthenticated] && self.loggedInUser && self.userID)
    {
        if ([self.userID isEqualToNumber:self.loggedInUser.objectid])
        {
            //it is the currently logged on user, show normal leaderboard
            [self enumerateLeaderboards:self.userID];
        }
        else
        {
            //not the current user we are looking at, show a pairs leaderboard
            [self enumeratePairsLeaderboard];
        }
    }
    else
    {
        //no user logged in, we show the normal leaderboard
        [self enumerateLeaderboards:self.userID];
    }
    
    
    /*if (self.loggedInUser)
    {
        if (![self.userID isEqualToNumber:self.loggedInUser.objectid])
        {
            //not the current user we are looking at, show a pairs leaderboard
            [self enumeratePairsLeaderboard];
        }
        else
        {
            //it is the currently logged on user, show normal leaderboard
            [self enumerateLeaderboards:self.userID];
        }
    }
    else
    {
        //no user logged in, we show the normal leaderboard
        [self enumerateLeaderboards:self.userID];
    }
    
    
    
    
    
    if (self.loggedInUser &&
        [self.userID isEqualToNumber:self.loggedInUser.objectid])
    {
        [self enumerateLeaderboards:self.userID];
    }
    else if (self.loggedInUser)
    {
        //user is not the logged in user, so we display a pairs leaderboard
        [self enumeratePairsLeaderboard];
    }*/
    
    // Render the profile view
    if (self.user != nil) {
        [self render];             
    }
    
    // Setup appropriate Navbar buttons
    if (self.userID && self.loggedInUser.objectid && [self.userID isEqualToNumber:self.loggedInUser.objectid]) {
        // Only enable the Account button and profile picture button for the logged in user
        UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"Settings"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(onAccountButtonPressed:)];
        self.navigationItem.leftBarButtonItem = leftButton;
        [leftButton release];
        
        UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                         target:self
                                         action:@selector(onDoneButtonPressed:)] autorelease];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        [self.btn_changeProfilePicture setEnabled:YES];
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
        
        //set the appropriate title for the follow button
        /*NSString* followButtonTitle;
        if (![Follow doesFollowExistFor:self.userID withFollowerID:self.loggedInUser.objectid]) {
            //logged in user does not follow this person, enable the follow button
            followButtonTitle = @"Follow";
        }
        else {
            //logged in user does follow this person, set follow button as selected already
             followButtonTitle = @"Unfollow";
        }
        
        UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                         initWithTitle:followButtonTitle
                                         style:UIBarButtonItemStyleDone
                                         target:self
                                        action:@selector(onFollowButtonPressed:)] autorelease];
        self.navigationItem.rightBarButtonItem = rightButton;*/
        
        // Show Done button
        UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                        target:self
                                        action:@selector(onDoneButtonPressed:)] autorelease];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        // Disable/hide any profile objects that should not be presented or enabled for a user who is not logged in
        [self.btn_changeProfilePicture setEnabled:NO];
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logEvent:@"VIEWING_PROFILEVIEW" timed:YES];
    
    //we mark that the user has viewed this viewcontroller at least once
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDPROFILEVC]==NO) 
    {
        [self onInfoButtonPressed:nil];
        [userDefaults setBool:YES forKey:setting_HASVIEWEDPROFILEVC];
        [userDefaults synchronize];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [FlurryAnalytics endTimedEvent:@"VIEWING_PROFILEVIEW" withParameters:nil];
    
    // Remove the subviews added in viewWillAppear because they will be rendered again when the view reappears
    [self.v_pointsProgressBar removeFromSuperview];
//    [self.v_leaderboard3Up removeFromSuperview];
//    [self.btn_leaderboard3UpButton removeFromSuperview];
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

#pragma mark - Segmented Control management
- (IBAction)indexDidChangeForSegmentedControl:(UISegmentedControl*)segmentedControl {
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    
    if (index == 1) {
        [self showLeaderBoardOfType:kPEOPLEIKNOW];
    }
    else if (index == 2) {
        [self showLeaderBoardOfType:kALL];
    }
}

#pragma mark - UIButton Handlers
- (IBAction) onLeaderboardButtonPressed:(id)sender
{
    //we need to launch the leaderboard view controller
    //we are going to launch with the friends leaderboard
    LeaderboardViewController* leaderBoardViewController = [LeaderboardViewController createInstanceFor:self.friendsLeaderboard.objectid forUserID:self.userID];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"User" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    [self.navigationController pushViewController:leaderBoardViewController animated:YES];
}

- (IBAction) onChangeProfilePictureButtonPressed:(id)sender {
    //Change profile picture button pressed
    self.cameraActionSheet = [UICameraActionSheet createCameraActionSheetWithTitle:@"Change Profile Picture" allowsEditing:YES];
    self.cameraActionSheet.a_delegate = self;
    [self.cameraActionSheet showInView:self.view];
}

- (IBAction) onPublishedButtonPressed:(id)sender {
    // We launch the BookViewController and open it up to the page we specified
    BookViewControllerBase* bookViewController = [BookViewControllerBase createInstanceWithUserID:self.userID];
    
    // Modal naviation
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

- (IBAction) onFollowersButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceOfListType:kFOLLOWERS withUserID:self.userID];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"User" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
}

- (IBAction) onFollowingButtonPressed:(id)sender {
    PeopleListViewController* peopleListViewController = [PeopleListViewController createInstanceOfListType:kFOLLOWING withUserID:self.userID];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"User" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    [self.navigationController pushViewController:peopleListViewController animated:YES];
}

- (void) processFollowUser {
    NSString* activityName = @"ProfileViewController.processFollowUser:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    if ([loggedInUserID longValue] != [self.userID longValue]) 
    {
        if (![Follow doesFollowExistFor:self.userID withFollowerID:loggedInUserID]) 
        {
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            progressView.delegate = self;
            
            //we create a Follow object and then save it
            [Follow createFollowFor:self.userID withFollowerID:loggedInUserID];
            
            // update followers count on profile
            [self.btn_numFollowers setTitle:[self.user.numberoffollowers stringValue] forState:UIControlStateNormal];
            
            //lets save it
            ResourceContext* resourceContext = [ResourceContext instance];
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@ Created follow object for user %@ to follow user %@",activityName,loggedInUserID,self.userID);
            
            ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
            
            [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:[NSString stringWithFormat:@"Following %@...", user.username]]];
        }
        else {
            //error case
            LOG_PERSONALLOGVIEWCONTROLLER(1, @"%@ Follow relationship already exists for user %@ to follow user %@",activityName,loggedInUserID,self.userID);
        }
    }
    else {
        LOG_PERSONALLOGVIEWCONTROLLER(1, @"%@User cannot follow themself",activityName);
    }
}

- (void) processUnfollowUser {
    //we need to unfollow a person here
    NSString* activityName = @"ProfileViewController.processUnfollowUser:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    if ([loggedInUserID longValue] != [self.userID longValue]) 
    {
        if ([Follow doesFollowExistFor:self.userID withFollowerID:loggedInUserID]) 
        {
            PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
            UIProgressHUDView* progressView = appDelegate.progressView;
            progressView.delegate = self;
            
            //we remove the follow object and then save it
            [Follow unfollowFor:self.userID withFollowerID:loggedInUserID];
            
            // update followers count on profile
            [self.btn_numFollowers setTitle:[self.user.numberoffollowers stringValue] forState:UIControlStateNormal];
            
            ResourceContext* resourceContext = [ResourceContext instance];
            [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
            
            LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@ Unfollowed relationship for user %@ to unfollow user %@",activityName,loggedInUserID,self.userID);
            
            ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
            User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
            
            [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:[NSString stringWithFormat:@"Unfollowing %@...", user.username]]];
        }
        else {
            //error case
            LOG_PERSONALLOGVIEWCONTROLLER(1, @"%@ Follow relationship does not exist for user %@ to unfollow user %@",activityName,loggedInUserID,self.userID);
        }
    }
    else 
    {
        LOG_PERSONALLOGVIEWCONTROLLER(1,@"%@User cannot unfollow themself",activityName);
    }
}

- (IBAction) onFollowButtonPressed:(id)sender {
    NSString* activityName = @"ProfileViewController.onFollowButtonPressed:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    //first we toggle the state of the follow button
    [self.btn_follow setSelected:!self.btn_follow.selected];
    
    //if (self.btn_follow.selected == YES) {
    if (![Follow doesFollowExistFor:self.userID withFollowerID:self.loggedInUser.objectid]) {
        //logged in user wants to follow this person
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@ User %@ wants to follow user %@",activityName,loggedInUserID,self.userID);
        [self processFollowUser];
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    else {
        //logged in user wants to unfollow this person
        LOG_PERSONALLOGVIEWCONTROLLER(0, @"%@ User %@ wants to unfollow user %@",activityName,loggedInUserID,self.userID);
        [self processUnfollowUser];
        [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
    }
    
}

- (void)showAchievements {
    AchievementsViewController* achievementsViewController = [AchievementsViewController createInstanceForUserWithID:self.userID];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:achievementsViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
}

- (IBAction)onInfoButtonPressed:(id)sender {
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewProfile"];
    [self.view addSubview:infoView];
    [infoView release];
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"ProfileViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    NSArray* requests = progressView.requests;
    Request* request = [requests objectAtIndex:0];
    NSArray* changedAttributes = request.changedAttributesList;
    NSString* changedAttribute = [changedAttributes objectAtIndex:0];
    
    if (progressView.didSucceed) {
        if ([changedAttribute isEqualToString:IMAGEURL] ||
            [changedAttribute isEqualToString:THUMBNAILURL]) 
        {
            // profile picture change was successful
            [self showProfilePicture];
        }
        else {
            // Follow/Unfollow request was successful
            // set the appropriate title for the follow button on the nav bar
            /*NSString* followButtonTitle;
            if (![Follow doesFollowExistFor:self.userID withFollowerID:self.loggedInUser.objectid]) {
                //logged in user does not follow this person, enable the follow button
                followButtonTitle = @"Follow";
            }
            else {
                //logged in user does follow this person, set follow button as selected already
                followButtonTitle = @"Unfollow";
            }
            
            self.navigationItem.rightBarButtonItem.title = followButtonTitle;*/
        }
        
    }
    else 
    {
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        
        //we need to determine that if this was a photo change or a follow change
        if ([changedAttribute isEqualToString:IMAGEURL] ||
            [changedAttribute isEqualToString:THUMBNAILURL]) 
        {
            //it was a failed attempt to change their picture
            [self showProfilePicture];
        }
        else 
        {
            // Follow/Unfollow request was unsuccessful
            // set the appropriate title for the follow button on the nav bar
            /*NSString* followButtonTitle;
            if (![Follow doesFollowExistFor:self.userID withFollowerID:self.loggedInUser.objectid]) {
                //logged in user does not follow this person, enable the follow button
                followButtonTitle = @"Follow";
            }
            else {
                //logged in user does follow this person, set follow button as selected already
                followButtonTitle = @"Unfollow";
            }
            
            self.navigationItem.rightBarButtonItem.title = followButtonTitle;*/
            
            [self.btn_follow setSelected:!self.btn_follow.selected];
            if (self.btn_follow.selected == YES) {
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
            }
            else {
                [self.btn_follow.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
            }
        }
        [self render];
    }
}

#pragma mark - UICameraActionSheetDelegate methods
- (void) displayPicker:(UIImagePickerController*) picker {
    [self presentModalViewController:picker animated:YES];
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image {
    //we handle back end processing of the image from the camera sheet here
    if ([self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        progressView.delegate = self;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        ImageManager* imageManager = [ImageManager instance];
        
        NSString* picFilename = [NSString stringWithFormat:@"%@-imageurl",self.userID];
        self.user.imageurl = [imageManager saveImage:image withFileName:picFilename];
        
        NSString* thumbnailFilename = [NSString stringWithFormat:@"%@-thumbnailurl",self.userID];
        self.user.thumbnailurl = [imageManager saveImage:thumbnailImage withFileName:thumbnailFilename];
        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        
        [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!\n\nLooking good, hot stuff." onFailureMessage:@"Failed :(\n\nTry your good side." inProgressMessages:[NSArray arrayWithObject:@"Updating your profile picture..."]];
    }
    
}

- (void) onCancel {
    // we deal with cancel operations from the action sheet here
    
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    ResourceContext* resourceContext = [ResourceContext instance];
    User* user = (User*)[resourceContext resourceWithType:USER withID:self.userID];
    NSNumber* userid = user.objectid;
    
    if (enumerator == self.profileCloudEnumerator) {
        self.user = user;
        self.userID = userid;
        if (self.user != nil && self.userID != nil) {
            [self render];
        }
    }
    else if (enumerator == self.allLeaderboardCloudEnumerator) {
        // Get the leaderboad object from the resource context
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kALL], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.allLeaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        
        //[self showLeaderBoardOfType:kALL]; In the profile, we don't show the leaderboard relative to all people
    }
    else if (enumerator == self.friendsLeaderboardCloudEnumerator) {
        // Get the leaderboad object from the resource context
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kPEOPLEIKNOW], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.friendsLeaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        
        [self showLeaderBoardOfType:kPEOPLEIKNOW];
    }
    else if (enumerator == self.pairsLeaderboardCloudEnumerator)
    {
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATECREATED ascending:NO];
        NSArray* valuesArray = [NSArray arrayWithObjects:[self.userID stringValue], [NSString stringWithFormat:@"%d",kONEPERSON], nil];
        NSArray* attributesArray = [NSArray arrayWithObjects:USERID, RELATIVETO, nil];
        NSArray* sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        self.pairsLeaderboard = (Leaderboard*)[resourceContext resourceWithType:LEADERBOARD withValuesEqual:valuesArray forAttributes:attributesArray sortBy:sortDescriptors];
        [self showLeaderBoardOfType:kONEPERSON];
    }
    
    [self.view setNeedsDisplay];
}

#pragma mark - Async callbacks
- (void)onImageDownloadComplete:(CallbackResult*)result {
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

#pragma mark - Static Initializers
+ (ProfileViewController*)createInstance {
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    //sets the user property to the currently logged on user
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    instance.userID = authenticationManager.m_LoggedInUserID;
    instance.user = (User*)[resourceContext resourceWithType:USER withID:instance.userID];
    return instance;
}

+ (ProfileViewController*)createInstanceForUser:(NSNumber *)userID {
    //returns an instance of the ProfileViewController configured for the specified user
    ProfileViewController* instance = [[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]autorelease];
    //sets the user property to the userid passed in
    ResourceContext* resourceContext = [ResourceContext instance];
    instance.userID = userID;
    instance.user = (User*)[resourceContext resourceWithType:USER withID:instance.userID];
    return instance;
}

@end
