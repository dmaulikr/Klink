//
//  WebServiceVerbs.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "WebServiceVerbs.h"


NSString* const verb_ENUMERATEWITHIDS = @"Objects/EnumerateByID";
NSString* const verb_UPDATEOBJECT=@"Objects/Put";
NSString* const verb_CREATEOBJECT=@"Objects/Create";
NSString* const verb_ENUMERATE=@"Objects/Enumerate";
NSString* const verb_DELETE=@"Objects/Delete";
NSString* const verb_UPLOADATTACHMENT = @"Objects/PutAttachment";
NSString* const verb_GETAUTHENTICATOR = @"Objects/Users/GetAuthenticator";
NSString* const verb_GETAUTHENTICATORWITHPASSWORD = @"Objects/Users/GetAuthenticatorWithUsername";
NSString* const verb_UPDATEATTRIBUTE = @"Objects/PutAttribute";
NSString* const verb_SHARE = @"Objects/Share";
NSString* const verb_UPDATEAUTHENTICATOR = @"Objects/Users/Authenticator/Put";
NSString* const verb_UPDATEOBJECTATTRIBUTES=@"Objects/PutAttributes";
NSString* const verb_CREATEUSERAUTHENTICATE = @"Objects/Users/Create";
NSString* const verb_GETAUTHENTICATORWITHTWITTER = @"Objects/Users/GetAuthenticatorWithTwitter";