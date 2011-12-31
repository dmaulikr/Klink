//
//  Caption.m
//  Platform
//
//  Created by Bobby Gill on 10/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Caption.h"
#import "AuthenticationManager.h"
#import "User.h"

@implementation Caption
@dynamic caption1;
@dynamic creatorid;
@dynamic creatorname;
@dynamic numberofvotes;
@dynamic photoid;
@dynamic hasvoted;  

+ (Caption*)createCaptionForPhoto:(NSNumber *)photoid withCaption:(NSString *)caption {
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];    
    ResourceContext* resourceContext = [ResourceContext instance];
    Caption* retVal = (Caption*)[Resource createInstanceOfType:CAPTION withResourceContext:resourceContext];
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    if (user != nil) {
        retVal.creatorid = user.objectid;
        retVal.creatorname = user.username;
    }
    retVal.caption1 = caption;
    retVal.photoid = photoid;
    
    retVal.numberofvotes = [NSNumber numberWithInt:0];

    return retVal;

}
@end
