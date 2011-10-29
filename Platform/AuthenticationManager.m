//
//  AuthenticationManager.m
//  Platform
//
//  Created by Bobby Gill on 10/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationManager.h"
#import "PlatformAppDelegate.h"
#import "ResourceContext.h"
#import "User.h"
#import "ImageManager.h"
#import "Types.h"
#import "Attributes.h"
#import "Facebook.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "AuthenticationContext.h"
#import "NSStringGUIDCategory.h"
#import "SFHFKeychainUtils.h"
#import "CallbackResult.h"
#import "EventManager.h"
#import "Macros.h"
#import "GetAuthenticatorResponse.h"

#define kKeyChainServiceName    @"Aardvark"
#define kUser                   @"User"

static  AuthenticationManager* sharedManager;

@implementation AuthenticationManager
@synthesize m_LoggedInUserID;
@synthesize facebook = __facebook;
@synthesize fbPictureRequest = m_fbPictureRequest;
@synthesize fbProfileRequest = m_fbProfileRequest;



+ (id) instance {
    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        }
        return sharedManager;
    }
}

#pragma mark - Properties


- (Facebook*) facebook {
    if (__facebook != nil) {
        return __facebook;
    }
    PlatformAppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
    __facebook = appDelegate.facebook;
    return __facebook;
}

#pragma mark - initializers
- (id) init {
    NSString* activityName =@"AuthenticationManager.init:";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* lastUserID = [defaults valueForKey:USERID];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber * lastLoggedInUserID = [f numberFromString:lastUserID];
    [f release];
    
    
    if (lastLoggedInUserID != 0) {
        AuthenticationContext* storedContext = [self contextForUserWithID:lastLoggedInUserID];
        if (storedContext != nil) {
            [self loginUser:lastLoggedInUserID withAuthenticationContext:storedContext];
            LOG_SECURITY(0, @"%@%@",activityName,@" Loaded stored user context");
        }
        else {
      
        }
    }
    else {
        LOG_SECURITY(0, @"%@%@",activityName,@" No stored user context found, will require re-authentication");
    }
    
    
    
    
    return self;
}


#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    NSString* activityName = @"AuthenticationManager.fbDidLogin:";
    LOG_SECURITY(0,@"%@%@", activityName,@" completed facebook authentication, beginning download os user profile from Facebook");
    //get the user object
    
    self.fbProfileRequest = [self.facebook requestWithGraphPath:@"me" andDelegate:self];        
}

#pragma mark -- FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSString* activityName = @"AuthenticationManager.requestDidLoad:";
    ResourceContext* resourceContext = [ResourceContext instance];
    
    if (request == self.fbProfileRequest) {
        LOG_SECURITY(0, @"%@%@",activityName,@"Facebook profile downloaded for logged in user");
        NSString* facebookIDString = [result valueForKey:ID];
        NSNumber* facebookID = [facebookIDString numberValue];
        NSString* displayName = [result valueForKey:NAME];
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onGetAuthenticationContextDownloaded:)];
        //we request offline permission, so the FB expiry date isnt needed. we set this to the current date, itsmeaningless
        
        LOG_SECURITY(0, @"%@:Requesting new authenticator from service withName:%@, withFacebookAccessToken:%@",activityName,displayName,self.facebook.accessToken);
        [resourceContext getAuthenticatorToken:facebookID withName:displayName withFacebookAccessToken:self.facebook.accessToken withFacebookTokenExpiry:self.facebook.expirationDate onFinishNotify:callback];
          
    }
    else if (request == self.fbPictureRequest) {
        User* userObject = (User*)[resourceContext resourceWithType:USER withID:m_LoggedInUserID];
      
        AuthenticationContext* currentContext = [self contextForLoggedInUser];
        
        if (userObject != nil && currentContext != nil) {
            UIImage* image = [UIImage imageWithData:result];
            LOG_SECURITY(0,@"%@Download of Facebook profile complete, saving photo to phone",activityName);
            //we need to save this image to the local file system
            ImageManager* imageManager = [ImageManager instance];
            NSString* path = [imageManager saveImage:image withFileName:currentContext.facebookuserid];
            
            //save the path on the user object and commit            
            userObject.thumbnailurl = path;
            [resourceContext save:YES onFinishCallback:nil];
        }
    }
    
}

- (AuthenticationContext*) contextForUserWithID:(NSNumber*)userid {
    NSString* activityName = @"AuthenticationManager.contextForUserWithID:";
    AuthenticationContext* retVal = nil;
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //grab access token
    NSError* error = nil;
    NSString* jsonRepresentation = [SFHFKeychainUtils getPasswordForUsername:[userid stringValue] andServiceName:kKeyChainServiceName error:&error];
    
    if (jsonRepresentation != nil) {
        
        if (error != nil) {
            LOG_SECURITY(1, @"%@Could not deserialize stored authentication context:@%",activityName,error);
            
        }
        else {
            NSEntityDescription* entity = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:resourceContext.managedObjectContext];
           
            NSDictionary* jsonDictionary = [jsonRepresentation objectFromJSONString];
            retVal = [[AuthenticationContext alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:resourceContext];
            
        }
    }
    //now we have a context that is populated with the necessary credentials for the user
    return retVal;
}
- (AuthenticationContext*) contextForLoggedInUser {
    //TODO implement authentication manager methods;
    if (self.m_LoggedInUserID != nil &&
        ![self.m_LoggedInUserID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        
        return [self contextForUserWithID:self.m_LoggedInUserID];
    }
    else {
        return nil;
    };
}

#pragma mark - Login/Logoff Methods
-(void) authenticate {
    NSString* activityName = @"AuthenticationManager.authenticate:";
    //now we need to grab their facebook authentication data, and then log them into our app    
    NSArray *permissions = [NSArray arrayWithObjects:@"offline_access", @"publish_stream",@"user_about_me", nil];
    if (![self.facebook isSessionValid]) {
        LOG_SECURITY(0,@"%@%@",activityName, @"Beginning facebook authentication sequencce");
        [self.facebook authorize:permissions delegate:self];
    }
    
}

- (BOOL)saveAuthenticationContextToKeychainForUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext*)context {
    NSString* activityName = @"AuthenticationManager.saveAuthenticationContextToKeychain:";
    NSError* error = nil;
    NSString* json = [context toJSON];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL retVal = NO;
    
    //now we save it in the key chain
    [SFHFKeychainUtils storeUsername:[userID stringValue] andPassword:json forServiceName:kKeyChainServiceName updateExisting:YES error:&error];
    
    if (error != nil) {
        LOG_SECURITY(1, @"%@Couldn't persist authentication token to keychain: %@",activityName,error);
        
    }
    else {
        //we save the user id into the user defaults object so we can use that to load the correct user up
        //upon startup
        [userDefaults setValue:[userID stringValue] forKey:USERID];
        [userDefaults synchronize];
        retVal = YES;
    }
    return retVal;
}

- (void)loginUser:(NSNumber*)userID withAuthenticationContext:(AuthenticationContext *)context {
    NSString* activityName = @"AuthenticationManager.loginUser:";
    ResourceContext* resourceContext = [ResourceContext instance];
    
    //check to see if the passed in context has valid facebook access data, if so, initiate the facebook session
    if (context.facebookaccesstoken) {
        self.facebook.accessToken = context.facebookaccesstoken;
        
        if (![self.facebook isSessionValid]) {            
            LOG_SECURITY(1, @"%@Facebook session is invalid with token %@",activityName,self.facebook.accessToken);
        }
    }
    else {
        LOG_SECURITY(1, @"%@%@",activityName,@"No facebook token returned in authenticator");
    }
    //set the current user id
    self.m_LoggedInUserID = userID;
    
    
    //check to see if the profile picture is empty, if so, lets grab it from fb
    User* currentUser = (User*)[resourceContext resourceWithType:USER withID:m_LoggedInUserID]; 
    
    if (currentUser != nil && (currentUser.thumbnailurl == nil ||
                               [currentUser.thumbnailurl isEqualToString:@""])) {
        
        
        //since we logged in successfully, now lets grab the profile photo                    
        self.fbPictureRequest = [self.facebook requestWithGraphPath:@"me/picture" andDelegate:self];
        LOG_SECURITY(0,@"%@User %@ doesnt have a profile picture, downloading from Facebook...",activityName,currentUser.objectid);
    }
    
    //now we emit the system wide notification to tell people the user has logged in
    EventManager* eventManager = [EventManager instance];
    [eventManager raiseUserLoggedInEvent:nil];
    LOG_SECURITY(0,@"%@User %@ successfully logged into application",activityName,self.m_LoggedInUserID);
    
}

- (void) logoff {
   
    NSString* activityName = @"AuthenticationManager.logoff:";
    if (![self.m_LoggedInUserID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        //user is currently logged in
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults valueForKey:USERID] != nil) {
            [userDefaults removeObjectForKey:USERID];
            [userDefaults synchronize];
        }
        
        NSError* error = nil;
        [SFHFKeychainUtils deleteItemForUsername:[self.m_LoggedInUserID stringValue] andServiceName:kKeyChainServiceName error:&error];
        
        self.m_LoggedInUserID = 0;
        //at this point the user is logged off
        
        [self.facebook logout:self];
        
        //we emit a system wide event to notify any listeners that the user has logged out
        EventManager* eventManager = [EventManager instance];
        [eventManager raiseUserLoggedOutEvent:nil];
        LOG_SECURITY(0,@"%@User has been logged out of application",activityName);
    }

}

- (BOOL) isUserAuthenticated {
    return (m_LoggedInUserID != nil && [m_LoggedInUserID intValue] != 0);
}

#pragma mark - Async Callback Handlers
- (void) onGetAuthenticationContextDownloaded:(CallbackResult*)result {
    ResourceContext* resourceContext = [ResourceContext instance];
    GetAuthenticatorResponse* response = (GetAuthenticatorResponse*)result.response;
    
    
    AuthenticationContext* newContext = response.authenticationcontext;
    User* returnedUser = response.user;
    
    Resource* existingUser = [resourceContext resourceWithType:USER withID:returnedUser.objectid];
        
    //save the user object that is returned to us in the database
    if (existingUser != nil) {
        [existingUser refreshWith:returnedUser];
    }
    else {
        //need to insert the new user into the resource context
        [resourceContext insert:returnedUser];
    }
    [resourceContext save:YES onFinishCallback:nil];
    
    BOOL contextSavedToKeyChain = [self saveAuthenticationContextToKeychainForUser:newContext.userid withAuthenticationContext:newContext];
    
    if (contextSavedToKeyChain) {
        [self loginUser:newContext.userid withAuthenticationContext:newContext];
    }
    else {
        //unable to login user due to inability to save the credential to key chain
        //raise global error
        
        EventManager* eventManager = [EventManager instance];
        [eventManager raiseUserLoginFailedEvent:nil];
    }
    
}


@end
