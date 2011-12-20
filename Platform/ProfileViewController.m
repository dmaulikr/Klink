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
