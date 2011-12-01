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


+ (NSURL*) urlForAuthentication:(NSNumber*)facebookID 
                       withName:(NSString*)name 
        withFacebookAccessToken:(NSString*)facebookAccessToken 
        withFacebookTokenExpiry:(NSDate*)date;

+ (NSURL*) urlForPutObject:(NSNumber*)objectid 
            withObjectType:(NSString*)objectType 
 withAuthenticationContext:(id)authenticationContext;


+ (NSURL*) urlForUpdateAuthenticatorURL:(NSString *)twitterID 
                              withToken:(NSString *)twitterAccessToken 
                        withTokenSecret:(NSString*)twitterAccessTokenSecret
                             withExpiry:(NSString*)twitterAccessTokenExpiry 
              withAuthenticationContext:(id)context; 


+ (NSURL*) urlForShareObject:(NSNumber*)objectid 
              withObjectType:(NSString*)objectType 
                 withOptions:(SharingOptions*)sharingOptions 
   withAuthenticationContext:(id)context;
@end
