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
@synthesize settings = m_settings;
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
//- (ApplicationSettings*) settings {
//    ResourceContext* resourceContext = [ResourceContext instance];
//    Resource* existingSettingsObject = [resourceContext singletonResourceWithType:APPLICATIONSETTINGS];
//    if (existingSettingsObject != nil){
//        __settings = (ApplicationSettings*)existingSettingsObject;
//        return __settings;
//    }
//    else {
//        __settings = [self createDefaultSettingsObject];
//        return __settings;
//    }
//
//}

///This method will go through the entire application settings object and ensure that
///its attribute meta data is not malformed, such that the app always will be able to receive
///new settings from the server
- (void) verifyAndUnlockAllAttributes 
{    
    if (self.settings != nil) {
        ResourceContext* resourceContext = [ResourceContext instance];
        [self.settings resetAttributeInstanceDataToDefault];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
}

- (id) init {
    NSString* activityName = @"ApplicationSettingsManager.init:";
    self = [super init];
    if (self) {
        ResourceContext* resourceContext = [ResourceContext instance];
        ApplicationSettings* appSettings =(ApplicationSettings*) [resourceContext singletonResourceWithType:APPLICATIONSETTINGS];
                   
        //let us susbscribe to the LoggedIn events 
        EventManager* eventManager = [EventManager instance];
        Callback* loginCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onUserLoggedIn:)];
        [eventManager registerCallback:loginCallback forSystemEvent:kUSERLOGGEDIN];
        [loginCallback release];
        
        if (appSettings != nil) {
            self.settings = appSettings;
//            [self verifyAndUnlockAllAttributes];
            
        }
        else {
            LOG_CONFIGURATION(0,@"@%Could not load saved settings object, will need to create default",activityName);
            self.settings = [self createDefaultSettingsObject];
            //[self verifyAndUnlockAllAttributes];
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
    
   
    if (![self.applicationSettingsEnumerator isLoading]) 
    {
        LOG_APPLICATIONSETTINGSMANAGER(0, @"%@Beginning to enumerate user's application settings object",activityName);
        [self.applicationSettingsEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        LOG_APPLICATIONSETTINGSMANAGER(0, @"%Skipping enumerating user's application settings object as the enumerator is busy",activityName);
    }
    
}
#pragma mark - Async Event Handlers
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
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
    ResourceContext* context = [ResourceContext instance];
    ApplicationSettings* settings = (ApplicationSettings*) [Resource createInstanceOfType:APPLICATIONSETTINGS withResourceContext:context];
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
    settings.progress_maxsecondstodisplay = [NSNumber numberWithInt:progress_MAXSECONDSTODISPLAY];
    settings.twitter_consumerkey = twitter_CONSUMERKEY;
    settings.twitter_consumersecret = twitter_CONSUMERSECRET;    
    settings.page_enumeration_timegap = [NSNumber numberWithInt:threshold_PAGE_ENUMERATION_TIME_GAP];
    settings.page_draftexpiry_seconds = [NSNumber numberWithInt:page_DRAFTEXPIRES_SECONDS];
    settings.version = [NSNumber numberWithInt:0];
    settings.poll_expiry_seconds = [NSNumber numberWithInt:default_POLL_EXPIRY_IN_SECONDS];
    settings.poll_num_pages = [NSNumber numberWithInt:default_POLL_NUM_PAGES];
    settings.editor_minimum = [NSNumber numberWithInt:EDITOR_MINIMUM];
    
    settings.follow_maxnumtodownload = [NSNumber numberWithInt:maxsize_FEEDDOWNLOAD];
    settings.follow_enumeration_timegap = [NSNumber numberWithInt:threshold_FOLLOW_ENUMERATION_TIME_GAP];
    
     settings.delete_objects_after = [NSNumber numberWithInt:delete_expired_objects];
    [context save:YES onFinishCallback:nil trackProgressWith:nil];
    
    return settings;
}
@end
