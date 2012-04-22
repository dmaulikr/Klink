//
//  SignUpViewController.m
//  Platform
//
//  Created by Jasjeet Gill on 4/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "SignUpViewController.h"
#import "PlatformAppDelegate.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "GetAuthenticatorResponse.h"
#import "ErrorCodes.h"

@implementation SignUpViewController
@synthesize tf_email        = m_tf_email;
@synthesize tf_password     = m_tf_password;
@synthesize tf_username     = m_tf_username;
@synthesize tf_password2    = m_tf_password2;
@synthesize btn_join        = m_btn_join;
@synthesize lbl_error       = m_lbl_error;
@synthesize tf_displayName  = m_tf_displayName;
@synthesize btn_cancel      = m_btn_cancel;
@synthesize tf_active       = m_tf_active;


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
    
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated
{
    self.lbl_error.hidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.tf_active = textField;
}


#pragma mark - IBAction handlers
- (IBAction)backgroundClick:(id)sender
{

    [self.tf_active resignFirstResponder];
}

- (IBAction) onJoinPressed:(id)sender
{
    //called when the user presses the join button
    NSString* password = self.tf_password.text;
    NSString* password2 = self.tf_password2.text;
    NSString* username = self.tf_username.text;
    NSString* email = self.tf_email.text;
    NSString* displayName = self.tf_displayName.text;
    
    self.lbl_error.hidden = YES;
    
    PlatformAppDelegate* appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString* deviceToken = appDelegate.deviceToken;
    UIProgressHUDView* progressView = appDelegate.progressView;
    progressView.delegate = self;
    
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
                                    
    //todo need to have error logic here to ensure the values are correct
    ResourceContext* resourceContext = [ResourceContext instance];
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onJoinComplete:) fireOnMainThread:YES];
    
    [resourceContext createUserAndGetAuthenticatorTokenWithEmail:email 
                                                    withPassword:password 
                                                 withDisplayName:displayName 
                                                    withUsername:username 
                                                 withDeviceToken:deviceToken 
                                                  onFinishNotify:callback 
                                               trackProgressWith:progressView];
    
    
    [self showDeterminateProgressBarWithMaximumDisplayTime:settings.progress_maxsecondstodisplay onSuccessMessage:@"Welcome, get ready to Bahndr!" onFailureMessage:@"Let's try this again..."  inProgressMessages:[NSArray arrayWithObject:@"Caculating energy coefficients..."]];
    
}



- (IBAction)onCancelPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIProgresHUDViewDelegate
- (void) hudWasHidden:(MBProgressHUD *)hud
{
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    
                            
}

- (void) hudWasHidden
{
    
}


#pragma mark - Async Event Handlers
- (void) onJoinComplete:(CallbackResult*)result
{

    //called when operation completes
    GetAuthenticatorResponse* response = (GetAuthenticatorResponse*)result.response;
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    if ([response.didSucceed boolValue] == YES)
    {
        ///it did succeed, we need to login the user and  dismiss ourselves
        BOOL didLoginSuccessfully = [authenticationManager processAuthenticationResponse:result];
        
        if (didLoginSuccessfully)
        {
            //user has been successfully logged in
            //[self dismissModalViewControllerAnimated:YES];
        }
        else {
            //unknown error condition
        }
    }
    else 
    {
        //it failed, we diagnose by inspecting the errorcode ont he request
        int errorCode = [response.errorCode intValue];
        if (errorCode == ec_USERNAME_NOT_UNIQUE)
        {   
            //username is not unique
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"Your desired username is not unique, please try another one";
        }
        else if (errorCode == ec_USER_ALREADY_REGISTERED)
        {
            //user is already registered
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"You have already registered this email address, please login with it";
        }
        else
        {
            //unknown error
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"Something went wrong, I am not sure what. But try again please...";
        }
    }
}


+ (SignUpViewController*)createInstance
{
    SignUpViewController* vc = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
    [vc autorelease];
    return vc;
    
}
@end
