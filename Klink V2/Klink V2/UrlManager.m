//
//  UrlManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UrlManager.h"


@implementation UrlManager

+ (NSURL*) getShareCaptionURL:(NSNumber*)captionID withOptions:(SharingOptions *)sharingOptions  withAuthenticationContext:(id)authenticationContext {
    NSString* verbName = verb_SHARECAPTION;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* captionIDParamName = param_OBJECTID;
    NSString* sharingOptionsIDParamName = param_SHARINGOPTIONS;
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    NSString* jsonSharingOptions = [sharingOptions toJSON];
   
    [parameters appendFormat:@"%@=%@",captionIDParamName,captionID];
    [parameters appendFormat:@"&%@=%@",sharingOptionsIDParamName, jsonSharingOptions];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease];
    [parameters release];
    return url;

}

+ (NSURL*) getUploadAttachmentURL:(NSNumber*)objectid withObjectType:(NSString*)objectType forAttributeName:(NSString*)attributeName withAuthenticationContext:(id)authenticationContext {
    NSString* verbName = verb_UPLOADATTACHMENT;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    NSString* objectTypeParamName = param_OBJECTTYPE;
    NSString* attributeNameParamName = param_ATTRIBUTENAME;
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    [parameters appendFormat:@"&%@=%@",attributeNameParamName,attributeName];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

}

+ (NSURL*) getDeleteURL:(NSNumber*)objectid withObjectType:(NSString*)objectType withAuthenticationContext:(id)authenticationContext {
    
    NSString* verbName = verb_DELETE;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    NSString* objectTypeParamName = param_OBJECTTYPE;
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;
}

+ (NSURL*) getEnumerateURLForQuery:(Query*)query withEnumerationContext:(EnumerationContext*)enumerationContext withAuthenticationContext:(AuthenticationContext*)authenticationContext {
    NSString* verbName = verb_ENUMERATE;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* queryJSON = [query toJSON];
    
    NSString* queryParameterName = param_QUERY;
    [parameters appendFormat:@"%@=%@",queryParameterName,queryJSON];
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* enumerationContextParameterName = param_ENUMERATIONCONTEXT;
    
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    NSString* jsonEnumerationContext = [enumerationContext toJSON];
    [parameters appendFormat:@"&%@=%@",enumerationContextParameterName,jsonEnumerationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc] initWithString:escapedURL]autorelease]; ;
    
    [parameters release];
    return url;

    
}

+ (NSURL*) getEnumerateURLForIDs:(NSArray*)ids withEnumerationContext:(EnumerationContext*)enumerationContext withAuthenticationContext:(AuthenticationContext*)authenticationContext {
        
    NSString* verbName = verb_ENUMERATEWITHIDS;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    NSString* idsParameterName = param_QUERY;
    
    Query* query = [[Query alloc]initWithIds:ids];
    NSString* jsonIDString = [query toJSON];
    
    [parameters appendFormat:@"%@=%@",idsParameterName,jsonIDString];
    
    NSString* authenticationContextParameterName = param_AUTHENTICATIONCONTEXT;
    NSString* enumerationContextParameterName = param_ENUMERATIONCONTEXT;
    
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];

    
    NSString* jsonEnumerationContext = nil;
    
    [parameters appendFormat:@"&%@=%@",authenticationContextParameterName,jsonAuthenticationContext];
    
    if (enumerationContext != nil) {
        enumerationContext.maximumNumberOfResults =[NSNumber numberWithUnsignedInt:[ids count]];
        jsonEnumerationContext = [enumerationContext toJSON];
        [parameters appendFormat:@"&%@=%@",enumerationContextParameterName,jsonEnumerationContext];
    }
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[NSURL alloc] initWithString:escapedURL] ;
    
    [parameters release];
    [query release];
    return url;
}

+ (NSURL*) getUpdateObjectURL:(NSNumber*)objectid withObjectType:(NSString*)objectType withAuthenticationContext:(id)authenticationContext {
    NSString* verbName = verb_UPDATEOBJECT;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTID;
    [parameters appendFormat:@"%@=%@",objectIDParamName,objectid];
    
    NSString* objectTypeParamName = param_OBJECTTYPE;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,objectType];
    
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

}

+ (NSURL*) getCreateObjectsURL:(NSArray*)objectids withObjectTypes:(NSArray*)objectTypes withAuthenticationContext:(id)authenticationContext {
    
    NSString* verbName = verb_CREATEOBJECT;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectIDParamName = param_OBJECTIDS;
    [parameters appendFormat:@"%@=%@",objectIDParamName,[objectids JSONString]];
    
    NSString* objectTypeParamName = param_OBJECTTYPES;
    [parameters appendFormat:@"&%@=%@",objectTypeParamName,[objectTypes JSONString]];
    
    
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [authenticationContext toJSON];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    
    [parameters release];
    return url;

}

+ (NSURL*) getAuthenticationURL:(NSNumber*)facebookID withName:(NSString*)name withFacebookAccessToken:(NSString*)facebookAccessToken withFacebookTokenExpiry:(NSDate*)date {
    
    NSString* verbName = verb_GETAUTHENTICATOR;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    double expiryDateInEpochSeconds = [date timeIntervalSince1970];
    
     NSString* facebookIDParamName = param_FACEBOOKID;
     [parameters appendFormat:@"%@=%@",facebookIDParamName,[facebookID stringValue]];
     NSString* displayNameParamName = param_DISPLAYNAME;
     [parameters appendFormat:@"&%@=%@",displayNameParamName,name];
     NSString* facebookAccessTokenParamName = param_FACEBOOKACCESSTOKEN;
    [parameters appendFormat:@"&%@=%@",facebookAccessTokenParamName,facebookAccessToken];
     NSString* facebookAccessTokenExpiryParamName = param_FACEBOOKACCESSTOKENEXPIRY;
    [parameters appendFormat:@"&%@=%f",facebookAccessTokenExpiryParamName,expiryDateInEpochSeconds];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    return url;
}

+ (NSURL*) getUpdateAttributeURL:(NSNumber*)objectid 
                                withObjectType:(NSString*)objectType 
                                forAttribute:(NSString*)attributeName 
                                withOperationCode:(int)operationCode 
                                byValue:(NSString*)value
                                withAuthenticationContext:(id)context{
   
    NSString* verbName = verb_UPDATEATTRIBUTE;
    NSString* baseURL = [ApplicationSettingsManager getBaseURL];
    NSMutableString *parameters = [[NSMutableString alloc] initWithFormat:@"%@/%@?",baseURL,verbName] ;
    
    NSString* objectidParamName = param_OBJECTID;
    NSString* objecttypeParamName = param_OBJECTTYPE;
    NSString* attributenameParamName = param_ATTRIBUTENAME;
    NSString* valueParamName = param_VALUE;
    NSString* operationCodeParamName = param_OPCODE;
    NSString* authenticationContextParamName = param_AUTHENTICATIONCONTEXT;
    NSString* jsonAuthenticationContext = [context toJSON];
    [parameters appendFormat:@"%@=%@",objectidParamName,objectid];
    [parameters appendFormat:@"&%@=%@",objecttypeParamName,objectType];
    [parameters appendFormat:@"&%@=%@",attributenameParamName,attributeName];
    [parameters appendFormat:@"&%@=%@",valueParamName,value];
    [parameters appendFormat:@"&%@=%d",operationCodeParamName,operationCode];
    [parameters appendFormat:@"&%@=%@",authenticationContextParamName,jsonAuthenticationContext];
    
    NSString* escapedURL = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [[[NSURL alloc]initWithString:escapedURL]autorelease];
    return url;
    
    
}

@end
