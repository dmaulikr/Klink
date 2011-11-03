//
//  BaseViewController.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ResourceContext.h"
#import "AuthenticationManager.h"
#import "FeedManager.h"
#import "EventManager.h"
@class CallbackResult;
@interface BaseViewController : UIViewController {
    
}
@property (nonatomic, retain) FeedManager*              feedManager;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) EventManager*             eventManager;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;

- (void) onUserLoggedIn:(CallbackResult*)result;
- (void) onUserLoggedOut:(CallbackResult*)result;
@end
