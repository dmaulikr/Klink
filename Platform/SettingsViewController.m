//
//  SettingsViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 3/19/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "PlatformAppDelegate.h"
#import "UIPromptAlertView.h"
#import "UIProgressHUDView.h"
#import "Macros.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "ImageManager.h"
#import <sys/utsname.h>
#import "Attributes.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize tc_changePictureTableViewCell   = m_tc_changePictureTableViewCell;
@synthesize tc_changeUsernameTableViewCell  = m_tc_changeUsernameTableViewCell;
@synthesize tc_logoutTableViewCell          = m_tc_logoutTableViewCell;
@synthesize tc_emailTableViewCell           = m_tc_emailTableViewCell;
@synthesize tc_inviteTableViewCell          = m_tc_inviteTableViewCell;
@synthesize tc_facebookSwitchTableViewCell  = m_tc_facebookSwitchTableViewCell;
@synthesize lbl_facebookTableViewCellLabel  = m_lbl_facebookTableViewCellLabel;
@synthesize sw_seamlessFacebookSharing      = m_sw_seamlessFacebookSharing;
@synthesize user                            = m_user;
@synthesize userID                          = m_userID;
@synthesize cameraActionSheet               = m_cameraActionSheet;


#define kMAXUSERNAMELENGTH 15


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(onDoneButtonPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Set Navigation bar title style with typewriter font
    CGSize labelSize = [@"Settings" sizeWithFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.0]];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 44)];
    titleLabel.text = @"Settings";
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
    
    self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tc_changePictureTableViewCell = nil;
    self.tc_changeUsernameTableViewCell = nil;
    self.tc_logoutTableViewCell = nil;
    self.tc_emailTableViewCell = nil;
    self.tc_inviteTableViewCell = nil;
    self.tc_facebookSwitchTableViewCell = nil;
    self.lbl_facebookTableViewCellLabel = nil;
    self.sw_seamlessFacebookSharing = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"SettingsViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    Request* request = [progressView.requests objectAtIndex:0];
    //now we have the request
    NSArray* changedAttributes = request.changedAttributesList;
    //list of all changed attributes
    //we take the first one and base our messaging off that
    NSString* attributeName = [changedAttributes objectAtIndex:0];
    
    if (progressView.didSucceed) {
        if (![attributeName isEqualToString:SHARINGLEVEL]) {
            // Change was successful, go back to profile to show the user
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else {
        NSString* duplicateUsername = self.loggedInUser.username;
        
        //we need to undo the operation that was last performed
        LOG_REQUEST(0, @"%@ Rolling back actions due to request failure",activityName);
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext.managedObjectContext.undoManager undo];
        
        NSError* error = nil;
        [resourceContext.managedObjectContext save:&error];
        
        
        NSString* title = nil;
        NSString* message = nil;
        //we need to determine what operation failed
        
        
        if ([attributeName isEqualToString:USERNAME]) 
        {
            //username change failed
            title = @"Change Username";
            message = [NSString stringWithFormat:@"\n\n\"%@\" is not available. Please try another username.",duplicateUsername];
            
            // Show the Change Username alert view again
            UIPromptAlertView* alert = [[UIPromptAlertView alloc]
                                        initWithTitle:title
                                        message:[NSString stringWithFormat:message]
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"Change", nil];
            [alert setMaxTextLength:kMAXUSERNAMELENGTH];
            [alert show];
            [alert release];
        }
        else if ([attributeName isEqualToString:SHARINGLEVEL])
        {
            //seamless sharing change failed
            // handle fail on change of seamless sharing option
            self.sw_seamlessFacebookSharing.on = [self.user.sharinglevel boolValue];
        }
    }
    
}


#pragma mark - Feedback Mail Helper	
NSString*	
machineNameSettings()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void)composeFeedbackMail {
    // Get version information about the app and phone to prepopulate in the email
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString* deviceType = machineNameSettings();
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    NSNumber* loggedInUserID = authenticationManager.m_LoggedInUserID;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"%@ Feedback!", appName]];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"contact@bahndr.com", nil];
    [picker setToRecipients:toRecipients];
    
    NSString *messageHeader = [NSString stringWithFormat:@"I'm using %@ version %@ on my %@ running iOS %@, %@.<br><br>--- Please add your message below this line ---", appName, appVersionNum, deviceType, currSysVer, [loggedInUserID stringValue]];
    [picker setMessageBody:messageHeader isHTML:YES];
    
    // Present the mail composition interface
    [self presentModalViewController:picker animated:YES];
    [picker release]; // Can safely release the controller now.
}

- (void)composeInviteMail {
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    // Set the email subject
    [picker setSubject:[NSString stringWithFormat:@"Start %@ing with me!", appName]];
    
    NSString *messageHeader = [NSString stringWithFormat:@"I've just started using this new app called %@. I think you'll find it interesting. You should download it and start %@ing with me.<br><br><a href='http://bit.ly/yzgdw3'>Download Bahndr from the AppStore</a><br><br>%@", appName, appName, self.user.displayname];
    [picker setMessageBody:messageHeader isHTML:YES];
    
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

#pragma mark - UISwitch Handler
- (IBAction) onFacebookSeamlessSharingChanged:(id)sender 
{
    if ([self.user.objectid isEqualToNumber:self.loggedInUser.objectid]) {
        PlatformAppDelegate* appDelegate =(PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
        UIProgressHUDView* progressView = appDelegate.progressView;
        progressView.delegate = self;
        
        ResourceContext* resourceContext = [ResourceContext instance];
        //[resourceContext.managedObjectContext.undoManager beginUndoGrouping];
        self.user.sharinglevel = [NSNumber numberWithBool:self.sw_seamlessFacebookSharing.on];
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        
        [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!" onFailureMessage:@"Failed :(" inProgressMessages:[NSArray arrayWithObject:@"Updating your settings..."]];
        //[self showDeterminateProgressBar:@"Updating your settings..." withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
        
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        // Account section
        return 3;
    }
    else if (section == 1) {
        // Feedback section
        return 2;
    }
    else if (section == 2) {
        // Facebook section
        return 1;
    }
    else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        // Account section
        return @"Account";
    }
    else if (section == 1) {
        // Feedback section
        return @"Feedback";
    }
    else if (section == 2) {
        // Facebook section
        return @"Facebook";
    }
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        // Facebook section
        return @"Toggle seamless sharing to automatically post all photos, captions and drafts you create to your Facebook wall.";
    }
    else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // Account section
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"ChangePicture";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_changePictureTableViewCell;
            }
            
            return cell;
        }
        else if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"ChangeUsername";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_changeUsernameTableViewCell;
            }
            
            return cell;
        }
        else if (indexPath.row == 2) {
            static NSString *CellIdentifier = @"Logout";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_logoutTableViewCell;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            return cell;
        }
        
    }
    else if (indexPath.section == 1) {
        // Feedback section
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"Email";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_emailTableViewCell;
            }
            
            return cell;
        }
        else if (indexPath.row == 1) {
            static NSString *CellIdentifier = @"Invite";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_inviteTableViewCell;
            }
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        // Facebook section
        static NSString *CellIdentifier = @"SeamlessSharing";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_facebookSwitchTableViewCell;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        // Account section
        
        if (indexPath.row == 0) {
            //Change profile picture
            self.cameraActionSheet = [UICameraActionSheet createCameraActionSheetWithTitle:@"Change Profile Picture" allowsEditing:YES];
            self.cameraActionSheet.a_delegate = self;
            [self.cameraActionSheet showInView:self.view];
        }
        else if (indexPath.row == 1) {
            //Change username
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
        else {
            //Logout
            if ([self.authenticationManager isUserAuthenticated]) {
                [self.authenticationManager logoff];
            }
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    else if (indexPath.section == 1) {
        // Feedback section
        
        if (indexPath.row == 0) {
            [self composeFeedbackMail];
        }
        else {
            [self composeInviteMail];
        }
    }
    else {
        // Facebook section
        // Do nothing, switch handled by IBAction
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    // Set section title style with typewriter font 
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 8, 320, 20);
    label.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:16.0];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = sectionTitle;
    
    UIView *view = [[[UIView alloc] init] autorelease];
    [view addSubview:label];
    
    return view;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // Set section footer style with typewriter font 
    NSString *sectionFooter = [self tableView:tableView titleForFooterInSection:section];
    if (sectionFooter == nil) {
        return nil;
    }
    
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 8, 280, 63);
    label.font = [UIFont fontWithName:@"AmericanTypewriter" size:14.0];
    label.numberOfLines = 3;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.text = sectionFooter;
    
    UIView *view = [[[UIView alloc] init] autorelease];
    [view addSubview:label];
    
    return view;
    
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
        
        
        // Profile picture change was successful, go back to profile to show the user
        [self dismissModalViewControllerAnimated:YES];

        
        [resourceContext save:YES onFinishCallback:nil trackProgressWith:progressView];
        ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
        

        
        [self showDeterminateProgressBarWithMaximumDisplayTime:settings.http_timeout_seconds onSuccessMessage:@"Success!\n\nLooking good, hot stuff." onFailureMessage:@"Failed :(\n\nTry your good side." inProgressMessages:[NSArray arrayWithObject:@"Updating your profile picture..."]];
    }
    

}

- (void) onCancel {
    // we deal with cancel operations from the action sheet here
    
}


#pragma mark - Navigation Bar button handler 
- (void)onDoneButtonPressed:(id)sender {    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Static Initializer
+ (SettingsViewController*)createInstance {
    SettingsViewController* settingsViewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    [settingsViewController autorelease];
    
    //sets the user property to the currently logged on user
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    settingsViewController.user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    settingsViewController.userID = authenticationManager.m_LoggedInUserID;
    return settingsViewController;
}

@end
