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
#import "Flurry.h"

@implementation SignUpViewController
@synthesize sv_scrollView   = m_sv_scrollView;
@synthesize tf_email        = m_tf_email;
@synthesize tf_password     = m_tf_password;
@synthesize tf_username     = m_tf_username;
@synthesize tf_password2    = m_tf_password2;
@synthesize btn_join        = m_btn_join;
@synthesize lbl_error       = m_lbl_error;
@synthesize lbl_intro       = m_lbl_intro;
@synthesize tf_displayName  = m_tf_displayName;
@synthesize tf_active       = m_tf_active;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Set background pattern
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pattern.png"]]];
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
        // Add rounded corners to custom buttons
        self.btn_join.layer.cornerRadius = 8;
        
        // Add border to custom buttons
        [self.btn_join.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [self.btn_join.layer setBorderWidth: 1.0];
        
        // Set text shadow of custom buttons
        [self.btn_join.titleLabel setShadowOffset:CGSizeMake(0.0, -1.0)];
        
        // Add mask on custom buttons
        [self.btn_join.layer setMasksToBounds:YES];
        
        // Set highlight state background color of custom buttons
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *lightGreyImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.btn_join setBackgroundImage:lightGreyImg forState:UIControlStateHighlighted];
        [self.btn_join setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
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
    
    // Make sure navigation bar is shown
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Navigation Bar properties
    self.navigationItem.title = @"New Account";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    // Navigation Bar Buttons
    UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc]
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(onCancelPressed:)] autorelease];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // Register for keyboard notifications to slide view up when typing
    [self registerForKeyboardNotifications];
    
    // Enable the gesture recognizer on the view to handle a single tap to hide the keyboard
    UITapGestureRecognizer *oneFingerTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick:)] autorelease];
    // Set required taps and number of touches
    [oneFingerTap setNumberOfTapsRequired:1];
    [oneFingerTap setNumberOfTouchesRequired:1];
    [oneFingerTap setCancelsTouchesInView:NO];
    // Add the gesture to the view
    [self.sv_scrollView addGestureRecognizer:oneFingerTap];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.sv_scrollView = nil;
    self.tf_email = nil;
    self.tf_username = nil;
    self.tf_password = nil;
    self.tf_password2 = nil;
    self.btn_join = nil;
    self.lbl_error = nil;
    self.lbl_intro = nil;
    self.tf_displayName = nil;
    
}


- (void) viewWillAppear:(BOOL)animated
{
    // Hide Login Error label
    self.lbl_error.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"VIEWING_SIGNUPVIEW" timed:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [Flurry endTimedEvent:@"VIEWING_SIGNUPVIEW" withParameters:nil];
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

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    self.tf_active = textField;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.tf_displayName &&
        self.tf_displayName.text != nil &&
        ![self.tf_displayName.text isEqualToString: @""] &&
        (self.tf_username.text == nil ||
        [self.tf_username.text isEqualToString: @""])) {
            
            NSRange range = [self.tf_displayName.text rangeOfString:@" "];
            
            NSString *usernameTEMP;
            
            if (range.length > 0 && range.location > 0) {
                usernameTEMP = [NSString stringWithString:[self.tf_displayName.text substringToIndex:(range.location + 2)]];
            }
            else {
                usernameTEMP = [self.tf_displayName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            
            // Trim any and all remaining white space
            usernameTEMP = [usernameTEMP stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            self.tf_username.text = usernameTEMP;
    }
}

#pragma mark - Keyboard Handlers
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.sv_scrollView.contentInset = contentInsets;
    self.sv_scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    //if (!CGRectContainsPoint(aRect, self.tf_active.frame.origin)) {
    //CGPoint scrollPoint = CGPointMake(0.0, self.tf_active.frame.origin.y+(self.tf_active.frame.size.height*1.5)-kbSize.height);
    CGPoint scrollPoint = CGPointMake(0.0, self.tf_active.frame.origin.y-(self.tf_active.frame.size.height*1.5));
    [self.sv_scrollView setContentOffset:scrollPoint animated:YES];
    //}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView beginAnimations:@"keyboardWillBeHiddenAnimation" context:nil];
    [UIView setAnimationDuration:0.35];
    
    self.sv_scrollView.contentInset = contentInsets;
    self.sv_scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

// Handles keyboard Return button pressed while editing a textfield to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [textField resignFirstResponder];
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

// Used to prevent spaces and more than one hashtag in the draft title string
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {    
    
    if (textField == self.tf_password || textField == self.tf_password2) {
        if ([text isEqualToString:@" "]) {
            // no spaces allowed
            self.lbl_intro.hidden = YES;
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"Sorry, you cannot have blank spaces in your password.";
            return NO;
        }
    }
    else if (textField == self.tf_email) {
        if ([text isEqualToString:@" "]) {
            // no spaces allowed
            self.lbl_intro.hidden = YES;
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"Sorry, you cannot have blank spaces in your email.";
            return NO;
        }
    }
    
    self.lbl_error.hidden = YES;
    self.lbl_intro.hidden = NO;
    
    return YES;
}

// Hides Keyboard when user touches screen outside of editable text view or field
- (IBAction)backgroundClick:(id)sender
{
    [self.tf_active resignFirstResponder];
}


#pragma mark - IBAction handlers

- (IBAction) onJoinPressed:(id)sender
{
    //called when the user presses the join button
    NSString* password = self.tf_password.text;
    NSString* password2 = self.tf_password2.text;
    NSString* email = self.tf_email.text;
    NSString* displayName = self.tf_displayName.text;
    NSString* username = self.tf_username.text;
    
    if (![password isEqualToString:password2]) {
        // passwords do not match
        self.lbl_intro.hidden = YES;
        self.lbl_error.hidden = NO;
        self.lbl_error.text = @"Your passwords do not match, please try again.";
    }
    else if (email == nil ||
             [email isEqualToString: @""] ||
             password == nil ||
             [password isEqualToString: @""] ||
             password2 == nil ||
             [password2 isEqualToString: @""] ||
             displayName == nil ||
             [displayName isEqualToString: @""])
    {
        // passwords do not match
        self.lbl_intro.hidden = YES;
        self.lbl_error.hidden = NO;
        self.lbl_error.text = @"All fields are required.";
    }
    else {
        self.lbl_error.hidden = YES;
        self.lbl_intro.hidden = NO;
        
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
        
        
        [self showDeterminateProgressBarWithMaximumDisplayTime:settings.progress_maxsecondstodisplay onSuccessMessage:@"Welcome, get ready to Bahndr!" onFailureMessage:@"Let's try this again..."  inProgressMessages:[NSArray arrayWithObject:@"Creating account..."]];
    }
    
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
            self.lbl_intro.hidden = YES;
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"Sorry, your desired username is taken, please try another one.";
        }
        else if (errorCode == ec_USER_ALREADY_REGISTERED)
        {
            //user is already registered
            self.lbl_intro.hidden = YES;
            self.lbl_error.hidden = NO;
            self.lbl_error.text = @"You have already registered this email address, please login with it.";
        }
        else
        {
            //unknown error
            self.lbl_intro.hidden = YES;
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
