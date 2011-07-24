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
+ (NSDate*) parseWebServiceDateDouble:(id)datePointer;
+ (NSTimeInterval) convertDateToDouble:(NSDate*)date;
+ (NSString*) formatShortDate:(NSDate*)date;

@end
