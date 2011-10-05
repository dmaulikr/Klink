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
#import "NotificationNames.h"
#import "User.h"
#import "ImageManager.h"
@implementation AuthenticationManager

@synthesize m_LoggedInUserID;
@synthesize facebook = __facebook;
@synthesize fbPictureRequest = m_fbPictureRequest;
@synthesize fbProfileRequest = m_fbProfileRequest;

static  AuthenticationManager* sharedManager; 

#pragma mark - Properties
- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }
    Klink_V2AppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    __facebook = appDelegate.facebook;
    return __facebook;
}

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
    
 
    
    
    return self;
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    NSString* activityName = @"AuthenticationManager.fbDidLogin:";
    NSString* message = [NSString stringWithFormat:@"Facebook login successful, accessToken:%@, expiryDate:%@",self.facebook.accessToken,self.facebook.expirationDate];
  
    [BLLog v:activityName withMessage:message];

    
    
    //get the user object
    self.fbProfileRequest = [self.facebook requestWithGraphPath:@"me" andDelegate:self];
    
  
}


#pragma mark -- FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"AuthenticationManager.request:didLoad:";
    NSString* message = [NSString stringWithFormat:@"Facebook request succeeded"];
    [BLLog v:activityName withMessage:message];
    
    if (request == self.fbProfileRequest) {
        WS_EnumerationManager *enumerationManager = [WS_EnumerationManager getInstance];
        NSString* facebookIDString = [result valueForKey:an_ID];
        NSNumber* facebookID = [facebookIDString numberValue];
        NSString* displayName = [result valueForKey:an_NAME];
        NSString* notificationID = [NSString GetGUID];
        
        //we request offline permission, so the FB expiry date isnt needed. we set this to the current date, itsmeaningless
        
        //Add an observer so that we can listen in for when authentication is complete
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onGetAuthenticationContextDownloaded:) name:notificationID object:nil];
        
        
        NSString* nm = [NSString stringWithFormat:@"Returned facebook token: %@",self.facebook.accessToken];
        [BLLog v:activityName withMessage:nm];
        [enumerationManager getAuthenticatorToken:facebookID withName:displayName withFacebookAccessToken:self.facebook.accessToken withFacebookTokenExpiry:self.facebook.expirationDate onFinishNotify:notificationID];
        
       
        
    }
    else if (request == self.fbPictureRequest) {
        User* userObject = [DataLayer getObjectByID:m_LoggedInUserID withObjectType:USER];
        AuthenticationContext* currentContext = [self getAuthenticationContext];
        
        if (userObject != nil && currentContext != nil) {
            UIImage* image = [UIImage imageWithData:result];
            
            //we need to save this image to the local file system
            ImageManager* imageManager = [ImageManager getInstance];
            NSString* path = [imageManager saveImage:image withFileName:currentContext.facebookUserID];
            
            //save the path on the user object and commit
            
            userObject.thumbnailURL = path;
            [userObject commitChangesToDatabase:NO withPendingFlag:NO];
            
            NSString* message = [NSString stringWithFormat:@"Updated user profile photo to %@",path];
            [BLLog v:activityName withMessage:message];
        }
    }
    
}

- (void) onGetAuthenticationContextDownloaded:(NSNotification*)notification {
    NSString* activityName = @"AuthenticationManager.onGetAuthenticationContextDownloaded:";
    NSDictionary* userInfo = [notification userInfo];
    AuthenticationContext* newContext = [[userInfo objectForKey:an_AUTHENTICATIONCONTEXT]retain];
    User* user = [[userInfo objectForKey:an_USER]retain];
    
    NSString* message = [NSString stringWithFormat:@"Authentication context received from server, logging in user: %@",newContext.userid];
    [BLLog v:activityName withMessage:message];
    
    //save the user object that is returned to us in the database
    [ServerManagedResource refreshWithServerVersion:user];
    
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
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:permissions delegate:self];
    }
    
}
- (void)loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext *)context {
    NSString* activityName = @"AuthenticationManager.loginUser";


    
    NSError* error = nil;
    NSString* json = [context toJSON];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    //check to see if the passed in context has valid facebook access data, if so, initiate the facebook session
    if (context.facebookAccessToken) {
        self.facebook.accessToken = context.facebookAccessToken;
        self.facebook.expirationDate = context.facebookAccessTokenExpiryDate;
        
        NSString* message = [NSString stringWithFormat:@"Attempting to create Facebook session for accessToken:%@ and expiryDate:%@",context.facebookAccessToken,context.facebookAccessTokenExpiryDate];
        [BLLog v:activityName withMessage:message];
        
        if (![self.facebook isSessionValid]) {
            NSString* message = [NSString stringWithFormat:@"Passed in access token is not valid, Facebook session not created"];
            [BLLog v:activityName withMessage:message];
        }
        else {
            NSString* message = [NSString stringWithFormat:@"Successfully created Facebook session"];
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
        
        //check to see if the profile picture is empty, if so, lets grab it from fb
        User* currentUser = [DataLayer getObjectByID:m_LoggedInUserID withObjectType:USER];
        if (currentUser != nil && (currentUser.thumbnailURL == nil ||
                                   [currentUser.thumbnailURL isEqualToString:@""])) {
            
            NSString* message = [NSString stringWithFormat:@"User %@ thumbnailURL is %@ and requires update",m_LoggedInUserID,currentUser.thumbnailURL];
            [BLLog v:activityName withMessage:message];
            //since we logged in successfully, now lets grab the profile photo            
            
            self.fbPictureRequest = [self.facebook requestWithGraphPath:@"me/picture" andDelegate:self];
        }

        //now we emit the system wide notification to tell people the user has logged in
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:n_USER_LOGGED_IN object:self];
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
        
        [self.facebook logout:self];
        
        //we emit a system wide event to notify any listeners that the user has logged out
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:n_USER_LOGGED_OUT object:self];
        
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

- (BOOL) isUserLoggedIn {
    if ([self.m_LoggedInUserID isEqualToNumber:[NSNumber numberWithInt:0]] ||
        self.m_LoggedInUserID == nil) {
        return NO;
    }
    else {
        return YES;
    }
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
