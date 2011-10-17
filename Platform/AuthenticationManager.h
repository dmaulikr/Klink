//
//  AuthenticationManager.h
//  Platform
//
//  Created by Bobby Gill on 10/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationContext.h"
#import "FBConnect.h"
@interface AuthenticationManager : NSObject <FBSessionDelegate, FBRequestDelegate> {
    NSNumber*   m_LoggedInUserID;
    Facebook*   facebook;
    FBRequest*  m_fbProfileRequest;
    FBRequest*  m_fbPictureRequest;
}

@property (nonatomic, retain) NSNumber* m_LoggedInUserID;
@property (nonatomic, retain) Facebook* facebook;
@property (nonatomic, retain) FBRequest*    fbProfileRequest;
@property (nonatomic, retain) FBRequest*    fbPictureRequest;

- (id) init;
- (AuthenticationContext*) contextForLoggedInUser;
- (AuthenticationContext*) contextForUserWithID:(NSNumber*)userid;
- (void) loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext*)context;
- (void) logoff;
+ (id) instance;

@end
