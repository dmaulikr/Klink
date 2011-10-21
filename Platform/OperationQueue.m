//
//  OperationQueue.m
//  Platform
//
//  Created by Bobby Gill on 10/19/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "OperationQueue.h"
#import "Macros.h"
#import "ASIHTTPRequest.h"
@implementation OperationQueue

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void) addOperation:(NSOperation *)op {
    NSString* activityName = @"OperationQueue.addOperation:";
    [super addOperation:op];
    
    ASIHTTPRequest* request = (ASIHTTPRequest*)op;
    //write out the url to the log
    LOG_HTTP(0, @"%@Sending HTTP Request:%@",activityName,request.url);
}
@end
