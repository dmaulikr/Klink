//
//  Page.h
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

typedef enum {
    kPUBLISHED,
    kDRAFT
} PageState;

@class Photo;
@class Caption;
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
@property (nonatomic,retain) NSNumber* state; //Published? Draft?
@property (nonatomic,retain) NSNumber* datepublished; //if state==published, this is the date it was added to the book

- (NSArray*) hashtagList;
- (Photo*) photoWithHighestVotes;
- (Caption*) captionWithHighestVotes;
@end