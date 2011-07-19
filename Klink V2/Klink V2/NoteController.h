//
//  NoteController.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/21/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "NoteController.h"
#import "UIColorCategory.h"
#import "QuartzCore/QuartzCore.h"
#import "DataLayer.h"
#import "Caption.h"
#import "WS_TransferManager.h"
#import "TitleView.h"
#import "CameraViewController.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)

typedef enum {
    kNormal,
    kZoomedIn
} ViewState;


@interface NoteController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {
    UITextField *noteTitle;
    UITextView *noteStream;
    UITextView *tv_Input;
    
    UITextVie* tb_test;
    
    Caption* thought;
    Photo* topic;
    
    UIView *landscape;
    UIView *portrait;
    
    UITextView *noteTopic_Landscape;
    
    UIToolbar *toolbar;
        
    //state management
    ViewState state;
}
@property (nonatomic,retain) IBOutlet UITextField *noteTitle;
@property (nonatomic, retain) IBOutlet UITextView *noteStream;
@property (nonatomic, retain) IBOutlet UITextView* tv_Input;
@property (nonatomic, retain) Caption* thought;
@property (nonatomic,retain)  Photo* topic;
@property (nonatomic,retain) IBOutlet UIToolbar* toolbar;

@property (nonatomic,retain) IBOutlet UIView* portrait;
@property (nonatomic,retain) IBOutlet UIView* landscape;
@property ViewState state;
@property (nonatomic,retain) IBOutlet UITextView *noteTopic_Landscape;

-(void)setInputBoxToDefault;
-(void)setViewMovedUp:(BOOL)movedUp;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopic:(Photo*)existingTopic withThought:(Caption*)existingThought;

-(IBAction)onThoughtTitleChanged:(id)sender;

- (void) showBackButton;
- (void) showCancelButton;
- (void)updateNavigationItemTitle;
@end
