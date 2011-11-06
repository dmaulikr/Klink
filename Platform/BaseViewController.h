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

#import "FeedManager.h"
#import "EventManager.h"

@class UICameraActionSheet;
@class CallbackResult;

@interface BaseViewController : UIViewController {
    UICameraActionSheet*    m_cameraActionSheet;
}
@property (nonatomic, retain) FeedManager*              feedManager;
@property (nonatomic, retain) AuthenticationManager*    authenticationManager;
@property (nonatomic, retain) EventManager*             eventManager;
@property (nonatomic, retain) NSManagedObjectContext*   managedObjectContext;
@property (nonatomic, retain) UICameraActionSheet*      cameraActionSheet;
@property (nonatomic, retain) User*                     loggedInUser;

- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image;
- (void) onUserLoggedIn:(CallbackResult*)result;
- (void) onUserLoggedOut:(CallbackResult*)result;
@end
