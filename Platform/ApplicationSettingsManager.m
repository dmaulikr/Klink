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
    self = [super init];
    if (self) {
        self.resourceContext = [ResourceContext instance];
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
    
    settings.fb_app_id = @"168077769927457";
    
    
    [self.resourceContext save:NO onFinishCallback:nil];
    
    return settings;
}
@end
