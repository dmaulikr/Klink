//
//  GetAuthenticatorResponse.h
//  Klink V2
//
//  Created by Bobby Gill on 7/22/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "AuthenticationContext.h"
#import "User.h"
@interface GetAuthenticatorResponse : Response {
    AuthenticationContext* m_authenticationcontext;
    User* user;
}
@property (nonatomic,retain) AuthenticationContext* authenticationcontext;
@property (nonatomic,retain) User* user;
@end
