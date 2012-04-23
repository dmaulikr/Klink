//
//  UrlManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceVerbs.h"
#import "JSONKit.h"
#import "WebServiceParameters.h"
#import "AuthenticationContext.h"
#import "EnumerationContext.h"
#import "SharingOptions.h"

#import "Query.h"

@interface UrlManager : NSObject {
    
}


+ (NSURL*) urlForQuery:(Query*)query 
            withEnumerationContext:(EnumerationContext*)enumerationContext 
         withAuthenticationContext:(AuthenticationContext*)authenticationContext;

+ (NSURL*) urlForUploadAttachment:(NSNumber*)objectid 
                   withObjectType:(NSString*)objectType 
                 forAttributeName:(NSString*)attributeName 
        withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) urlForCreateObjects:(NSArray*)objectids 
               withObjectTypes:(NSArray*)objectTypes 
     withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) urlForPasswordAuthentication:(NSString*)email 
                       withPassword:(NSString*)password
                        withDeviceToken:(NSString*)deviceToken;

+ (NSURL*)urlForCreateUserAccount:(NSString*)email 
                     withPassword:(NSString*)password
                  withDisplayName:(NSString*)displayname
                     withUsername:(NSString*)username 
                  withDeviceToken:(NSString*)deviceToken;

+ (NSURL*) urlForAuthentication:(NSNumber*)facebookID 
                       withName:(NSString*)name
                      withEmail:(NSString*)email
        withFacebookAccessToken:(NSString*)facebookAccessToken 
        withFacebookTokenExpiry:(NSDate*)date
                withDeviceToken:(NSString*)deviceToken;


+ (NSURL*) urlForAuthenticationWithTwitter:(NSNumber*)twitterID 
                           withTwitterName:(NSString*)twitterName
                           withAccessToken:(NSString*)twitterAccessToken
                     withAccessTokenSecret:(NSString*)twitterAccessTokenSecret 
                            withExpiryDate:(NSString*)twitterTokenExpiry
                           withDeviceToken:(NSString*)deviceToken;

+ (NSURL*) urlForPutObject:(NSNumber*)objectid 
            withObjectType:(NSString*)objectType 
 withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) urlForPutObject:(NSNumber*)objectid 
            withObjectType:(NSString*)objectType 
            withAttributes:(NSArray*)attributeNames
       withAttributeValues:(NSArray*)attributeValues
        withOperationCodes:(NSArray*)operationCodes
 withAuthenticationContext:(id)authenticationContext;


+ (NSURL*) urlForUpdateAuthenticatorURL:(NSString *)twitterID 
                              withToken:(NSString *)twitterAccessToken 
                        withTokenSecret:(NSString*)twitterAccessTokenSecret
                             withExpiry:(NSString*)twitterAccessTokenExpiry 
              withAuthenticationContext:(id)context;

+ (NSURL*) urlForUpdateAuthenticatorWithFacebookURL:(NSString *)facebookID 
                              withToken:(NSString *)facebookAccessToken 
                             withExpiry:(NSDate *)facebookAccessTokenExpiry 
              withAuthenticationContext:(id)context;


+ (NSURL*) urlForShareObject:(NSNumber*)objectid 
              withObjectType:(NSString*)objectType 
                 withOptions:(SharingOptions*)sharingOptions 
   withAuthenticationContext:(id)context;

+ (NSURL*) urlForDeleteObject:(NSNumber*)objectid 
               withObjectType:(NSString*)objectType 
    withAuthenticationContext:(id)context;
@end
