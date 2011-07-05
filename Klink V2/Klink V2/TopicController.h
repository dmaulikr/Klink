//
//  TopicController.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/23/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "NoteViewCell.h"
#import "Caption.h"
#import "NoteController.h"
#import "TitleView.h"
#import "PhotoNoteCell.h"
#import "ImageDownloadProtocol.h"
@interface TopicController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, ImageDownloadCallback, UITextFieldDelegate> {
    Photo* topic;
    UITableView *tbl_thought;
    UITextField *lbl_topicTitle;
    
    
    UIToolbar* bottom_toolbar;
    UIBarButtonItem *btn_Picture;
    UIBarButtonItem *btn_Refresh;
}

@property (nonatomic,retain) Photo* topic;
@property (nonatomic,retain) IBOutlet UITableView* tbl_thought;
@property (nonatomic,retain) IBOutlet UITextField* lbl_topicTitle;
@property (nonatomic,retain) IBOutlet UIToolbar* bottom_toolbar;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btn_Picture;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btn_Refresh;

-(IBAction)textFieldReturn:(id)sender;
-(IBAction)backgroundTouched:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTopic:(Photo*)topic;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)onThoughtClick:(Caption*)thought;
- (void)updateNavigationItemTitle;
@end
