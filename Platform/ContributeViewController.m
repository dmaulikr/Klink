//
//  ContributeViewController.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ContributeViewController.h"


@implementation ContributeViewController
@synthesize scrollView = m_scrollview;
@synthesize activeTextView = m_activeTextView;
@synthesize activeTextField = m_activeTextField;

@synthesize lbl_draftTitle = m_lbl_draftTitle;
@synthesize tf_newDraftTitle = m_tf_newDraftTitle;
@synthesize lbl_titleRequired = m_lbl_titleRequired;

@synthesize iv_photo = m_iv_photo;
@synthesize img_photo = m_img_photo;
@synthesize lbl_photoOptional = m_lbl_photoOptional;

@synthesize tv_caption = m_tv_caption;
@synthesize lbl_captionOptional = m_lbl_captionOptional;

@synthesize lbl_deadline = m_lbl_deadline;



#pragma mark - Initializers
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    
    [self registerForKeyboardNotifications];
    
    // Keeps the text of the caption textview aligned to the vertical center of the textview frame
    [self.tv_caption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
     
    self.iv_photo.image = self.img_photo;

    //[self.view setNeedsDisplay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // show toolbar
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextview and TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.activeTextView = textView;
    
    // Clear the default text of a texview upon editing
    [self.activeTextView setText:@""];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeTextView = nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

// Handles keyboard Return button pressed while editing a textview to dismiss the keyboard
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

// Handles keyboard Return button pressed while editing a textfield to dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

// Keeps the text of the caption textview aligned to the vertical center of the textview frame
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView* textview = object;
    //Center vertical alignment
    CGFloat topCorrect = ([textview bounds].size.height - [textview contentSize].height * [textview zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    textview.contentInset = UIEdgeInsetsMake(topCorrect, 0, 0, 0);
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
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeTextView.frame.origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeTextView.frame.origin.y+(self.activeTextView.frame.size.height*1.25)-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    [UIView beginAnimations:@"keyboardWillBeHiddenAnimation" context:nil];
    [UIView setAnimationDuration:0.35];
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

// Hides Keyboard when user touches screen outside of editable text view or field
- (IBAction)backgroundClick:(id)sender
{
    [self.activeTextView resignFirstResponder];
    [self.activeTextField resignFirstResponder];
}

#pragma mark - Static Initializers
+ (ContributeViewController*) createInstance {
    ContributeViewController* contributeViewController = [[ContributeViewController alloc]initWithNibName:@"ContributeViewController" bundle:nil];
    [contributeViewController autorelease];
    return contributeViewController;
}

@end
