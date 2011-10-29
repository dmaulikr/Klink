//
//  DateTimeHelper.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "DateTimeHelper.h"


@implementation DateTimeHelper

+ (NSString*) formatDateForWebService:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    return formattedDate;

}

+ (NSString*) formatShortDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    return formattedDate;

}

+ (NSTimeInterval) convertDateToDouble:(NSDate*)date {
    return [date timeIntervalSince1970];
}
+ (NSDate*) parseWebServiceDateString: (NSString*)dateString {
    return [[[NSDate alloc]init ]autorelease];
}

+ (NSDate*) parseWebServiceDateDouble:(id)datePointer {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * dateInSeconds = [f numberFromString:datePointer];
    NSDate* retVal  = [[NSDate alloc] initWithTimeIntervalSince1970:[dateInSeconds doubleValue]];
    [retVal autorelease];
    return retVal;
}



@end
