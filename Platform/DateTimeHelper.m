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

+ (NSString*) formatMediumDateWithTime:(NSDate*)date includeSeconds:(BOOL)seconds {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    if (seconds) {
        // Returns a string with format like "Dec 1, 2011, 12:00:59 AM"
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    else {
        // Returns a string with format like "Dec 1, 2011, 12:00 AM"
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    return formattedDate;
    
}

+ (NSString*) formatMediumDate:(NSDate*)date {
    // Returns a string with format like "Dec 1, 2011"
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    return formattedDate;
    
}

+ (NSTimeInterval) convertDateToDouble:(NSDate*)date {
    return [date timeIntervalSince1970];
}

+ (NSTimeInterval) convertDatePointerToDouble:(NSNumber*)datePointer {
    NSDate* date = nil;
    date = [DateTimeHelper parseWebServiceDateDouble:datePointer];
    return [DateTimeHelper convertDateToDouble:date];
    [date autorelease];
}

+ (NSDate*) parseWebServiceDateString: (NSString*)dateString {
    return [[[NSDate alloc]init ]autorelease];
}

+ (NSDate*) parseWebServiceDateDouble:(NSNumber*)datePointer {
    NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* dateInSeconds = [f numberFromString:[datePointer stringValue]];
    NSDate* retVal  = [[NSDate alloc] initWithTimeIntervalSince1970:[dateInSeconds doubleValue]];
    [f release];
    [retVal autorelease];
    return retVal;
}

+ (NSString *) formatTimeInterval:(NSTimeInterval)interval {
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date1]; 
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSString* timeRemaining = nil;
    
    if ([breakdownInfo month] > 1) {
        timeRemaining = [NSString stringWithFormat:@"%d months",[breakdownInfo month]];
    }
    else if ([breakdownInfo month] == 1) {
        timeRemaining = [NSString stringWithFormat:@"%d month",[breakdownInfo month]];
    }
    else if ([breakdownInfo day] > 1) {
        timeRemaining = [NSString stringWithFormat:@"%d days",[breakdownInfo day]];
    }
    else if ([breakdownInfo day] == 1) {
        timeRemaining = [NSString stringWithFormat:@"%d day",[breakdownInfo day]];
    }
    else if ([breakdownInfo hour] > 1) {
        timeRemaining = [NSString stringWithFormat:@"%d hrs %d min",[breakdownInfo hour], [breakdownInfo minute]];
    }
    else if ([breakdownInfo hour] == 1) {
        timeRemaining = [NSString stringWithFormat:@"%d hr %d min",[breakdownInfo hour], [breakdownInfo minute]];
    }
    else if ([breakdownInfo minute] > 0) {
        //timeRemaining = [NSString stringWithFormat:@"%d min %d sec",[breakdownInfo minute], [breakdownInfo second]];
        timeRemaining = [NSString stringWithFormat:@"%d minutes",[breakdownInfo minute]];
    }
    else if ([breakdownInfo second] > 0) {
        //timeRemaining = [NSString stringWithFormat:@"%d seconds",[breakdownInfo second]];
        timeRemaining = [NSString stringWithFormat:@"< 1 minute",[breakdownInfo second]];
    }
    else {
        timeRemaining = [NSString stringWithFormat:@"closed!"];
    }
    
    
    
    [date1 release];
    [date2 release];
    return timeRemaining;
}


@end
