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
@implementation GetAuthenticatorResponse
@synthesize authenticationcontext;
@synthesize user;


- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromJSONDictionary:jsonDictionary]; 
    
    if (self != nil) {
        NSDictionary* authenticationContextDictionary = [jsonDictionary objectForKey:AUTHENTICATIONCONTEXT];
        self.authenticationcontext = [AuthenticationContext createInstanceOfAuthenticationContextFromJSON:authenticationContextDictionary];
        
        
        
        NSDictionary* userDictionary = [jsonDictionary valueForKey:an_USER];
        if (userDictionary != nil) {
            self.user = [Resource createInstanceOfTypeFromJSON:userDictionary];
        }
        else {
            //TODO: log an error for missing user object on get authenticator response object
        }
    }
    return self;
}



- (void) dealloc {
    [self.authenticationcontext release];
    [self.user release];
    [super dealloc];
}
@end
