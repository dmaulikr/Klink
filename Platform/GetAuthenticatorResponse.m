//
//  GetAuthenticatorResponse.m
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "GetAuthenticatorResponse.h"
#import "Attributes.h"
#import "Types.h"
#import "ResourceContext.h"
#import "AuthenticationContext.h"
#import "Macros.h"

@implementation GetAuthenticatorResponse
@synthesize authenticationcontext = m_authenticationcontext;
@synthesize user;


- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"GetAuthenticatorResponse.initFromJSONDictionary:";
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil) {
        NSDictionary* authenticationContextDictionary = [jsonDictionary objectForKey:AUTHENTICATIONCONTEXT];
        self.authenticationcontext = [AuthenticationContext createInstanceOfAuthenticationContextFromJSON:authenticationContextDictionary];
        
               
        NSDictionary* userDictionary = [jsonDictionary valueForKey:an_USER];
        if (userDictionary != nil) {
            self.user = [Resource createInstanceOfTypeFromJSON:userDictionary];
        }
        else {
        
            LOG_RESPONSE(1,@"%@Missing user object on authenticator response object",activityName);
        }
    }
    return self;
}



- (void) dealloc {
  //  [self.authenticationcontext release];
    //[self.user release];
    [super dealloc];
}
@end
