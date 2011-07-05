//
//  CameraViewController.h
//  Test Project 2
//
//  Created by Bobby Gill on 7/1/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Caption.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ImageDownloadProtocol.h"
#import "TitleView.h"



typedef enum {
    kNorm,
    kZoom
} CameraControllerViewState;

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, 
UINavigationControllerDelegate, 
ImageDownloadCallback,
UITextViewDelegate, 
UITextFieldDelegate> 
{
    UIImageView *imageView; 
    UITextField *lbl_Title;
    UITextView *lbl_Note;
    UITextView *lbl_Stream;    
    CGRect imageFrame;    
    UIButton *takePictureButton;     
    UIView* preSelection;
    UIView* postSelection;
    Caption* thought;
    Photo* topic;
    
    BOOL shouldDisplaySaveButton;
    //state management
    CameraControllerViewState state;
}
@property BOOL shouldDisplaySaveButton;
@property (nonatomic, retain) IBOutlet UITextField *lbl_Title;
@property (nonatomic, retain) IBOutlet UITextView *lbl_Note;
@property (nonatomic, retain) IBOutlet UITextView *lbl_Stream;
@property (nonatomic, retain) IBOutlet UIView *preSelection;
@property (nonatomic, retain) IBOutlet UIView *postSelection;
@property (nonatomic, retain) IBOutlet UIImageView *imageView; 
@property (nonatomic, retain) IBOutlet UIButton *takePictureButton; 
@property CameraControllerViewState state;
 

@property (nonatomic, retain) Caption *thought;
@property (nonatomic, retain) Photo* topic;

- (void) showBackButton;
- (void) showCancelButton;
- (void)setViewMovedUp:(BOOL)movedUp;
- (IBAction)shootPictureOrVideo:(id)sender; 
- (IBAction)selectExistingPictureOrVideo:(id)sender;
-(IBAction)onThoughtTitleChanged:(id)sender; 
-(IBAction)onSaveClicked:(id)sender;
-(IBAction)onCancelClicked:(id)sender;
- (void)updateNavigationItemTitle;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopic:(Photo*)existingTopic withThought:(Caption*)existingThought;
@end
