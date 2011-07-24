//
//  NSStringGUIDCategory.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NSStringGUIDCategory.h"


@implementation NSString (NSStringGUIDCategory)
+ (NSString *)GetGUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

- (NSNumber*) numberValue {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber * lastLoggedInUserID = [f numberFromString:self];
    [f release];
    return lastLoggedInUserID;
}
@end
