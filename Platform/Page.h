//
//  Page.h
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface Page : Resource {
    
}


@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSNumber* dateexpire;
@property (nonatomic,retain) NSString* descr;
@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSString* hashtags;


- (NSArray*) hashtagList;

@end
