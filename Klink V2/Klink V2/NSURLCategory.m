//
//  NSURLCategory.m
//  Test Project 2
//
//  Created by Bobby Gill on 7/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NSURLCategory.h"


@implementation NSURL (NSURLCategory)
+ (BOOL) isValidURL: (NSString *) candidate {
//    NSString *urlRegEx =
//    @"(http|https)://";
//    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx]; 
//    return [urlTest evaluateWithObject:candidate];

    
    BOOL result = [candidate hasPrefix:@"http"];
    return result;

}

@end
