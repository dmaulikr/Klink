//
//  AuthenticationManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationContext.h"
#import "Klink_V2AppDelegate.h"
#import "TypeNames.h"
#import "DataLayer.h"
#import "ApplicationSettings.h"
@class AuthenticationContext;
@interface AuthenticationManager : NSObject {
 NSNumber* m_LoggedInUserID;
}

@property (nonatomic, retain) NSNumber* m_LoggedInUserID;

- (id) init;
- (id) getAuthenticationContextForUser:(NSNumber*)userID;
- (id) getAuthenticationContext;
- (NSNumber*) getLoggedInUserID;
- (void) loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext*)context;
+ (NSString*) getTypeName;
+ (AuthenticationManager*) getInstance;
@end
