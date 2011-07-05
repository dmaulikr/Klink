//
//  RootViewController.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILoggableActivity.h"
#import <CoreData/CoreData.h>
#import "IStateBasedViewController.h"
#import "UserStatistics.h"
#import "ApplicationSettings.h"
#import "NoteController.h"
#import "TopicController.h"
#import "NSStringGUIDCategory.h"

@class CustomCell;
@interface RootViewController : UIViewController <NSFetchedResultsControllerDelegate, ILoggableActivity, IStateBasedViewController> {

    UIActivityIndicatorView  *activityIndicator;
    UILabel *lb_newCaptions;
    UILabel *lb_newViews;
    
    UITableView *tv_tableView;
}

@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UILabel *lb_newCaptions;
@property (nonatomic,retain) IBOutlet UILabel *lb_newViews;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void) onWebServiceResponseReceived:(NSNotification*)notification;
- (id) init;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; 
- (void)onExistingTopicClick:(Photo*)topic;
- (void)onAddNewClick :(id)sender; 

-(void)startBusyIndicator;
-(void)stopBusyIndicator;
@end
