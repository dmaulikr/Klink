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
#import "EventManager.h"
#import "AuthenticationManager.h"

@implementation ApplicationSettingsManager
@synthesize resourceContext = m_resourceContext;
@synthesize settings = __settings;
@synthesize applicationSettingsEnumerator = __applicationSettingsEnumerator;
@synthesize onFinishCallback = m_onFinishCallback;

static ApplicationSettingsManager* instance;

#pragma mark - Properties
- (CloudEnumerator*) applicationSettingsEnumerator {
    if (__applicationSettingsEnumerator != nil) {
        return __applicationSettingsEnumerator;
    }
    
    AuthenticationManager* authnManager = [AuthenticationManager instance];
    if ([authnManager isUserAuthenticated]) {
        NSNumber* loggedInUserID = authnManager.m_LoggedInUserID;
        CloudEnumerator* enumerator = [CloudEnumerator enumeratorForApplicationSettings:loggedInUserID];
        __applicationSettingsEnumerator = enumerator;
        __applicationSettingsEnumerator.delegate = self;
        return __applicationSettingsEnumerator;
        
    }
    else {
        return nil;
    }
}
- (ApplicationSettings*) settings {
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* existingSettingsObject = [resourceContext singletonResourceWithType:APPLICATIONSETTINGS];
    if (existingSettingsObject != nil){
        __settings = (ApplicationSettings*)existingSettingsObject;
        return __settings;
    }
    else {
        __settings = [self createDefaultSettingsObject];
        return __settings;
    }

}

- (id) init {
    NSString* activityName = @"ApplicationSettingsManager.init:";
    self = [super init];
    if (self) {
        self.resourceContext = [ResourceContext instance];

        ApplicationSettings* appSettings =(ApplicationSettings*) [self.resourceContext singletonResourceWithType:APPLICATIONSETTINGS];
        
        //let us susbscribe to the LoggedIn events 
        EventManager* eventManager = [EventManager instance];
        Callback* loginCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedIn:)];
        [eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
        [loginCallback release];
        
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

- (void) refreshApplicationSettings:(Callback *)callback {
    //makes a call to the cloud to refresh the local app settings object
    NSString* activityName = @"ApplicationSettings.refreshApplicationSettings:";
    self.onFinishCallback = callback;
    
    LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Beginning to enumerate user's application settings object",activityName);
    
    [self.applicationSettingsEnumerator enumerateUntilEnd:nil];
    
}
#pragma mark - Async Event Handlers
- (void) onEnumerateComplete:(NSDictionary *)userInfo
{
    NSString* activityName = @"ApplicationSettingsManager.onEnumerateComplete:";
    
    LOG_APPLICATIONSETTINGSMANAGER(0,@"%@Finished enumerating user's application settings object",activityName);
    if (self.onFinishCallback != nil) {
        [self.onFinishCallback fire];
    }
}

- (void) onUserLoggedIn:(CallbackResult*)result 
{
    NSString* activityName = @"ApplicationSettingsManager.onUserLoggedIn:";
    LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Detected user login event, refreshing user application settings from the cloud",activityName);
    [self refreshApplicationSettings:nil];
}

//Creates a single default settings object in the store
//Ideally this should never get called unless for somer eason the app
//is unable to pull down settings from the cloud and the local is corrupted/missing
- (ApplicationSettings*) createDefaultSettingsObject {
    ApplicationSettings* settings = (ApplicationSettings*) [Resource createInstanceOfType:APPLICATIONSETTINGS withResourceContext:self.resourceContext];
    //here we need to set up the defaults according to whats in the 
    //ApplicationSettingsDefaults.h file
    //settings.fb_app_id = facebook_APPID;
    settings.base_url = default_BASEURL;
    settings.feed_maxnumtodownload =[NSNumber numberWithInt:maxsize_FEEDDOWNLOAD];
    settings.photo_maxnumtodownload = [NSNumber numberWithInt:maxsize_PHOTODOWNLOAD];
    settings.page_maxnumtodownload = [NSNumber numberWithInt:maxsize_THEMEDOWNLOAD];
    settings.caption_maxnumtodownload = [NSNumber numberWithInt:maxsize_CAPTIONDOWNLOAD];
    settings.numberoflinkedobjectstoreturn = [NSNumber numberWithInt:size_NUMLINKEDOBJECTSTOTRETURN];
    settings.pagesize = [NSNumber numberWithInt:pagesize];
    settings.http_timeout_seconds = [NSNumber numberWithInt:timeout_HTTP];
    settings.feed_enumeration_timegap = [NSNumber numberWithInt:threshold_FEED_ENUMERATION_TIME_GAP];
    settings.caption_enumeration_timegap = [NSNumber numberWithInt:threshold_CAPTION_ENUMERATION_TIME_GAP];
    
   
    
    settings.twitter_consumerkey = twitter_CONSUMERKEY;
    settings.twitter_consumersecret = twitter_CONSUMERSECRET;
    
    settings.page_enumeration_timegap = [NSNumber numberWithInt:threshold_PAGE_ENUMERATION_TIME_GAP];
    settings.page_draftexpiry_seconds = [NSNumber numberWithInt:page_DRAFTEXPIRES_SECONDS];
    settings.version = [NSNumber numberWithInt:0];
    [self.resourceContext save:YES onFinishCallback:nil];
    
    return settings;
}
@end
