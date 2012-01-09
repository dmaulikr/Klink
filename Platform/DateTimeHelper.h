//
//  DateTimeHelper.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateTimeHelper : NSObject {
    
}

+ (NSString*) formatDateForWebService:(NSDate*)date;
+ (NSDate*) parseWebServiceDateString: (NSString*)dateString;
+ (NSDate*) parseWebServiceDateDouble:(NSNumber*)datePointer;
+ (NSTimeInterval) convertDateToDouble:(NSDate*)date;
+ (NSTimeInterval) convertDatePointerToDouble:(NSNumber*)datePointer;
+ (NSString*) formatShortDate:(NSDate*)date;
+ (NSString*) formatMediumDateWithTime:(NSDate*)date includeSeconds:(BOOL)seconds;
+ (NSString*) formatMediumDate:(NSDate*)date;
+ (NSString *) formatTimeInterval:(NSTimeInterval)interval;

@end
