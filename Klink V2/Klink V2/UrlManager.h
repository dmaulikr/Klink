//
//  UrlManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationSettings.h"
#import "WebServiceVerbs.h"
#import "JSONKit.h"
#import "WebServiceParameters.h"
#import "AuthenticationContext.h"
#import "EnumerationContext.h"
#import "ApplicationSettingsManager.h"
#import "URLEncoding.h"
#import "Query.h"

@interface UrlManager : NSObject {
    
}
+ (NSURL*) getEnumerateURLForIDs:(NSArray*)ids withEnumerationContext:(EnumerationContext*)enumerationContext withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) getUpdateObjectURL:(NSNumber*)objectid withObjectType:(NSString*)objectType withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) getCreateObjectsURL:(NSArray*)objectids withObjectTypes:(NSArray*)objectTypes withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) getEnumerateURLForQuery:(Query*)query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext;

+ (NSURL*) getDeleteURL:(NSNumber*)objectid withObjectType:(NSString*)objectType withAuthenticationContext:(id)authenticationContext;

+ (NSURL*) getUploadAttachmentURL:(NSNumber*)objectid withObjectType:(NSString*)objectType forAttributeName:(NSString*)attributeName withAuthenticationContext:(id)authenticationContext;
@end
