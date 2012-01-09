//
//  Feed.h
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "FeedData.h"

@interface Feed : Resource {
    
}


@property (nonatomic,retain) NSNumber* hasopened;
@property (nonatomic,retain) NSNumber* hasseen;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,retain) NSNumber* feedevent;
@property (nonatomic,retain) NSNumber* targetobjectid;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSNumber* dateexpires;
@property (nonatomic,retain) NSArray* feeddata;
@property (nonatomic,retain) NSNumber* rendertype;
@end
