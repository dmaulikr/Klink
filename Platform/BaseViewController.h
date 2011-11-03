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
#import "User.h"
@interface BaseViewController : UIViewController {
    
}

@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;
@property (nonatomic, retain) User*                     loggedInUser;

@end
