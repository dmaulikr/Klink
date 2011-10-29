//
//  ApplicationSettingsManager.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ApplicationSettingsManager.h"
#import "Types.h"
#import "Resource.h"
#import "ApplicationSettingsDefaults.h"
#import "Macros.h"

@implementation ApplicationSettingsManager
@synthesize resourceContext = m_resourceContext;
@synthesize settings = __settings;



static ApplicationSettingsManager* instance;

#pragma mark - Properties
- (ApplicationSettings*) settings {
    if (__settings != nil) {
        return __settings;
    }
    __settings = [self createDefaultSettingsObject];
    return __settings;
}

- (id) init {
    NSString* activityName = @"ApplicationSettingsManager.init:";
    self = [super init];
    if (self) {
        self.resourceContext = [ResourceContext instance];
        ApplicationSettings* appSettings =(ApplicationSettings*) [self.resourceContext singletonResourceWithType:APPLICATIONSETTINGS];
        if (appSettings != nil) {
            self.settings = appSettings;
        }
        else {
            LOG_CONFIGURATION(0,@"@%Could not load saved settings object, will need to create default",activityName);
        }
    }
    return self;
}

+ (id) instance {
    @synchronized (self) {
        if (!instance) {
            instance = [[super allocWithZone:NULL]init];
        }
        return instance;
    }
}



//Creates a single default settings object in the store
//Ideally this should never get called unless for somer eason the app
//is unable to pull down settings from the cloud and the local is corrupted/missing
- (ApplicationSettings*) createDefaultSettingsObject {
    ApplicationSettings* settings = (ApplicationSettings*) [Resource createInstanceOfType:APPLICATIONSETTINGS withResourceContext:self.resourceContext];
    //here we need to set up the defaults according to whats in the 
    //ApplicationSettingsDefaults.h file
    settings.fb_app_id = facebook_APPID;
    settings.base_url = default_BASEURL;
    settings.feed_maxnumtodownload =[NSNumber numberWithInt:maxsize_FEEDDOWNLOAD];
    settings.photo_maxnumtodownload = [NSNumber numberWithInt:maxsize_PHOTODOWNLOAD];
    settings.page_maxnumtodownload = [NSNumber numberWithInt:maxsize_THEMEDOWNLOAD];
    settings.caption_maxnumtodownload = [NSNumber numberWithInt:maxsize_CAPTIONDOWNLOAD];
    settings.numberoflinkedobjectstoreturn = [NSNumber numberWithInt:size_NUMLINKEDOBJECTSTOTRETURN];
    settings.pagesize = [NSNumber numberWithInt:pageSize_PHOTO];
    settings.http_timeout_seconds = [NSNumber numberWithInt:timeout_HTTP];
    settings.feed_enumeration_timegap = [NSNumber numberWithInt:threshold_FEED_ENUMERATION_TIME_GAP];
    settings.caption_enumeration_timegap = [NSNumber numberWithInt:threshold_CAPTION_ENUMERATION_TIME_GAP];
    
    settings.page_size_linkedobjects = [NSNumber numberWithInt:page_size_LINKEDOBJECTS];
    
    
    settings.page_enumeration_timegap = [NSNumber numberWithInt:threshold_PAGE_ENUMERATION_TIME_GAP];
    [self.resourceContext save:YES onFinishCallback:nil];
    
    return settings;
}
@end
