//
//  AuthenticationManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationManager.h"


@implementation AuthenticationManager
@synthesize m_LoggedInUserID;
@synthesize m_facebook = __facebook;

static  AuthenticationManager* sharedManager; 

-(Facebook*)facebook {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.facebook;
}

#pragma mark - initializers
- (id) init {
    NSString* activityName=@"AuthenticationManager.init:";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = stng_LASTLOGGEDINUSERID;
    NSNumber* lastLoggedInUserID = (NSNumber*)[defaults objectForKey:key];
    
    if (lastLoggedInUserID != 0) {
        self.m_LoggedInUserID = lastLoggedInUserID;
        [BLLog v:activityName withMessage:@"loaded last logged in user: %@", lastLoggedInUserID];
    }
    else {
        [BLLog v:activityName withMessage:@"no last logged in user id present in settings"];
    }
    
    
    return self;
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.m_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.m_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self.m_facebook requestWithGraphPath:@"me" andDelegate:self];
}
#pragma mark -- FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error  {
    NSString* activityName = @"AuthenticationManager:request:didFailWithError";
    NSString* message = [NSString stringWithFormat:@"Facebook request failed with error: %@",[error description]];
    [BLLog e:activityName withMessage:message];
}

#pragma mark - authenticators
-(void) loginUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.m_facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.m_facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![self.m_facebook isSessionValid]) {
        [self.m_facebook authorize:nil delegate:self];
    }
}
- (void)loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext *)context {
    NSString* activityName = @"AuthenticationManager.loginUser";
    NSString* stringUserID = [userID stringValue];
    AuthenticationContext* existingContext = [DataLayer getObjectByType:tn_AUTHENTICATIONCONTEXT withValueEqual:stringUserID forAttribute:an_USERID];
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    NSManagedObjectContext *appContext = appDelegate.managedObjectContext;    

    if (existingContext == nil) {
        [appContext insertObject:context];
        
    }
    else {
        [existingContext copyFrom:context];
    }
    
    NSError* error = nil;
    [appContext save:&error];
    
    
    if (error != nil) {
        NSString* errorMessage = [NSString stringWithFormat:@"error: %@",[error description]];
        [BLLog e:activityName withMessage:errorMessage];
    }
    else {
        self.m_LoggedInUserID = userID;
    }
    
}

#pragma mark - accessors

- (NSNumber*) getLoggedInUserID {
    return self.m_LoggedInUserID;
}

+ (NSString*) getTypeName {
    return @"AuthenticationManager";
}

+ (AuthenticationManager*) getInstance {
    NSString* activityName=@"AuthenticationManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
            [BLLog v:activityName withMessage:@"completed initialization"];
        }        
        return sharedManager;
    }
}

- (AuthenticationContext*) getAuthenticationContext {
    if (m_LoggedInUserID == 0) {
    return nil;
    }
    else {
        AuthenticationContext* loggedInUserContext = [self getAuthenticationContextForUser:m_LoggedInUserID];
        return loggedInUserContext;
    }
}

// Returns a the authentication context object stored in the datastore. If none exists,
// returns nil.
- (AuthenticationContext*) getAuthenticationContextForUser:(NSNumber*)userID {
    AuthenticationContext* retVal = nil;
    NSString *activityName = @"AuthenticationManager.getAuthenticationContextForUser:";
    NSString *typeName = tn_AUTHENTICATIONCONTEXT;
    NSString *stringValue = [userID stringValue];
    retVal = [DataLayer getObjectByType:typeName withValueEqual:stringValue forAttribute:an_USERID];
    
    if (retVal == nil) {
        [BLLog v:activityName withMessage:@"no authentication context exists for user: %@",stringValue];
    }
    
    return retVal;
}
@end
