//
//  GetAuthenticatorResponse.m
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "GetAuthenticatorResponse.h"


@implementation GetAuthenticatorResponse
@synthesize authenticationcontext;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary]; 
    
    if (self != nil) {
        NSDictionary* authenticationContextDictionary = [jsonDictionary objectForKey:an_AUTHENTICATIONCONTEXT];
        self.authenticationcontext = [[AuthenticationContext alloc] initFromDictionary:authenticationContextDictionary];
               
        
    }
    return self;
}

- (void) dealloc {
    [self.authenticationcontext release];
    [super dealloc];
}
@end
