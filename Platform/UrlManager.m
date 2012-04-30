//
//  UrlManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UrlManager.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "NSStringGUIDCategory.h"


@implementation UrlManager


+ (NSURL*) urlForQuery:(Query*)query withEnumerationContext:(EnumerationContext*)enumerationContext withAuthenticationContext:(AuthenticationContext*)authenticationContext {
    
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance]settings];
    
    NSString* verbName = verb_ENUMERATE;
    NSString* baseURL = settingsObject.base_url;
    
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* queryJSON = [query toJSON];
    
    NSString* queryParameterName = param_QUERY;
    [parameters appendFormat:@"%@=%@",queryParameterName,queryJSON];
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* enumerationContextParameterName = param_ENUMERATIONCONTEXT;
    
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* jsonEnumerationContext = [enumerationContext toJSON];
    [parameters appendFormat:@"&%@=%@",enumerationContextParameterName,jsonEnumerationContext];

    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease]; ;
    
    [parameters release];
    return url;

    
}

+ (NSURL*) urlForUploadAttachment:(NSNumber*)objectid withObjectType:(NSString*)objectType forAttributeName:(NSString*)attributeName withAuthenticationContext:(id)authenticationContext {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* baseURL = settingsObject.base_url;

    NSString* verbName = verb_UPLOADATTACHMENT;
       
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    NSString* objectTypeParamName = param_OBJECTTYPE;
    NSString* attributeNameParamName = param_ATTRIBUTENAME;
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    [parameters appendFormat:@"&%@=%@",attributeNameParamName,attributeName];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;
    
}



+ (NSURL*) urlForCreateObjects:(NSArray*)objectids 
               withObjectTypes:(NSArray*)objectTypes 
     withAuthenticationContext:(id)authenticationContext {
    
    NSString* verbName = verb_CREATEOBJECT;
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTIDS;
    [parameters appendFormat:@"%@=%@",objectIDParamName,[objectids JSONString]];
    
    NSString* objectTypeParamName = param_OBJECTTYPES;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,[objectTypes JSONString]];
    
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;
    
}

+ (NSURL*) urlForUpdateAuthenticatorWithFacebookURL:(NSString *)facebookID 
                                          withToken:(NSString *)facebookAccessToken 
                                         withExpiry:(NSDate *)facebookAccessTokenExpiry 
                          withAuthenticationContext:(id)context
{
    NSString* verbName = verb_UPDATEAUTHENTICATOR;
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* baseURL = settingsObject.base_url;
    
    double expiryDateInEpochSeconds = [facebookAccessTokenExpiry timeIntervalSince1970];
    
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* twitterUserIdParamName = param_FACEBOOKID;
    NSString* twitterAccessTokenParamName = param_FACEBOOKACCESSTOKEN;
    NSString* twitterTokenExpiryName = param_FACEBOOKACCESSTOKENEXPIRY;
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [context toJSON];
    jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    
    [parameters appendFormat:@"%@=%@",twitterUserIdParamName,facebookID];
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenParamName,facebookAccessToken];
    [parameters appendFormat:@"&%@=%f",twitterTokenExpiryName,expiryDateInEpochSeconds];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    [parameters release];
    return url;
}

+ (NSURL*) urlForPasswordAuthentication:(NSString*)email 
                           withPassword:(NSString*)password
                        withDeviceToken:(NSString*)deviceToken
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    
    NSString* verbName = verb_GETAUTHENTICATORWITHPASSWORD;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    
    
    NSString* emailParamName = param_EMAIL;
    [parameters appendFormat:@"%@=%@",emailParamName,email];
    NSString* passwordParamName = param_PASSWORD;
    [parameters appendFormat:@"&%@=%@",passwordParamName,password];    
    NSString* deviceTokenParamName = param_DEVICETOKEN;
    [parameters appendFormat:@"&%@=%@",deviceTokenParamName,deviceToken];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

}

+ (NSURL*) urlForCreateUserAccount:(NSString *)email 
                      withPassword:(NSString *)password
                   withDisplayName:(NSString *)displayName
                      withUsername:(NSString *)username 
                   withDeviceToken:(NSString *)deviceToken
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* verbName = verb_CREATEUSERAUTHENTICATE;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* emailParamName = param_EMAIL;
    [parameters appendFormat:@"%@=%@",emailParamName,email];
    
    NSString* passwordParamName = param_PASSWORD;
    [parameters appendFormat:@"&%@=%@",passwordParamName,password];
    
    NSString* displayNameParamName = param_DISPLAYNAME;
    [parameters appendFormat:@"&%@=%@",displayNameParamName,displayName];
    
    NSString* usernameParamName = param_USERNAME;
    [parameters appendFormat:@"&%@=%@",usernameParamName,username];
    
    NSString* deviceTokenParamName = param_DEVICETOKEN;
    [parameters appendFormat:@"&%@=%@",deviceTokenParamName,deviceToken];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

    
    
}


+ (NSURL*) urlForAuthenticationWithTwitter:(NSNumber*)twitterID 
                           withTwitterName:(NSString*)twitterName
                           withAccessToken:(NSString*)twitterAccessToken
                     withAccessTokenSecret:(NSString*)twitterAccessTokenSecret 
                            withExpiryDate:(NSString*)twitterTokenExpiry
                           withDeviceToken:(NSString*)deviceToken
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    
    NSString* verbName = verb_GETAUTHENTICATORWITHTWITTER;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    
    
    NSString* twitterIDParamName = param_TWITTERUSERID;
    [parameters appendFormat:@"%@=%@",twitterIDParamName,[twitterID stringValue]];
    NSString* twitterNameParamName = param_TWITTERNAME;
    [parameters appendFormat:@"&%@=%@",twitterNameParamName,twitterName];
    NSString* twitterAccessTokenParamName = param_TWITTERACCESSTOKEN;
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenParamName,twitterAccessToken];
    NSString* twitterAccessTokenSecretParamName = param_TWITTERACCESSTOKENSECRET;
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenSecretParamName,twitterAccessTokenSecret];
    NSString* twitterAccessTokenExpiryParamName = param_TWITTERACCESSTOKENEXPIRY;
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenExpiryParamName,twitterTokenExpiry];
    NSString* deviceTokenParamName = param_DEVICETOKEN;
    [parameters appendFormat:@"&%@=%@",deviceTokenParamName,deviceToken];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;
    
}

+ (NSURL*) urlForAuthentication:(NSNumber *)facebookID 
                       withName:(NSString *)name 
                      withEmail:(NSString*)email
        withFacebookAccessToken:(NSString *)facebookAccessToken 
        withFacebookTokenExpiry:(NSDate *)date 
                withDeviceToken:(NSString *)deviceToken {
    
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    
    NSString* verbName = verb_GETAUTHENTICATOR;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    double expiryDateInEpochSeconds = [date timeIntervalSince1970];
    
    NSString* facebookIDParamName = param_FACEBOOKID;
    [parameters appendFormat:@"%@=%@",facebookIDParamName,[facebookID stringValue]];
    NSString* displayNameParamName = param_DISPLAYNAME;
    [parameters appendFormat:@"&%@=%@",displayNameParamName,name];
    NSString* emailParamName = param_EMAIL;
    [parameters appendFormat:@"&%@=%@",emailParamName,email];
    NSString* facebookAccessTokenParamName = param_FACEBOOKACCESSTOKEN;
    [parameters appendFormat:@"&%@=%@",facebookAccessTokenParamName,facebookAccessToken];
    NSString* facebookAccessTokenExpiryParamName = param_FACEBOOKACCESSTOKENEXPIRY;
    [parameters appendFormat:@"&%@=%f",facebookAccessTokenExpiryParamName,expiryDateInEpochSeconds];
    NSString* deviceTokenParamName = param_DEVICETOKEN;
    [parameters appendFormat:@"&%@=%@",deviceTokenParamName,deviceToken];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

    
}

+ (NSURL*) urlForUpdateAuthenticatorURL:(NSString *)twitterID 
                           withToken:(NSString *)twitterAccessToken 
                     withTokenSecret:(NSString*)twitterAccessTokenSecret
                          withExpiry:(NSString*)twitterAccessTokenExpiry 
           withAuthenticationContext:(id)context {
    
    NSString* verbName = verb_UPDATEAUTHENTICATOR;
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* baseURL = settingsObject.base_url;
    
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* twitterUserIdParamName = param_TWITTERUSERID;
    NSString* twitterAccessTokenParamName = param_TWITTERACCESSTOKEN;
    NSString* twitterAccessTokenSecretParamName = param_TWITTERACCESSTOKENSECRET;
    NSString* twitterTokenExpiryName = param_TWITTERACCESSTOKENEXPIRY;
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [context toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    
    [parameters appendFormat:@"%@=%@",twitterUserIdParamName,twitterID];
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenParamName,twitterAccessToken];
    [parameters appendFormat:@"&%@=%@",twitterAccessTokenSecretParamName,twitterAccessTokenSecret];
    [parameters appendFormat:@"&%@=%@",twitterTokenExpiryName,twitterAccessTokenExpiry];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    [parameters release];
    return url;
}

+ (NSURL*) urlForPutObject:(NSNumber*)objectid 
            withObjectType:(NSString*)objectType 
 withAuthenticationContext:(id)authenticationContext {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];

    NSString* verbName = verb_UPDATEOBJECT;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    
    NSString* objectTypeParamName = param_OBJECTTYPE;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;
    
}


+ (NSURL*)urlForPutObject:(NSNumber*)objectid 
           withObjectType:(NSString*)objectType 
           withAttributes:(NSArray*)attributeNames
      withAttributeValues:(NSArray*)attributeValues
       withOperationCodes:(NSArray*)operationCodes
withAuthenticationContext:(id)authenticationContext; 
{
 
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    
    NSString* verbName = verb_UPDATEOBJECTATTRIBUTES;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
       
    NSString* jsonAttributeNames = [attributeNames JSONString];
    NSString* jsonAttributeValues = [attributeValues JSONString];
    NSString* jsonOperationCodes = [operationCodes JSONString];
      
    NSString* objectIDParamName = param_OBJECTID;
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    
    NSString* objectTypeParamName = param_OBJECTTYPE;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];

    NSString* attributesParamName = param_ATTRIBUTENAMES;
    [parameters appendFormat:@"&%@=%@",attributesParamName,jsonAttributeNames];
    
    NSString* attributesValuesParamName = param_ATTRIBUTEVALUES;
    [parameters appendFormat:@"&%@=%@",attributesValuesParamName,jsonAttributeValues];
    
    NSString* operationCodesParamName = param_OPERATIONCODE;
    [parameters appendFormat:@"&%@=%@",operationCodesParamName,jsonOperationCodes];
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;


}

+ (NSURL*) urlForShareObject:(NSNumber *)objectid 
              withObjectType:(NSString *)objectType 
                 withOptions:(SharingOptions *)sharingOptions 
   withAuthenticationContext:(id)authenticationContext {
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* verbName = verb_SHARE;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* captionIDParamName = param_OBJECTID;
    NSString* sharingOptionsIDParamName = param_SHARINGOPTIONS;
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
     jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    
    NSString* jsonSharingOptions = [sharingOptions toJSON];
    
    [parameters appendFormat:@"%@=%@",captionIDParamName,objectid];
    [parameters appendFormat:@"&%@=%@",sharingOptionsIDParamName, jsonSharingOptions];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease];
    [parameters release];
    return url;

}



+ (NSURL*) urlForDeleteObject:(NSNumber*)objectid 
               withObjectType:(NSString*)objectType 
    withAuthenticationContext:(id)context
{
    ApplicationSettings* settingsObject = [[ApplicationSettingsManager instance] settings];
    NSString* verbName = verb_DELETE;
    NSString* baseURL = settingsObject.base_url;
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    
    NSString* objectTypeParamName = param_OBJECTTYPE;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [context toJSON];
    
    jsonAuthenticationContext = [jsonAuthenticationContext encodeString:NSUTF8StringEncoding];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

}








@end
