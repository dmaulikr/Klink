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

@interface ApplicationSettingsManager : NSObject {
    ResourceContext* m_resourceContext;
 
}

@property (nonatomic, retain) ResourceContext* resourceContext;
@property (nonatomic, retain) ApplicationSettings* settings;
- (ApplicationSettings*) createDefaultSettingsObject;

+ (id) instance;


@end
