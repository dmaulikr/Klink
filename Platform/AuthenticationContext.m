//
//  AuthenticationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationContext.h"
#import "JSONKit.h"
#import "IJSONSerializable.h"

@implementation AuthenticationContext
@dynamic userid;
@dynamic expirydate;
@dynamic token;
@dynamic facebookaccesstoken;
@dynamic facebookaccesstokenexpirydate;
@dynamic facebookuserid;
@dynamic twitteraccesstoken;
@dynamic twitteruserid;
@dynamic wppassword;
@dynamic wpusername;
@dynamic wordpressurl;



- (BOOL) hasWordpress {
    BOOL retVal = NO;
    
    if (self.wpusername != nil && self.wordpressurl != nil) {
        retVal = YES;
    }
    return retVal;
}

- (BOOL) hasFacebook {
    BOOL retVal = NO;
    
    if (self.facebookuserid != nil && self.facebookaccesstoken != nil) {
        retVal = YES;
    }
    return retVal;
}

- (NSString*) toJSON {
    return nil;
}





@end
