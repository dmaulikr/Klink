//
//  Response.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Response.h"
#import "Attributes.h"
#import "JSONKit.h"


@implementation Response
@synthesize didSucceed = m_didSucceed;
@synthesize errorCode  = m_errorCode;
@synthesize errorMessage = m_errorMessage;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary {
   
    
    //Mandatory
    self.didSucceed = [jsonDictionary valueForKey:DIDSUCCEED] ;
    
    //Optional
    self.errorMessage = [jsonDictionary valueForKey:ERRORMESSAGE];
    self.errorCode = [jsonDictionary valueForKey:ERRORCODE];

    
    return self;
}

- (NSString*)toJSON {
    NSString* retVal = nil;
    NSMutableDictionary* jsonDictionary = [[[NSMutableDictionary alloc]init]autorelease];
    [jsonDictionary setValue:self.didSucceed forKey:DIDSUCCEED];
    [jsonDictionary setValue:self.errorMessage forKey:ERRORMESSAGE];
    [jsonDictionary setValue:self.errorCode forKey:ERRORCODE];
    retVal = [jsonDictionary JSONString];
    return retVal;
}



@end
