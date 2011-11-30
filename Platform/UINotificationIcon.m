//
//  UINotificationIcon.m
//  Platform
//
//  Created by Bobby Gill on 11/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UINotificationIcon.h"
#import "PlatformAppDelegate.h"
#import "PersonalLogViewController.h"
#import "AuthenticationManager.h"
#import "Types.h"
#import "Attributes.h"
#import "Macros.h"

@implementation UINotificationIcon
@synthesize lbl_numberOfNotifications   = m_lbl_numberOfNotifications;
@synthesize btn_showNotifications       = m_btn_showNotifications;
@synthesize navigationViewController    = m_navigationViewController;
@synthesize frc_notifications           = __frc_notifications;

#pragma mark - Properties
- (NSFetchedResultsController*)frc_notifications {
    NSString* activityName = @"UINotificationIcon.frc_notifications:";
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    if ([authenticationManager isUserAuthenticated]) {
        if (__frc_notifications != nil) {
            return __frc_notifications;
        }
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:FEED inManagedObjectContext:resourceContext.managedObjectContext];
        
        
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
        
        //add predicate to only query for notification items that have not been seen
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@",HASSEEN, [NSNumber numberWithBool:NO]];
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [fetchRequest setEntity:entityDescription];
        
        
        NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        controller.delegate = self;
        self.frc_notifications = controller;
        
        
        NSError* error = nil;
        [controller performFetch:&error];
        if (error != nil)
        {
            LOG_NOTIFICATIONICON(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
        }
        
        [controller release];
        [fetchRequest release];
        
        return __frc_notifications;
    }
    else {
        //no user authenticated, we nil out the frc
        LOG_NOTIFICATIONICON(0, @"%@No user logged in, returning nil fetched results controller",activityName);
        __frc_notifications = nil;
        return __frc_notifications;
    }
        
}
#pragma mark - Instance Methods
- (void) render {
    //we update the notification label with the correct number
    int unseenNotificationCount = [[self.frc_notifications fetchedObjects]count];
    self.lbl_numberOfNotifications.text = [NSString stringWithFormat:@"%d",unseenNotificationCount];
    
  
}
#pragma mark - Frames
- (CGRect) frameForShowNotificationButton {
    return CGRectMake(33, 0, 39, 37);
}

- (CGRect) frameForNumberOfNotificationsLabel {
    return CGRectMake(0, 0, 42, 37);
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect frameForButton = [self frameForShowNotificationButton];
        CGRect frameForLabel = [self frameForNumberOfNotificationsLabel];
        
        self.btn_showNotifications = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btn_showNotifications.frame = frameForButton;
        [self.btn_showNotifications setTitle:@"!" forState:UIControlStateNormal];
        self.btn_showNotifications.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.btn_showNotifications addTarget:self action:@selector(onShowNotificationsClick:) forControlEvents:UIControlEventTouchUpInside];
        self.btn_showNotifications.backgroundColor = [UIColor clearColor];
        
        self.lbl_numberOfNotifications = [[UILabel alloc]initWithFrame:frameForLabel];
        self.lbl_numberOfNotifications.textAlignment = UITextAlignmentCenter;
        self.lbl_numberOfNotifications.textColor = [UIColor whiteColor];
        self.lbl_numberOfNotifications.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        
        
        [self addSubview:self.lbl_numberOfNotifications];
        [self addSubview:self.btn_showNotifications];
        [self render];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [self.frc_notifications release];
    [self.lbl_numberOfNotifications release];
    [self.btn_showNotifications release];
    [super dealloc];

}

#pragma mark - NSFetchedResultsControllerDelegate
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    //everytime a change is detected to the number of notifications in the system,
    [self render];
}

#pragma mark - Event Handlers
- (void) onShowNotificationsClick:(id)sender {
    //when the notifications button is clicked we need to move to the profile view controller
    PersonalLogViewController* personalLogViewController = [PersonalLogViewController createInstance];
    [self.navigationViewController pushViewController:personalLogViewController animated:YES];
}



#pragma mark - Static Initializers
+ (UINotificationIcon*)notificationIconForPageViewControllerToolbar {
    PlatformAppDelegate* appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    CGRect frameForNotificationIcon = CGRectMake(0, 0, 72, 37);
    UINotificationIcon* notificationIcon = [[[UINotificationIcon alloc]initWithFrame:frameForNotificationIcon]autorelease];
    notificationIcon.navigationViewController = appDelegate.navigationController;
    return notificationIcon;
}
@end
