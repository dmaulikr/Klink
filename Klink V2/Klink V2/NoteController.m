//
//  NoteController.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/21/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NoteController.h"



@implementation NoteController
@synthesize tv_Input;
@synthesize noteTitle;
@synthesize noteStream;
@synthesize topic;
@synthesize thought;
@synthesize landscape;
@synthesize portrait;
@synthesize noteTopic_Landscape;
@synthesize state;
@synthesize toolbar;


NSString* const default_NOTETOPIC = @"Enter blazestorm name";
NSString* const default_NOTESTREAM = @"Give it a stream";
NSString* const default_INPUT = @"Give me your thoughts";

#define kOFFSET_FOR_KEYBOARD 60.0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopic:(Photo*)existingTopic withThought:(Caption*)existingThought
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.thought = existingThought;
        self.topic = existingTopic;
       
        
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(onNoteSave:)];
    
        
    
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    [noteTitle setBackgroundColor:[UIColor clearColor]];
    [noteStream setBackgroundColor:[UIColor clearColor]];
    [tv_Input.layer setBackgroundColor: [[UIColor whiteColor]CGColor]];
    [tv_Input.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [tv_Input.layer setBorderWidth: 1.0];
    [tv_Input.layer setCornerRadius:5.0];
    [tv_Input.layer setMasksToBounds:YES];
    
    
    self.tv_Input.delegate = self;
    self.noteStream.delegate = self;
    self.noteTitle.delegate = self;
    
 
    if (self.thought == nil) {
        self.noteTitle.text = [Caption getNewCaptionTitle];
        self.noteTitle.textColor = [UIColor lightGrayColor];
        self.noteStream.text=@"";
        
        self.tv_Input.textColor = [UIColor lightGrayColor];
        self.tv_Input.text = default_INPUT;
        
        self.noteTopic_Landscape.textColor =[UIColor lightGrayColor];
        self.noteTopic_Landscape.text = default_INPUT;
        
    }
    else {       
        self.noteTitle.text = self.thought.title;
        self.tv_Input.text = self.thought.caption1;
        self.noteStream.text = [DateTimeHelper formatShortDate:self.thought.datecreated];
        self.noteTopic_Landscape.text = self.thought.caption1 ;
    }
    
    if (self.topic != nil) {
        //set the title of the navigation controller
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:nil options:nil];
        
        TitleView *titleView = [arr objectAtIndex:0];        
        self.navigationItem.titleView = titleView;
        [self updateNavigationItemTitle];

    }
    
  
}

- (void)updateNavigationItemTitle {
    TitleView *titleView = (TitleView*)self.navigationItem.titleView;
    if (titleView != nil) {
        titleView.titleLabel.text = self.topic.descr;
        titleView.subtitleLabel.text = [DateTimeHelper formatShortDate:self.topic.datecreated];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 

    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        self.view = self.landscape;
    }
    else {
        self.view = self.portrait;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
}



#pragma mark - Action Management



-(IBAction)onThoughtTitleChanged:(id)sender {
    UITextField* textField = (UITextField*)sender;
    if (self.thought != nil) {
        if (![self.thought.title isEqualToString:textField.text]) {
            self.thought.title = textField.text;
            [self.thought commitChangesToDatabase:YES withPendingFlag:YES];
        }
    }
}

- (void)onNoteSave:(id)sender {
//    NSString* activityName = @"NoteController.onNoteSave:";
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    BOOL shouldCreateTopic = NO;
    BOOL shouldCreateThought = NO;
                    
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;            
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:appContext];
    
    if (self.topic == nil) {
        //if there is no existing topic object and this is a new thought
        Photo *newTopic = [[Photo alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:appContext];
        [newTopic init];
        shouldCreateTopic = YES;
        newTopic.descr = self.noteTitle.text;
        newTopic.creatorid = [[AuthenticationManager getInstance]getLoggedInUserID];
        self.topic = newTopic;
        [newTopic release];
    }
    
    if (self.thought == nil) {
        NSEntityDescription *captionEntity = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:appContext];
        
        Caption *newThought = [[Caption alloc]initWithEntity:captionEntity insertIntoManagedObjectContext:appContext];    
        [newThought init];
        shouldCreateThought = YES;
        self.thought = newThought;
        self.thought.photoid = self.topic.objectid;
        self.thought.creatorid = [[AuthenticationManager getInstance] getLoggedInUserID];
        
        self.thought.title = self.noteTitle.text;
        
        [newThought release];
    }

    if (self.view == portrait) {
        self.thought.caption1 = self.tv_Input.text;
    }
    else {
        self.thought.caption1 = self.noteTopic_Landscape.text;
    }
    
    [self.thought commitChangesToDatabase:NO withPendingFlag:YES];
    [self.topic commitChangesToDatabase:NO withPendingFlag:YES];
    
    if (shouldCreateTopic && shouldCreateThought) {
        //need to create both a new topic and new thought
        NSArray* objectids = [NSArray arrayWithObjects:self.topic.objectid,self.thought.objectid, nil];
        NSArray* objecttypes = [NSArray arrayWithObjects:self.topic.objecttype,self.thought.objecttype, nil];
        
        [transferManager createObjectsInCloud:objectids withObjectTypes:objecttypes withAttachments:nil];
    }
    else if (shouldCreateThought) {
        //topic already exists, adding a new thought
        NSArray* objectids = [NSArray arrayWithObject:self.thought.objectid];
        NSArray* objecttypes = [NSArray arrayWithObject:self.thought.objecttype];
        [transferManager createObjectsInCloud:objectids withObjectTypes:objecttypes withAttachments:nil];
        
    }
    else {
        //topic and thought exists, updating the thought        
        [transferManager updateObjectInCloud:self.thought.objectid withObjectType:self.thought.objecttype];
    }
    
  
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)onBackPressed:(id)sender {
    if (self.state == kZoomedIn) {
        [self setViewMovedUp:NO];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Text Field Management
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.noteTitle) {
        NSString* defaultNoteTitle = [Caption getNewCaptionTitle];
        if ([textField.text isEqualToString:defaultNoteTitle]) {
            textField.text=@"";
            textField.textColor = [UIColor normalTextColor];
        }
        
        //disable the save button
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.noteTitle) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Text View Management
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
if (textView == self.tv_Input || textView == self.noteTopic_Landscape) {
        if ([textView.text isEqualToString:default_INPUT]) {
            textView.text=@"";
            textView.textColor = [UIColor normalTextColor];
        }
    }

}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        self.state = kZoomedIn;
        [self showCancelButton];
        
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        self.state = kNormal;
        [self showBackButton];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void) showBackButton {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void) showCancelButton {
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemCancel target:self action:@selector(onBackPressed:)];
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    if (self.view == portrait) {
        if (self.state == kNormal && [tv_Input isFirstResponder])
        {
            [self setViewMovedUp:YES];
        }
        else if ( self.state == kZoomedIn)
        {
            [self setViewMovedUp:NO];
        }
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        if (textView == noteTitle) {
            textView.text = [Caption getNewCaptionTitle];
          
            
        }

        else if (textView == self.tv_Input || textView == self.noteTopic_Landscape) {
            textView.text = default_INPUT;
            
        }
        textView.textColor = [UIColor placeHolderColor];
        
        
    }
}

#pragma mark - memory management functions
- (void)dealloc
{
    [landscape release];
    [portrait release];
    [noteTopic_Landscape release];
    [noteTitle release];
    [noteStream release];
    [tv_Input release];
    [thought release];
     [topic release]; 

    [super dealloc];
}

- (void)viewDidUnload
{
    self.landscape = nil;
    self.portrait = nil;
    self.noteTopic_Landscape = nil;
    self.noteTitle = nil;
    self.noteStream = nil;
    self.tv_Input = nil;
    self.thought = nil;
    self.topic = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - rotation handlers

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view = portrait;
//        self.view.transform = CGAffineTransformIdentity;
//        self.view.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
        self.view.bounds = CGRectMake(0.0,0.0,320,460);
        self.tv_Input.text = self.noteTopic_Landscape.text;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.view = landscape;
//        self.view.transform = CGAffineTransformIdentity;
//        self.view.transform = CGAffineTransformMakeRotation(degreesToRadians(-90));
        self.view.bounds = CGRectMake(0.0,0.0,480,300);
        self.noteTopic_Landscape.text = self.tv_Input.text;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.view = portrait;
//        self.view.transform = CGAffineTransformIdentity;
//        self.view.transform = CGAffineTransformMakeRotation(degreesToRadians(180));
        self.view.bounds = CGRectMake(0.0,0.0,320,460);
        self.tv_Input.text = self.noteTopic_Landscape.text;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view = landscape;
//        self.view.transform = CGAffineTransformIdentity;
//        self.view.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
        self.view.bounds = CGRectMake(0.0,0.0,480,300);
        self.noteTopic_Landscape.text = self.tv_Input.text;
    }
    
}


@end
