//
//  AuthenticationManager.h
//  Platform
//
//  Created by Bobby Gill on 10/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationContext.h"

@interface AuthenticationManager : NSObject {
    
}

+ (id) instance;
- (AuthenticationContext*) contextForLoggedInUser;
@end
