//
//  AuthenticationManager.m
//  Platform
//
//  Created by Bobby Gill on 10/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationManager.h"


static  AuthenticationManager* sharedManager;

@implementation AuthenticationManager

- (AuthenticationContext*) contextForLoggedInUser {
    //TODO implement authentication manager methods;
    return nil;
}
+ (id) instance {
    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        }
        return sharedManager;
    }
}
@end
