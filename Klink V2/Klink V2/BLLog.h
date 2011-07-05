//
//  BLLog.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BLLog : NSObject {
   
}
 + (void) v : (NSString*)activityName withMessage:(NSString*)format, ...;
 + (void) e : (NSString*)activityName withMessage:(NSString*)format, ...;
@end
