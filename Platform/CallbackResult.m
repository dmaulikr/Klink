//
//  CallbackResult.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CallbackResult.h"
#import "Callback.h"

@implementation CallbackResult
@synthesize context = m_context;
@synthesize response = m_response;

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
+ (CallbackResult*) resultForCallback:(Callback*)callback {
    //returns a callbackresult object generated for the specific callback objects
    CallbackResult* retVal = [[[CallbackResult alloc]init]autorelease];
    retVal.context = callback.context;
    return retVal;
}
@end

