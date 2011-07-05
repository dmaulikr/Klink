//
//  BLLog.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "BLLog.h"


@implementation BLLog

+ (void) v : (NSString*)activityName withMessage:(NSString*)message, ... {
    NSLog(@"%@ : %@", activityName,message);
}

+ (void) e : (NSString*)activityName withMessage:(NSString*)message, ... {
    
   
    NSLog(@"%@ : %@", activityName,message);
}
@end
