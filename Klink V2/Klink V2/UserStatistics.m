//
//  UserStatistics.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "UserStatistics.h"


@implementation UserStatistics
@dynamic numberOfNewViews;
@dynamic numberOfNewCaptions;
@dynamic userid;

- (id) initFromDictionary:(NSDictionary*)jsonDictionary {
    self = [super initFromDictionary:jsonDictionary];
    if (self != nil) {
        self.numberOfNewViews = [jsonDictionary valueForKey:an_NUMBEROFNEWVIEWS];
        self.numberOfNewCaptions = [jsonDictionary valueForKey:an_NUMBEROFNEWCAPTIONS];
               
    }
    return self;
}

+ (NSString*) getTypeName {
    return tn_USERSTATISTICS;
    
}

-  (id) getCreateNotificationName {
    return n_USERSTATISTICS_CREATE;
}
-  (id) getUpdateNotificationName {
    return n_USERSTATISTICS_UPDATE;
}

-  (id) toJSON {
    NSMutableDictionary *dictionary = nil;
    
    dictionary = [super toJSON];
    [dictionary setValue:self.numberOfNewViews forKey:an_NUMBEROFNEWVIEWS];
    [dictionary setValue:self.numberOfNewCaptions forKey:an_NUMBEROFNEWCAPTIONS];

    return dictionary;
    
}

@end
