//
//  AuthenticationManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationManager.h"
#import "SFHFKeychainUtils.h"
#import "ApplicationSettings.h"
#import "JSONKit.h"
#import "NSStringGUIDCategory.h"
#import "WS_TransferManager.h"
@implementation AuthenticationManager
@synthesize m_LoggedInUserID;
@synthesize m_facebook;

static  AuthenticationManager* sharedManager; 



#pragma mark - initializers
- (id) init {
    NSString* activityName=@"AuthenticationManager.init:";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* lastUserID = [defaults valueForKey:an_USERID];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber * lastLoggedInUserID = [f numberFromString:lastUserID];
    [f release];
    
    
    if (lastLoggedInUserID != 0) {
        AuthenticationContext* storedContext = [self getAuthenticationContextForUser:lastLoggedInUserID];
        if (storedContext != nil) {
            [self loginUser:lastLoggedInUserID withAuthenticationContext:storedContext];
            [BLLog v:activityName withMessage:@"loaded last logged in user: %@", lastLoggedInUserID];
        }
        else {
             [BLLog v:activityName withMessage:@"no last logged in user id present in settings"];
        }
        
        
    }
    else {
        [BLLog v:activityName withMessage:@"no last logged in user id present in settings"];
    }
    
    //grab the facebook instance from the app delegate handler
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.m_facebook = appDelegate.facebook;
    

    
    
    return self;
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    NSString* activityName = @"AuthenticationManager.fbDidLogin:";
    NSString* message = [NSString stringWithFormat:@"Facebook login successful, retrieving user profile data"];
    [BLLog v:activityName withMessage:message];

    
    
    //get the user object
    [self.m_facebook requestWithGraphPath:@"me" andDelegate:self];
}


#pragma mark -- FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"AuthenticationManager.request:didLoad:";
    NSString* message = [NSString stringWithFormat:@"Facebook request succeeded"];
    [BLLog v:activityName withMessage:message];
    
    WS_EnumerationManager *enumerationManager = [WS_EnumerationManager getInstance];
    NSString* facebookIDString = [result valueForKey:an_ID];
    NSNumber* facebookID = [facebookIDString numberValue];
    NSString* displayName = [result valueForKey:an_NAME];
    NSString* notificationID = [NSString GetGUID];
    
    //we request offline permission, so the FB expiry date isnt needed. we set this to the current date, itsmeaningless
    NSDate* expiryDate = [NSDate date];
    //Add an observer so that we can listen in for when authentication is complete
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onGetAuthenticationContextDownloaded:) name:notificationID object:nil];
    
    
    [enumerationManager getAuthenticatorToken:facebookID withName:displayName withFacebookAccessToken:self.m_facebook.accessToken withFacebookTokenExpiry:expiryDate onFinishNotify:notificationID];
    
}

- (void) onGetAuthenticationContextDownloaded:(NSNotification*)notification {
    NSString* activityName = @"AuthenticationManager.onGetAuthenticationContextDownloaded:";
    NSDictionary* userInfo = [notification userInfo];
    AuthenticationContext* newContext = [[userInfo objectForKey:an_AUTHENTICATIONCONTEXT]retain];
    
    NSString* message = [NSString stringWithFormat:@"Authentication context received from server, logging in user: %@",newContext.userid];
    [BLLog v:activityName withMessage:message];
    
    [self loginUser:newContext.userid withAuthenticationContext:newContext];
    
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error  {
    NSString* activityName = @"AuthenticationManager:request:didFailWithError";
    NSString* message = [NSString stringWithFormat:@"Facebook request failed with error: %@",[error description]];
    [BLLog e:activityName withMessage:message];
}

#pragma mark - authenticators
-(void) authenticate {
   //now we need to grab their facebook authentication data, and then log them into our app    
    NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", @"publish_stream",@"user_about_me", nil];
    [self.m_facebook authorize:permissions delegate:self];
  
    
}
- (void)loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext *)context {
    NSString* activityName = @"AuthenticationManager.loginUser";


    
    NSError* error = nil;
    NSString* json = [context toJSON];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    //check to see if the passed in context has valid facebook access data, if so, initiate the facebook session
    if (context.facebookAccessToken && context.facebookAccessTokenExpiryDate) {
        self.m_facebook.accessToken = context.facebookAccessToken;
        self.m_facebook.expirationDate = context.facebookAccessTokenExpiryDate;
        
        if (![self.m_facebook isSessionValid]) {
            NSString* message = [NSString stringWithFormat:@"Passed in access token is not valid, Facebook session not created"];
            [BLLog v:activityName withMessage:message];
        }
    }
    
    
    //now we save it in the key chain
    [SFHFKeychainUtils storeUsername:[userID stringValue] andPassword:json forServiceName:sn_KEYCHAINSERVICENAME updateExisting:YES error:&error];
    
    
    if (error != nil) {
        NSString* errorMessage = [NSString stringWithFormat:@"error: %@",[error description]];
        [BLLog e:activityName withMessage:errorMessage];
    }
    else {
        self.m_LoggedInUserID = userID;
        
        //we save the user id into the user defaults object so we can use that to load the correct user up
        //upon startup
        [userDefaults setValue:[userID stringValue] forKey:an_USERID];
        [userDefaults synchronize];
    }
    
}

- (void) logoff {
    NSString* activityName = @"AuthenticationManager.logoff:";
    
    if (![self.m_LoggedInUserID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        //user is currently logged in
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults valueForKey:an_USERID] != nil) {
            [userDefaults removeObjectForKey:an_USERID];
            [userDefaults synchronize];
        }
        
        NSError* error = nil;
        [SFHFKeychainUtils deleteItemForUsername:[self.m_LoggedInUserID stringValue] andServiceName:sn_KEYCHAINSERVICENAME error:&error];
        
        self.m_LoggedInUserID = 0;
        //at this point the user is logged off
        
        NSString* message = @"User logged off successfully"  ;
        [BLLog v:activityName withMessage:message];
    }
    else {
        NSString* message = @"No user logged in"  ;
        [BLLog v:activityName withMessage:message];
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

    
    //grab access token
    NSError* error = nil;
    NSString* jsonRepresentation = [SFHFKeychainUtils getPasswordForUsername:[userID stringValue] andServiceName:sn_KEYCHAINSERVICENAME error:&error];
    
    if (jsonRepresentation != nil) {
        
        if (error != nil) {
            NSString* message = [NSString stringWithFormat:@"Error when loading authentication context: %@",[error description]];
            [BLLog e:activityName withMessage:message];
            
        }
        else {
            NSDictionary* jsonDictionary = [jsonRepresentation objectFromJSONString];
            retVal = [[[AuthenticationContext alloc]initFromDictionary:jsonDictionary]autorelease];
            
        }
    }
    //now we have a context that is populated with the necessary credentials for the user
    return retVal;
    
}
@end
