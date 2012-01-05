//
//  SocialSharingManager.m
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SocialSharingManager.h"

#import "Caption.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "Photo.h"
#import "Request.h"
#import "RequestManager.h"
#import "UrlManager.h"
#import "Macros.h"

@implementation SocialSharingManager


#pragma mark - Instance Management

static  SocialSharingManager* sharedManager;

+ (id) getInstance {
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
           
        }        
        return sharedManager;
    }
}

#pragma mark - Initializer
- (id) init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) share:(NSURL*)url 
withSharingOptions:(SharingOptions*)sharingOptions 
      onFinish:(Callback*)callback 
trackProgressWith:(id<RequestProgressDelegate>)progressDelegate 
{
    Request* request = [Request createInstanceOfRequest];
    request.url = [url absoluteString];
    request.onFailCallback = callback;
    request.onSuccessCallback = callback;
    request.operationcode =[NSNumber numberWithInt:kSHARE];
    request.delegate = progressDelegate;
     [request updateRequestStatus:kPENDING];
    //request.statuscode = [NSNumber numberWithInt:kPENDING];
    
    [progressDelegate initializeWith:[NSArray arrayWithObject:request]];
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];

}


#pragma mark - Sharing Methods
- (void) sharePageOnFacebook:(NSNumber *)pageID 
                    onFinish:(Callback *)callback 
           trackProgressWith:(id<RequestProgressDelegate>)progressDelegate 
{
    NSString* activityName = @"SocialSharingManager.sharePageOnFacebook:";
    SharingOptions* sharingOptions = [SharingOptions shareOnFacebook];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:pageID withObjectType:PAGE withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }
    
}

- (void) sharePageOnTwitter:(NSNumber *)pageID 
                   onFinish:(Callback *)callback 
          trackProgressWith:(id<RequestProgressDelegate>)progressDelegate 
{
    NSString* activityName = @"SocialSharingManager.sharePageOnTwitter:";
    SharingOptions* sharingOptions = [SharingOptions shareOnTwitter];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:pageID withObjectType:CAPTION withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }

}


//This method will share a caption on Facebook and Twitter
- (void) shareCaption:(NSNumber*)captionID 
             onFinish:(Callback*)callback 
    trackProgressWith:(id<RequestProgressDelegate>)progressDelegate 
{
    NSString* activityName = @"SocialSharingManager.shareCaption:";
    SharingOptions* sharingOptions = [SharingOptions shareOnAll];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:captionID withObjectType:CAPTION withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }
    
}

//This method will share a caption on Facebook 
- (void) shareCaptionOnFacebook:(NSNumber*)captionID 
                       onFinish:(Callback*)callback 
              trackProgressWith:(id<RequestProgressDelegate>)progressDelegate
{
    NSString* activityName = @"SocialSharingManager.shareCaptionOnFacebook:";
    SharingOptions* sharingOptions = [SharingOptions shareOnFacebook];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:captionID withObjectType:CAPTION withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }

}

//This method will share a caption on Twitter
- (void) shareCaptionOnTwitter:(NSNumber*)captionID onFinish:(Callback*)callback trackProgressWith:(id<RequestProgressDelegate>)progressDelegate{
    NSString* activityName = @"SocialSharingManager.shareCaptionOnTwitter:";
    SharingOptions* sharingOptions = [SharingOptions shareOnTwitter];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    
    if ([authenticationManager isUserAuthenticated]) {
        NSURL* url = [UrlManager urlForShareObject:captionID withObjectType:CAPTION withOptions:sharingOptions withAuthenticationContext:[authenticationManager contextForLoggedInUser]];
        [self share:url withSharingOptions:sharingOptions onFinish:callback trackProgressWith:progressDelegate];
        
    }
    else {
        //error, cant share unauthenticated
        LOG_SOCIALSHARINGMANAGER(1,@"%@Cannot share without being logged in",activityName);
    }
}




@end
