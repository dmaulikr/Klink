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

+ (NSString*) formatMediumDateWithTime:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
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

+ (NSDate*) parseWebServiceDateDouble:(NSNumber*)datePointer {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * dateInSeconds = [f numberFromString:[datePointer stringValue]];
    NSDate* retVal  = [[NSDate alloc] initWithTimeIntervalSince1970:[dateInSeconds doubleValue]];
    [retVal autorelease];
    return retVal;
}


+ (NSString *) formatTimeInterval:(NSTimeInterval)interval {
    unsigned long seconds = interval;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;
    
    NSMutableString * result = [[NSMutableString new] autorelease];
    
    if(hours)
        [result appendFormat: @"%d:", hours];
    
    [result appendFormat: @"%02:", minutes];
    [result appendFormat: @"%02", seconds];
    
    return result;
}


@end
