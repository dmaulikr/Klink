//
//  Response.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Response.h"


@implementation Response
@synthesize didSucceed;
@synthesize errorCode;
@synthesize errorMessage;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName =@"Response.initFromDictionary: ";
    
    //Mandatory
    self.didSucceed = [jsonDictionary objectForKey:an_DIDSUCCEED] ;
    
    //Optional
    self.errorMessage = [jsonDictionary objectForKey:an_ERRORMESSAGE];
    self.errorCode = [jsonDictionary objectForKey:an_ERRORCODE];

    NSString* message = nil;
    
    if ([self.errorCode intValue]==0) {
        message = [[NSString alloc] initWithFormat:@"Created with: didSucceed=%@", self.didSucceed];
        
        //[BLLog v:activityName withMessage:message];
    }
    else {
        message = [[NSString alloc] initWithFormat:@"Created with: didSucceed=%@, errorCode=%@, errorMessage=%@", didSucceed,errorCode,errorMessage];
        
       // [BLLog e:activityName withMessage:message];
    }
   
    
    [message release];
    return self;
}



@end
