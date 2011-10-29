//
//  Page.m
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Page.h"

#define kDELIMETER  @","

@implementation Page
@dynamic hashtags;
@dynamic displayname;
@dynamic descr;
@dynamic dateexpire;
@dynamic imageurl;
@dynamic thumbnailurl;
@dynamic creatorid;
@dynamic creatorname;



- (NSArray*) hashtagList {
    NSArray* retVal = [self.hashtags componentsSeparatedByString:kDELIMETER];
    return retVal;
}


@end
