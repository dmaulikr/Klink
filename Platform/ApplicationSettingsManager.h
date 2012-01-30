//
//  ApplicationSettingsManager.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceContext.h"
#import "ApplicationSettings.h"
#import "CloudEnumerator.h"

@interface ApplicationSettingsManager : NSObject <CloudEnumeratorDelegate> {
  
    Callback* m_onFinishCallback;
    ApplicationSettings* m_applicationSettings;
}


@property (nonatomic, retain) ApplicationSettings* settings;
@property (nonatomic, retain) CloudEnumerator*  applicationSettingsEnumerator;
@property (nonatomic, retain) Callback* onFinishCallback;
- (ApplicationSettings*) createDefaultSettingsObject;
- (void) refreshApplicationSettings:(Callback*)callback;
+ (id) instance;


@end
