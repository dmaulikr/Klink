//
//  CameraViewController.m
//  Test Project 2
//
//  Created by Bobby Gill on 7/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIColorCategory.h"

#define kOFFSET_FOR_KEYBOARD 200.0

@interface CameraViewController() 
static UIImage* shrinkImage(UIImage *original, CGSize size);

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;

@end


@implementation CameraViewController
@synthesize imageView; 
@synthesize takePictureButton; 
@synthesize preSelection;
@synthesize postSelection;
@synthesize lbl_Note;
@synthesize lbl_Title;
@synthesize lbl_Stream;
@synthesize shouldDisplaySaveButton;
@synthesize thought;
@synthesize topic;
@synthesize state;

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
    
    //need to determine to show pre or post view
    
    //if this is a new thought, show the preview
    if (self.thought == nil) {
        self.view = preSelection;
        shouldDisplaySaveButton = NO;
        self.lbl_Title.text = [Caption getNewCaptionTitle];
        self.lbl_Title.textColor = [UIColor lightGrayColor];
        self.lbl_Stream.text=@"";
        
        self.lbl_Note.text = [Caption getNewCaptionNote];
        self.lbl_Note.textColor = [UIColor lightGrayColor];

    }
    else {
        self.view = postSelection;
        self.shouldDisplaySaveButton = NO;
        self.lbl_Stream.text = @"";
        self.lbl_Note.text = self.thought.caption1;
        self.lbl_Title.text = self.thought.title;
        
        UIImage* img = [[ImageManager getInstance] downloadImage:self.thought.imageurl withUserInfo:nil atCallback:self];
        
        if (img != nil) {
            self.imageView.image = img;
        }
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        takePictureButton.hidden = YES;
    }
    imageFrame = imageView.frame;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSaveClicked:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (!shouldDisplaySaveButton) {
        saveButton.enabled = NO;
    }
    
    if (self.topic != nil) {
        //set the title of the navigation controller
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:nil options:nil];
        
        TitleView *titleView = [arr objectAtIndex:0];        
        self.navigationItem.titleView = titleView;
        [self updateNavigationItemTitle];
        
    }
    
    [saveButton release];
    

}

- (void)updateNavigationItemTitle {
    TitleView *titleView = (TitleView*)self.navigationItem.titleView;
    if (titleView != nil) {
        titleView.titleLabel.text = self.topic.descr;
        titleView.subtitleLabel.text = [DateTimeHelper formatShortDate:self.topic.datecreated];
    }
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window]; 
}

- (void)viewDidUnload
{
    self.imageView = nil;
    self.takePictureButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [imageView release];
    [takePictureButton release]; 
    

    [super dealloc];
}



#pragma mark - action event handlers

- (IBAction)shootPictureOrVideo:(id)sender { 
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}
- (IBAction)selectExistingPictureOrVideo:(id)sender { 
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void)onBackPressed:(id)sender {
    if (self.state == kZoom) {
        [self setViewMovedUp:NO];
        [self.lbl_Note resignFirstResponder];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    if (self.state == kNorm && [lbl_Note isFirstResponder])
        {
            [self setViewMovedUp:YES];
        }
        else if ( self.state == kZoom)
        {
            [self setViewMovedUp:NO];
    }
    
}

- (IBAction)onSaveClicked:(id)sender {
    //when a photo is saved, it needs to be written to the file system
    //and then uploaded 
    WS_TransferManager* transferManager = [WS_TransferManager getInstance];
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;  
    BOOL shouldCreateThought = NO;
    BOOL shouldCreateTopic = NO;
    NSString* imagePath = nil;
    
    
    if (self.topic == nil) {
        //if there is no existing topic object and this is a new thought
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PHOTO inManagedObjectContext:appContext];
        Photo *newTopic = [[Photo alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:appContext];
        [newTopic init];
        self.topic = newTopic;
        shouldCreateTopic = YES;
        newTopic.descr = self.lbl_Title.text;
        newTopic.creatorid = [[AuthenticationManager getInstance]getLoggedInUserID];
        
        
        [newTopic release];
    }

    
    if (self.thought == nil) {
        //new thought picture
        NSEntityDescription *captionEntity = [NSEntityDescription entityForName:CAPTION inManagedObjectContext:appContext];
        Caption *newThought = [[Caption alloc]initWithEntity:captionEntity insertIntoManagedObjectContext:appContext];
        [newThought init];
        shouldCreateThought = YES;
        self.thought = newThought;
        
        NSString* newPhotoFileName = [self.thought.objectid stringValue];
        ImageManager* imageManager = [ImageManager getInstance];
        imagePath = [imageManager saveImage:self.imageView.image withFileName:newPhotoFileName];
        self.thought.thumbnailurl = imagePath;
        self.thought.imageurl = imagePath;                
        self.thought.photoid = self.topic.objectid;
        self.thought.creatorid = [[AuthenticationManager getInstance] getLoggedInUserID];
    }
    
    self.thought.caption1 = self.lbl_Note.text;
    self.thought.title = self.lbl_Title.text;
    
    [self.thought commitChangesToDatabase:NO withPendingFlag:YES];
    [self.topic commitChangesToDatabase:NO withPendingFlag:YES];

    if (shouldCreateThought && shouldCreateTopic) {
        //need to create both a new topic and new thought
        NSArray* objectids = [NSArray arrayWithObjects:self.topic.objectid,self.thought.objectid, nil];
        NSArray* objecttypes = [NSArray arrayWithObjects:self.topic.objecttype,self.thought.objecttype, nil];
        Attachment* attachment = [Attachment attachmentWith:self.topic.objectid objectType:self.topic.objecttype forAttribute:an_IMAGEURL atFileLocation:imagePath];
        NSArray* attachments = [NSArray arrayWithObject:attachment];
        [transferManager createObjectsInCloud:objectids withObjectTypes:objecttypes withAttachments:attachments];

    }
    else if (shouldCreateThought) {

        [transferManager createObjectInCloud:self.thought.objectid withObjectType:self.thought.objecttype withAttachmentFor:an_IMAGEURL atFileLocation:imagePath];
      
    }
    else {
        [transferManager updateObjectInCloud:self.thought.objectid withObjectType:self.thought.objecttype];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onCancelClicked:(id)sender {
    
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
        self.state = kZoom;
        [self showCancelButton];
        
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        self.state = kNorm;
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


#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *shrunkedImage = shrinkImage(chosenImage, imageFrame.size);
       
        [picker dismissModalViewControllerAnimated:YES];
    
        self.view = postSelection;
    
        self.imageView.image = shrunkedImage;
        self.shouldDisplaySaveButton = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker  {
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark -
static UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale; 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale, size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,CGRectMake(0, 0, size.width * scale, size.height * scale),
                       original.CGImage);
    
    CGImageRef shrunken = CGBitmapContextCreateImage(context); UIImage *final = [UIImage imageWithCGImage:shrunken];
    CGContextRelease(context); CGImageRelease(shrunken);
    return final;
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) { 
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType]; 
        UIImagePickerController *picker = [[UIImagePickerController alloc] init]; 
        picker.mediaTypes = mediaTypes;
        picker.delegate = self; 
        picker.allowsEditing = YES; 
        picker.sourceType = sourceType; 
        [self presentModalViewController:picker animated:YES]; 
        [picker release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error accessing media"
                                                        message:@"Device doesn’t support that media source." delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show]; 
        [alert release];
    }
}

#pragma mark - ImageDownloadCallback handlers
- (void) onImageDownload:(UIImage *)img withUserInfo:(NSDictionary *)userInfo {
    self.imageView.image = img;
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

#pragma mark - Text View Delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (textView == self.lbl_Note) {
        NSString* defaultThought = [Caption getNewCaptionNote];
        if ([textView.text isEqualToString:defaultThought]) {
            textView.text=@"";
            textView.textColor = [UIColor normalTextColor];
        }
        self.shouldDisplaySaveButton = YES;
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (textView == self.lbl_Note) {
        if ([textView.text isEqualToString:@""]) {
            if (textView == lbl_Note) {
                textView.text = [Caption getNewCaptionNote];
                textView.textColor = [UIColor placeHolderColor];
                
            }
            
            
        }
        else {
            NSString* defaultNote = [Caption getNewCaptionNote];
            if (![textView.text isEqualToString:defaultNote]) {
                self.shouldDisplaySaveButton = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        }
    }
}

#pragma mark - Text Field Management
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.lbl_Title) {
        NSString* defaultNoteTitle = [Caption getNewCaptionTitle];
        if ([textField.text isEqualToString:defaultNoteTitle]) {
            textField.text=@"";
            textField.textColor = [UIColor normalTextColor];
        }
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.lbl_Title) {
        NSString* defaultNoteTitle = [Caption getNewCaptionTitle];
        if (![textField.text isEqualToString:defaultNoteTitle]) {
            self.shouldDisplaySaveButton = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        
    }
}
@end
