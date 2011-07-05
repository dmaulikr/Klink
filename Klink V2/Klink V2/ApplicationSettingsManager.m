//
//  ApplicationSettingsManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ApplicationSettingsManager.h"


@implementation ApplicationSettingsManager

+ (NSString*) getBaseURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* baseURL = [defaults stringForKey:stng_BASEURL];
    
    if (baseURL == nil) {
        return default_BASEURL;
    }
    else {
        return baseURL;
    }
}
@end
