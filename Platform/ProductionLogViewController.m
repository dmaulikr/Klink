//
//  ProductionLogViewController2.m
//  Platform
//
//  Created by Jordan Gurrieri on 11/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ProductionLogViewController.h"
#import "UIProductionLogTableViewCell.h"
#import "Macros.h"
#import "Page.h"
#import "Photo.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DraftViewController.h"
#import "ContributeViewController.h"
#import "CloudEnumeratorFactory.h"
#import "DateTimeHelper.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "ProfileViewController.h"
#import "PageState.h"
#import "PlatformAppDelegate.h"
#import "UserDefaultSettings.h"
#import "UIStrings.h"
#import "BookViewControllerBase.h"
#import "NotificationsViewController.h"
#import "DateTimeHelper.h"
#import "LoginViewController.h"
#import "UITutorialView.h"
#import "FlurryAnalytics.h"

#define kPHOTOID @"photoid"
#define kCELLID @"cellid"
#define kCELLTITLE @"celltitle"
#define kPRODUTIONLOGTABLEVIEWCELLHEIGHT 73

@implementation ProductionLogViewController
@synthesize tbl_productionTableView     = m_tbl_productionTableView;
@synthesize frc_draft_pages             = __frc_draft_pages;
@synthesize productionTableViewCell     = m_productionTableViewCell;
@synthesize lbl_title                   = m_lbl_title;
@synthesize cloudDraftEnumerator        = m_cloudDraftEnumerator;
@synthesize refreshHeader               = m_refreshHeader;
@synthesize selectedDraftID             = m_selectedDraftID;
@synthesize v_typewriter                = m_v_typewriter;
@synthesize btn_profileButton           = m_btn_profileButton;
@synthesize btn_newPageButton           = m_btn_newPageButton;
@synthesize btn_notificationsButton     = m_btn_notificationsButton;
@synthesize btn_notificationBadge       = m_btn_notificationBadge;
@synthesize shouldOpenTypewriter        = m_shouldOpenTypewriter;
@synthesize shouldCloseTypewriter       = m_shouldCloseTypewriter;
@synthesize btn_homeButton              = m_btn_homeButton;
@synthesize iv_bookBackground           = m_iv_bookBackground;
@synthesize iv_bookCover                = m_iv_bookCover;
@synthesize shouldOpenBookCover         = m_shouldOpenBookCover;
@synthesize photos                      = m_photos;
@synthesize captions                    = m_captions;


//this NSFetchedResultsController will query for all draft pages
- (NSFetchedResultsController*) frc_draft_pages {
    NSString* activityName = @"ProductionLogViewController.frc_draft_pages:";
    if (__frc_draft_pages != nil) {
        return __frc_draft_pages;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    PlatformAppDelegate* app = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PAGE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATEDRAFTEXPIRES   ascending:YES];
    
    double doubleDateNow = [[NSDate date] timeIntervalSince1970];
    
    //add predicate to test for being published
    NSString* stateAttributeNameStringValue = [NSString stringWithFormat:@"%@",STATE];
    NSString* dateExpireAttributeNameStringValue = [NSString stringWithFormat:@"%@",DATEDRAFTEXPIRES];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%d AND %K >= %f",stateAttributeNameStringValue, kDRAFT, dateExpireAttributeNameStringValue,doubleDateNow];
    
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_draft_pages = controller;
    
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_PRODUCTIONLOGVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@",activityName,[error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_draft_pages;
    
}

- (void) registerCallbackHandlers {
    // resister callbacks for change events
    Callback* newDraftCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewDraft:)];
    Callback* newPhotoCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhoto:)];
    Callback* newCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaption:)];
    Callback* newPhotoVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewPhotoVote:)];
    Callback* newCaptionVoteCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNewCaptionVote:)];
    Callback* unreadCaptionCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUnreadCaptionUpdate:)];
    
    //we set each callback to call on the mainthread
    newDraftCallback.fireOnMainThread = YES;
    newPhotoCallback.fireOnMainThread = YES;
    newCaptionCallback.fireOnMainThread = YES;
    newPhotoCallback.fireOnMainThread = YES;
    newCaptionCallback.fireOnMainThread = YES;
    newCaptionVoteCallback.fireOnMainThread = YES;
    unreadCaptionCallback.fireOnMainThread = YES;
    
    [self.eventManager registerCallback:newDraftCallback forSystemEvent:kNEWPAGE];
    [self.eventManager registerCallback:newPhotoCallback forSystemEvent:kNEWPHOTO];
    [self.eventManager registerCallback:newCaptionCallback forSystemEvent:kNEWCAPTION];
    [self.eventManager registerCallback:newPhotoVoteCallback forSystemEvent:kNEWPHOTOVOTE];
    [self.eventManager registerCallback:newCaptionVoteCallback forSystemEvent:kNEWCAPTIONVOTE];
    [self.eventManager registerCallback:unreadCaptionCallback forSystemEvent:kCAPTIONREAD];
    
    [newDraftCallback release];
    [newPhotoCallback release];
    [newCaptionCallback release];
    [newPhotoVoteCallback release];
    [newCaptionVoteCallback release];
    [unreadCaptionCallback release];
    
}

#pragma mark - UIView Animations
- (void)animationDidStart:(CAAnimation *)theAnimation {
    if (theAnimation == [self.iv_bookCover.layer animationForKey:@"flipBookCoverOpen"]) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        [self.iv_bookBackground setAlpha:0];
        
        [UIView commitAnimations];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
    // Get the tag from the animation, we use it to find the
    // animated UIView
    //    NSString *animationKeyClosed = [NSString stringWithFormat:@"flipTypewriterClosed"];
    
    if (flag) {
        if (theAnimation == [self.v_typewriter.layer animationForKey:@"flipTypewriterClosed"] || theAnimation == [self.v_typewriter.layer animationForKey:@"flipTypewriterOpen"]) {
            for (NSString* animationKey in self.v_typewriter.layer.animationKeys) {
                if ([animationKey isEqualToString:@"flipTypewriterClosed"]) {
                    // typewriter was closed
                    
                    //self.view.userInteractionEnabled = YES;
                    self.v_typewriter.userInteractionEnabled = YES;
                    
                }
                else {
                    // typewriter was opened, move to draft view
                    
                    //[self pageHideView:self.view duration:0.5];
                    
                    // Open Draft View
                    DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:self.selectedDraftID];
                    
                    [self.navigationController pushViewController:draftViewController animated:YES];
                    
                    //[self.navigationController presentModalViewController:draftViewController animated:YES];
                    
                    // Now we just hide the animated view since
                    // animation.removedOnCompletion is not working
                    // in animation groups. Hiding the view prevents it
                    // from returning to the original state and showing.
                    //self.iv_bookCover.hidden = YES;
                    //[self.view sendSubviewToBack:self.iv_bookCover];
                }
            }
        }
        else if (theAnimation == [self.iv_bookCover.layer animationForKey:@"flipBookCoverClosed"] || theAnimation == [self.iv_bookCover.layer animationForKey:@"flipBookCoverOpen"]) {
            for (NSString* animationKey in self.iv_bookCover.layer.animationKeys) {
                if ([animationKey isEqualToString:@"flipBookCoverOpen"]) {
                    // book was opened, hide the cover
                    [self.view sendSubviewToBack:self.iv_bookBackground];
                    [self.view sendSubviewToBack:self.iv_bookCover];
                    
                    // close the typewriter onto the page
                    [self closeTypewriter];
                }
                else {
                    // book closed
                    
                }
            }
        }
    }
    
    //    if (flag) {
    //        for (NSString* animationKey in self.v_typewriter.layer.animationKeys) {
    //            if ([animationKey isEqualToString:@"flipTypewriterClosed"]) {
    //                // typewriter was closed
    //                
    //                //self.view.userInteractionEnabled = YES;
    //                self.v_typewriter.userInteractionEnabled = YES;
    //                
    //            }
    //            else {
    //                // typewriter was opened, move to draft view
    //                
    //                //[self pageHideView:self.view duration:0.5];
    //                
    //                // Open Draft View
    //                DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:self.selectedDraftID];
    //                
    //                [self.navigationController pushViewController:draftViewController animated:YES];
    //                
    //                //[self.navigationController presentModalViewController:draftViewController animated:YES];
    //                
    //                // Now we just hide the animated view since
    //                // animation.removedOnCompletion is not working
    //                // in animation groups. Hiding the view prevents it
    //                // from returning to the original state and showing.
    //                //self.iv_bookCover.hidden = YES;
    //                //[self.view sendSubviewToBack:self.iv_bookCover];
    //            }
    //        }
    //    }
    
    /*// Get the tag from the animation, we use it to find the
     // animated UIView
     NSNumber *tag = [theAnimation valueForKey:@"viewToOpenTag"];
     // Find the UIView with the tag and do what you want
     // This only searches the first level subviews
     for (UIView *subview in self.view.subviews) {
     if (subview.tag == [tag intValue]) {
     // Code for what's needed to happen after
     // the animation finishes goes here.
     if (flag) {
     // Now we just hide the animated view since
     // animation.removedOnCompletion is not working
     // in animation groups. Hiding the view prevents it
     // from returning to the original state and showing.
     subview.hidden = YES;
     }
     }
     }*/
    
}

#pragma mark Typewriter Animations
- (void) typewriterOpenView:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToOpen.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToOpen.hidden = NO;
    //[self.view bringSubviewToFront:viewToOpen];
    
    // disable the view so it’s not doing anything while animating
    viewToOpen.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the bottom edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToOpen.layer.anchorPoint.y != 1.0f) {
        //viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToOpen.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        //viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
        viewToOpen.center = CGPointMake(viewToOpen.center.x, viewToOpen.center.y + viewToOpen.bounds.size.height/2.0f);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // start the animation from the current state
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                           -1.0f,
                                                           0.0f,
                                                           0.0f);
    // these values control the 3D projection outlook
    endTransform.m34 = 0.001f;
    endTransform.m24 = 0.005f;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:endTransform];
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToOpen.tag] forKey:@"viewToOpenTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipTypewriterOpen"];
}

- (void) typewriterCloseView:(UIView *)viewToClose duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToClose.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToClose.hidden = NO;
    //[self.view bringSubviewToFront:viewToClose];
    
    // disable the view so it’s not doing anything while animating
    viewToClose.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the bottom edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToClose.layer.anchorPoint.y != 1.0f) {
        //viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToClose.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
        //viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
        viewToClose.center = CGPointMake(viewToClose.center.x, viewToClose.center.y + viewToClose.bounds.size.height/2.0f);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // start the animation from the open state
    // this is the basic rotation by 90 degree along the x-axis
    CATransform3D startTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                             -1.0f,
                                                             0.0f,
                                                             0.0f);
    // these values control the 3D projection outlook
    //startTransform.m34 = 0.001f;
    //startTransform.m14 = -0.0015f;
    startTransform.m34 = 0.001f;
    startTransform.m24 = 0.005f;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:startTransform];
    
    // end the transformation at the default state
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToClose.tag] forKey:@"viewToCloseTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToClose.layer addAnimation:theGroup forKey:@"flipTypewriterClosed"];
}

- (void)openTypewriter {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = NO;
    
    [self typewriterOpenView:self.v_typewriter duration:0.5f];
}

- (void)closeTypewriter {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = YES;
    
    [self typewriterCloseView:self.v_typewriter duration:0.5f];
}

- (void) pageShowView:(UIView *)viewToShow duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToShow.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToShow.hidden = NO;
    
    // disable the view so it’s not doing anything while animating
    viewToShow.userInteractionEnabled = NO;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -230); //place the view just off screen, bottom right
    //viewToShow.transform = transform;
    
    [UIView animateWithDuration:duration  
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         viewToShow.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         if (self.shouldCloseTypewriter) {
                             [self closeTypewriter];
                         }
                     }
     ];
}

- (void) pageHideView:(UIView *)viewToShow duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToShow.layer removeAllAnimations];
    
    // Make sure view is visible
    viewToShow.hidden = NO;
    
    // disable the view so it’s not doing anything while animating
    viewToShow.userInteractionEnabled = NO;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 460); //place the view just off screen, bottom right
    
    [UIView animateWithDuration:duration  
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         viewToShow.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         // Open Draft View
                         DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:self.selectedDraftID];
                         
                         [self.navigationController pushViewController:draftViewController animated:NO];
                     }
     ];
}

#pragma mark Book cover open animation
- (void) pageOpenView:(UIView *)viewToOpen duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToOpen.layer removeAllAnimations];
    
    // Make sure view is visible
    //viewToOpen.hidden = NO;
    [self.view bringSubviewToFront:viewToOpen];
    
    // disable the view so it’s not doing anything while animating
    viewToOpen.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the left edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToOpen.layer.anchorPoint.x != 0.0f) {
        viewToOpen.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToOpen.center = CGPointMake(viewToOpen.center.x - viewToOpen.bounds.size.width/2.0f, viewToOpen.center.y);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // start the animation from the current state
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D endTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                           0.0f,
                                                           -1.0f,
                                                           0.0f);
    // these values control the 3D projection outlook
    endTransform.m34 = 0.001f;
    endTransform.m14 = -0.0015f;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:endTransform];
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToOpen.tag] forKey:@"viewToOpenTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToOpen.layer addAnimation:theGroup forKey:@"flipBookCoverOpen"];
}

- (void) pageCloseView:(UIView *)viewToClose duration:(NSTimeInterval)duration {
    // Remove existing animations before starting new animation
    [viewToClose.layer removeAllAnimations];
    
    // Make sure view is visible
    //viewToClose.hidden = NO;
    [self.view bringSubviewToFront:viewToClose];
    
    // disable the view so it’s not doing anything while animating
    viewToClose.userInteractionEnabled = NO;
    // Set the CALayer anchorPoint to the left edge and
    // translate the view to account for the new
    // anchorPoint. In case you want to reuse the animation
    // for this view, we only do the translation and
    // anchor point setting once.
    if (viewToClose.layer.anchorPoint.x != 0.0f) {
        viewToClose.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
        viewToClose.center = CGPointMake(viewToClose.center.x - viewToClose.bounds.size.width/2.0f, viewToClose.center.y);
    }
    // create an animation to hold the page turning
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // start the animation from the open state
    // this is the basic rotation by 90 degree along the y-axis
    CATransform3D startTransform = CATransform3DMakeRotation(3.141f/2.0f,
                                                             0.0f,
                                                             -1.0f,
                                                             0.0f);
    // these values control the 3D projection outlook
    startTransform.m34 = 0.001f;
    startTransform.m14 = -0.0015f;
    transformAnimation.fromValue = [NSValue valueWithCATransform3D:startTransform];
    
    // end the transformation at the default state
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    // Create an animation group to hold the rotation
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    
    // Set self as the delegate to receive notification when the animation finishes
    theGroup.delegate = self;
    theGroup.duration = duration;
    // CAAnimation-objects support arbitrary Key-Value pairs, we add the UIView tag
    // to identify the animation later when it finishes
    [theGroup setValue:[NSNumber numberWithInt:viewToClose.tag] forKey:@"viewToCloseTag"];
    // Here you could add other animations to the array
    theGroup.animations = [NSArray arrayWithObjects:transformAnimation, nil];
    theGroup.fillMode = kCAFillModeBoth;
    theGroup.removedOnCompletion = NO;
    // Add the animation group to the layer
    [viewToClose.layer addAnimation:theGroup forKey:@"flipBookCoverClosed"];
}

- (void)openBook {
    [self pageOpenView:self.iv_bookCover duration:1.0f];
}

- (void)closeBook {
    [self pageCloseView:self.iv_bookCover duration:0.5f];
}


#pragma mark - Notification Button Handlers
- (void)updateNotificationButton {
    if ([self.authenticationManager isUserAuthenticated]) {
        int unreadNotifications = [User unopenedNotificationsFor:self.loggedInUser.objectid];
        
        if (unreadNotifications > 0) {
            if (unreadNotifications > 99) {
                // limit the label to "99"
                unreadNotifications = 99;
            }
            [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb_lit.png"] forState:UIControlStateNormal];
            
            [self.btn_notificationBadge setTitle:[NSString stringWithFormat:@"%d", unreadNotifications] forState:UIControlStateNormal];
            [self.btn_notificationBadge setHidden:NO];
        }
        else {
            [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb.png"] forState:UIControlStateNormal];
            [self.btn_notificationBadge setHidden:YES];
        }
    }
    else {
        [self.btn_notificationsButton setBackgroundImage:[UIImage imageNamed:@"typewriter_key-lightbulb.png"] forState:UIControlStateNormal];
        [self.btn_notificationBadge setHidden:YES];
    }
}

#pragma mark - Initializers
- (void) commonInit {
    //common setup for the view controller
    NSString* activityName = @"ProductionLogViewController.commonInit";
    
    if (self.cloudDraftEnumerator == nil) 
    {
        self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
        self.cloudDraftEnumerator.delegate = self;
    }
    
    if (!self.cloudDraftEnumerator.isLoading) 
    {
        //enumerator is not loading, so we can go ahead and reset it and run it
        
        if ([self.cloudDraftEnumerator canEnumerate]) 
        {
            LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Refreshing draft count from cloud",activityName);
            [self.cloudDraftEnumerator enumerateUntilEnd:nil];
        }
        else 
        {
            //the enumerator is not ready to run, but we reset it and away we go
            [self.cloudDraftEnumerator reset];
            [self.cloudDraftEnumerator enumerateUntilEnd:nil];
        }
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //backgroundQueue = dispatch_queue_create("com.bluelabel.bahndr", 0);
        backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
        // Custom initialization
        [self commonInit];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
    self.frc_draft_pages = nil;
    self.selectedDraftID = nil;
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)updateVisibleCells {
    NSArray* visibleCells = [self.tbl_productionTableView visibleCells];
    
    UIProductionLogTableViewCell* prodLogCell;
    
    for (int i = 0; i < [visibleCells count]; i++) {
        prodLogCell = [visibleCells objectAtIndex:i];
        
        [prodLogCell renderPhoto];
        [prodLogCell renderCaption];
        [prodLogCell renderUnreadCaptions];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
    //self.cloudDraftEnumerator.delegate = self;
    
    CGRect frameForRefreshHeader = CGRectMake(0, 0.0f - self.tbl_productionTableView.bounds.size.height, self.tbl_productionTableView.bounds.size.width, self.tbl_productionTableView.bounds.size.height);
    
    EGORefreshTableHeaderView* erthv = [[EGORefreshTableHeaderView alloc] initWithFrame:frameForRefreshHeader];
    self.refreshHeader = erthv;
    [erthv release];
    
    self.refreshHeader.delegate = self;
    self.refreshHeader.backgroundColor = [UIColor clearColor];
    self.tbl_productionTableView.rowHeight = kPRODUTIONLOGTABLEVIEWCELLHEIGHT;
    [self.tbl_productionTableView addSubview:self.refreshHeader];
    [self.refreshHeader refreshLastUpdatedDate];
    
    // Update draft counter labels at the top of the view
    //[self updateDraftCounterLabels];
    
    [self registerCallbackHandlers];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Navigation Bar Buttons
    UIBarButtonItem* leftButton = [[[UIBarButtonItem alloc]
                                     initWithTitle:@"Home"
                                    style:UIBarButtonItemStyleBordered 
                                    target:self 
                                    action:@selector(onHomeButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    // Setup the animation to show the typewriter
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = YES;
    
    // place the entire view just off screen so it can be shown with the pageShow animation
    //CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 480);
    //self.view.transform = transform;
    //CGSize viewSize = self.view.frame.size;
    //self.view.frame = CGRectMake(0, 460, viewSize.width, viewSize.height);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_productionTableView = nil;
    self.productionTableViewCell = nil;
    self.refreshHeader = nil;
    self.lbl_title = nil;
    self.v_typewriter = nil;
    self.btn_profileButton = nil;
    self.btn_newPageButton = nil;
    self.btn_notificationsButton = nil;
    self.btn_notificationBadge = nil;
    self.btn_homeButton = nil;
    self.iv_bookBackground = nil;
    self.iv_bookCover = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString* activityName = @"ProductionLogViewController.viewWillAppear:";
    [super viewWillAppear:animated];

    /*//if its the first time the user has opened the production log, we display a welcome message
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:setting_HASVIEWEDPRODUCTIONLOGVC] == NO) {
        //this is the first time opening, so we show a welcome message
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Production Log" message:ui_WELCOME_PRODUCTIONLOG delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }*/
    
    
    //we set the clouddraftenumerator delegate to this view controller
    self.cloudDraftEnumerator.delegate = self;
    
    //we perform this check to reset the table refresh header in the case
    //that it was left spinning errantly
    if (![self.cloudDraftEnumerator isLoading])
    {
        [self resetRefreshTableHeaderToNormalPosition];
    }
    
    if ([self.cloudDraftEnumerator canEnumerate]) 
    {
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Refreshing production log from cloud",activityName);
        [self.cloudDraftEnumerator enumerateUntilEnd:nil];
    }
    
    // refresh the notification feed
    Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
    BOOL isEnumeratingFeed = [[FeedManager instance]tryRefreshFeedOnFinish:callback];
      
    if (isEnumeratingFeed) 
    {
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Refreshing user's notification feed",activityName);
    }
       
    // Update notifications button on typewriter
    [self updateNotificationButton];
    
    // Make sure the status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Hide the navigation bar and tool bars so our custom bars can be shown
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    // Make sure the book cover is appropriately positioned if it will be opened
    if (self.shouldOpenBookCover == YES) {
        [self.iv_bookBackground setAlpha:1];
        [self.iv_bookCover setAlpha:1];
        [self.view bringSubviewToFront:self.iv_bookBackground];
        [self.view bringSubviewToFront:self.iv_bookCover];
    }
    else {
        [self.iv_bookBackground setAlpha:0];
        [self.iv_bookCover setAlpha:0];
        [self.view sendSubviewToBack:self.iv_bookBackground];
        [self.view sendSubviewToBack:self.iv_bookCover];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FlurryAnalytics logEvent:@"VIEWING_PRODUCTIONLOG" timed:YES];
    
    //if its the first time the user has opened the production log, we display a welcome message
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([userDefaults boolForKey:setting_HASVIEWEDPRODUCTIONLOGVC] == NO) {
//        //this is the first time opening, so we show a welcome message
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Production Log" message:ui_WELCOME_PRODUCTIONLOG delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//        
//        [alert show];
//        [alert release];
//        
//        //we mark that the user has viewed this viewcontroller at least once
//        [userDefaults setBool:YES forKey:setting_HASVIEWEDPRODUCTIONLOGVC];
//        [userDefaults synchronize];
//    }
    
    if (self.shouldOpenBookCover) {
        self.shouldOpenBookCover = NO;
        [self openBook];
    }
    else if (self.shouldCloseTypewriter) {
        [self closeTypewriter];
    }
    
    //[self pageShowView:self.view duration:0.5];
    
    [self updateVisibleCells];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [FlurryAnalytics endTimedEvent:@"VIEWING_PRODUCTIONLOG" withParameters:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* activityName = @"ProductionLogViewController.numberOfRowsInSection";
 
    int retVal = [[self.frc_draft_pages fetchedObjects]count];
    // Return the number of rows in the section.
    LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Number of rows in fetched results controller:%d",activityName,retVal);
    return retVal;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int draftCount = [[self.frc_draft_pages fetchedObjects]count];
    
    if ([indexPath row] < draftCount) {
        Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
        
        UIProductionLogTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UIProductionLogTableViewCell cellIdentifier]];
        if (cell == nil) {
            cell = [[[UIProductionLogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UIProductionLogTableViewCell cellIdentifier]] autorelease];
        }
        
        [cell renderDraftWithID:draft.objectid];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)customReloadData {
    // We need to capture each relaodData call on the Tableview
    // so we can show the thumbnails after each reload
    [self.tbl_productionTableView reloadData];
    
    [self updateVisibleCells];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



#pragma mark - UIAlertView Delegate
- (void)alertView:(UICustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    
    if (buttonIndex == 1 && alertView.delegate == self) {
        if (![self.authenticationManager isUserAuthenticated]) {
            // user is not logged in
            [self authenticate:YES withTwitter:NO onFinishSelector:alertView.onFinishSelector onTargetObject:self withObject:nil];
        }
    }
}

#pragma mark - Button Handlers
- (IBAction)onInfoButtonPressed:(id)sender {
    UITutorialView* infoView = [[UITutorialView alloc] initWithFrame:self.view.bounds withNibNamed:@"UITutorialViewProductionLog"];
    [self.view addSubview:infoView];
    [infoView release];
}

#pragma mark Navigation Button Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = NO;
    
//    [self dismissModalViewControllerAnimated:YES];
    
    BookViewControllerBase* bookViewController = [BookViewControllerBase createInstance];
    
    UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:bookViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];

}

#pragma mark Tyewriter Button Handlers
- (IBAction) onProfileButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    if (![self.authenticationManager isUserAuthenticated]) 
    {
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onProfileButtonPressed:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];

        [onSucccessCallback release];
        [onFailCallback release];
    }
    else {
        ProfileViewController* profileViewController = [ProfileViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:profileViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
   
}

- (IBAction) onPageButtonPressed:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) {
        [FlurryAnalytics logEvent:@"LOGIN_NEW_DRAFT_PRODUCTIONLOG"];
        
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onPageButtonPressed:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
        
        [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
        [onSucccessCallback release];
        [onFailCallback release];

    }
    else {
        [FlurryAnalytics logEvent:@"NEW_DRAFT_PRODUCTIONLOG" timed:YES];
        
        ContributeViewController* contributeViewController = [ContributeViewController createInstanceForNewDraft];
        contributeViewController.delegate = self;
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:contributeViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
       
    }
}

- (IBAction) onNotificationsButtonClicked:(id)sender {
    // Setup the typewriter animation
    self.shouldCloseTypewriter = NO;
    self.shouldOpenTypewriter = NO;
    
    //we check to ensure the user is logged in first
    if (![self.authenticationManager isUserAuthenticated]) 
    {
        Callback* onSucccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onNotificationsButtonClicked:) withContext:nil];        
        Callback* onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onLoginFailed:)];
         [self authenticateAndGetFacebook:NO getTwitter:NO onSuccessCallback:onSucccessCallback onFailureCallback:onFailCallback];
        
        
        [onSucccessCallback release];
        [onFailCallback release];
    }
    else {
        NotificationsViewController* notificationsViewController = [NotificationsViewController createInstance];
        
        UINavigationController* navigationController = [[UINavigationController alloc]initWithRootViewController:notificationsViewController];
        navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navigationController animated:YES];
        
        [navigationController release];
    }
}

#pragma mark - Table view delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    //[self.tbl_productionTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 63.0f, 0.0f)];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVisibleCells];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return kPRODUTIONLOGTABLEVIEWCELLHEIGHT;
    return 115;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Dynamic height based on feed message size
//    int textLabelTopMargin = 37;
//    int textLabelBottomMargin = 14;
//    
//    Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
//    
//    UIFont* font = [UIFont fontWithName:@"AmericanTypewriter" size:13];
//    
//    CGSize maximumSize = CGSizeMake(150, 1000);
//    
//    // Grab the top photo and caption
//    Caption* caption = [draft captionWithHighestVotes];
//    
//    NSString* message = caption.caption1;
//    
//    CGSize messageSize = [message sizeWithFont:font constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
//    
//    CGFloat height = kPRODUTIONLOGTABLEVIEWCELLHEIGHT; 
//    
//    if (messageSize.height > kPRODUTIONLOGTABLEVIEWCELLHEIGHT) {
//        // Message is taller than default height
//        height = messageSize.height + textLabelTopMargin + textLabelBottomMargin;
//    }
//    
//    return height;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Setup the typewriter animation
    self.shouldCloseTypewriter = YES;
    self.shouldOpenTypewriter = YES;
    
    /*// Set up navigation bar back button
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Production Log"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:nil
                                                                             action:nil] autorelease];
    
    // Open Draft View
    Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
    
    DraftViewController* draftViewController = [DraftViewController createInstanceWithPageID:draft.objectid];
    
    [self.navigationController pushViewController:draftViewController animated:YES];*/
    
    // Get ID of draft user selected
    Page* draft = [[self.frc_draft_pages fetchedObjects] objectAtIndex:[indexPath row]];
    self.selectedDraftID = draft.objectid;
    
    if (self.shouldOpenTypewriter) {
        [self openTypewriter];
    }
   
}

#pragma mark - NSFetchedResultsControllerDelegate methods
-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_productionTableView endUpdates];
    //[self.tbl_productionTableView reloadData];
    [self customReloadData];
}

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tbl_productionTableView beginUpdates];
}


- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"ProductionLogViewController.controller.didChangeObject:";
    if (controller == self.frc_draft_pages) {
        if (type == NSFetchedResultsChangeInsert) {
            //insertion of a new page
            Resource* resource = (Resource*)anObject;
            int count = [[self.frc_draft_pages fetchedObjects]count];
            LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Inserting newly created resource with type %@ and id %@ at index %d (num itemsin frc:%d)",activityName,resource.objecttype,resource.objectid,[newIndexPath row],count);
            [self.tbl_productionTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Scrolling table view to newly created item",activityName);
           // [self.tbl_productionTableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            //LOG_PRODUCTIONLOGVIEWCONTROLLER(0, @"%@Reloading table",activityName);
           // [self.tbl_productionTableView reloadData];
            // Update draft counter labels at the top of the view
            //[self updateDraftCounterLabels];
        }
        else if (type == NSFetchedResultsChangeDelete) {
            [self.tbl_productionTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
           // [self.tbl_productionTableView reloadData];
            // Update draft counter labels at the top of the view
            //[self updateDraftCounterLabels];
        }
    }
    else {
        LOG_PRODUCTIONLOGVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p",activityName,&controller);
    }
}

- (void) resetRefreshTableHeaderToNormalPosition 
{
    //we tell the ego fresh header that we've stopped loading items
    [self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbl_productionTableView];
    
    // reset the content inset of the tableview so bottom is not covered by toolbar
    [self.tbl_productionTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 63.0f, 0.0f)];
}

#pragma mark - Callback Event Handlers
- (void) onFeedRefreshComplete:(CallbackResult*)result 
{
    // Update notifications button on typewriter
    [self updateNotificationButton];
}

//- (void) onNewDraft:(CallbackResult*)result {
//   
////    NSDictionary* userInfo = (NSDictionary*)result.response;
////    Page* page = [userInfo objectForKey:PAGE];
////    NSNumber* pageID = [NSNumber numberWithLong:[page.objectid longValue]];
////    [pageID retain];
////    void (^block)(NSNumber*) = ^ (NSNumber* pageid) {
////        ResourceContext* resourceContext = [ResourceContext instance];
////        Page* p = (Page*)[resourceContext resourceWithType:PAGE withID:pageid];
////        [p updateCaptionWithHighestVotes];
// //   };
////    NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc]init];
////    [page performSelectorInBackground:@selector(updateCaptionWithHighestVotes) withObject:nil];
////    [autorelease drain];
////    [autorelease release];
//    //[page updateCaptionWithHighestVotes];
//     //dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
////    dispatch_async(backgroundQueue, ^{ block(pageID); });
////    [pageID release];
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}
//
//- (void) onNewPhoto:(CallbackResult*)result {
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}
//
////#define kGCDQueueName   @"com.bluelabellabs.bahndr"
////
////- (void) onNewCaptionVote_Async:(NSNumber*)captionid
////{
////    //create a dispatch queue
////    void (^block)(NSNumber*) = ^(NSNumber* cid) {
////        ResourceContext* resourceContext = [ResourceContext instance];
////        Caption* caption = (Caption*)[resourceContext resourceWithType:CAPTION withID:cid];
////        Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:caption.pageid]; 
////        
////        if (page != nil) 
////        {
////            // [page performSelectorInBackground:@selector(updateCaptionWithHighestVotes:) withObject:changedCaption];
////            [page updateCaptionWithHighestVotes:caption];
////            
////        }
////    };
////    
////    //dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
////    dispatch_async(backgroundQueue,^{block(captionid);});
////}
//
//
//
//- (void) onNewCaption:(CallbackResult*)result {
//  //  ResourceContext* resourceContext = [ResourceContext instance];
////    NSDictionary* userInfo = (NSDictionary*)result.response;
////    Caption* changedCaption = [userInfo objectForKey:CAPTION];
////    NSNumber* captionID = [NSNumber numberWithLong:[changedCaption.objectid longValue]]; 
////    [captionID retain];
////    
////    [self onNewCaptionVote_Async:captionID];
////    NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc]init];
////    
////    
////    [self performSelectorInBackground:@selector(onNewCaptionVote_Async:) withObject:captionID];
////    [autorelease drain];
////    [autorelease release];
////    [captionID release];
////    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:changedCaption.pageid]; 
////    
////    
////    if (page != nil) {
////        [page performSelectorInBackground:@selector(updateCaptionWithHighestVotes:) withObject:changedCaption];
////       
////    }
//    
////     [captionID release];
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}
//
//- (void) onNewPhotoVote:(CallbackResult*)result {
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}
//
//
//- (void) onNewCaptionVote:(CallbackResult*)result 
//{
//   // ResourceContext* resourceContext = [ResourceContext instance];
////    NSDictionary* userInfo = (NSDictionary*)result.response;
////    Caption* changedCaption = [userInfo objectForKey:CAPTION];
////    NSNumber* captionID = [NSNumber numberWithLong:[changedCaption.objectid longValue]]; 
////    [captionID retain];
//    
////    [self onNewCaptionVote_Async:captionID];
////    NSAutoreleasePool* autorelease = [[NSAutoreleasePool alloc]init];
////    
////    [self performSelectorInBackground:@selector(onNewCaptionVote_Async:) withObject:captionID];
////    [autorelease drain];
////    [autorelease release];
////    [captionID release];
////    Page* page = (Page*)[resourceContext resourceWithType:PAGE withID:changedCaption.pageid]; 
////    
////    if (page != nil) 
////    {
////        [page performSelectorInBackground:@selector(updateCaptionWithHighestVotes:) withObject:changedCaption];
//////        [page updateCaptionWithHighestVotes:changedCaption];
////    
////    }
////    [captionID release];
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}
//
//- (void) onUnreadCaptionUpdate:(CallbackResult*)result {
//    //[self.tbl_productionTableView reloadData];
//    [self customReloadData];
//}


#pragma mark - EgoRefreshTableHeaderDelegate
- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    NSString* activityName = @"ProductionLogViewController.egoRefreshTableHeaderDidTriggerRefresh:";
    //what we need to do is check if the enumerator is actually running
    //if its running lets not do anything
    //if its not running, we re-create a new one and away we go
    
    if (![self.cloudDraftEnumerator isLoading]) 
    {
        //enumerator is not loading
        [self.cloudDraftEnumerator reset];
        [self.cloudDraftEnumerator enumerateUntilEnd:nil];
    }
    else {
        //enumerator is currently loading, no refresh scheduled
        LOG_PRODUCTIONLOGVIEWCONTROLLER(0,@"%@Skipping refresh of production log as the enumerator is currently running",activityName);
        [self resetRefreshTableHeaderToNormalPosition];
    }
    
    //[self.cloudDraftEnumerator reset];
    //self.cloudDraftEnumerator = [[CloudEnumeratorFactory instance]enumeratorForDrafts];
    
//    self.cloudDraftEnumerator = nil;
//    self.cloudDraftEnumerator.delegate = self;
//    [self.cloudDraftEnumerator enumerateUntilEnd:nil];

}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    if (self.cloudDraftEnumerator != nil) {
        return [self.cloudDraftEnumerator isLoading];
    }
    else {
        return NO;
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}


#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    [self resetRefreshTableHeaderToNormalPosition];
}

#pragma mark - Static Initializer
+ (ProductionLogViewController*)createInstance {
    ProductionLogViewController* productionLogViewController = [[ProductionLogViewController alloc]initWithNibName:@"ProductionLogViewController" bundle:nil];
    [productionLogViewController autorelease];
    return productionLogViewController;
}

@end
