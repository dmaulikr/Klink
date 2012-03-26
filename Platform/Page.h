//
//  Page.h
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"



@class Photo;
@class Caption;
@interface Page : Resource {
    
}

@property (nonatomic,retain) NSNumber* numberofflags;
@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSString* imageurl;

@property (nonatomic,retain) NSString* descr;
@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSString* hashtags;
@property (nonatomic,retain) NSNumber* state; //Published? Draft?
@property (nonatomic,retain) NSNumber* datepublished; //if state==published, this is the date it was added to the book
@property (nonatomic,retain) NSNumber* numberofphotos;
@property (nonatomic,retain) NSNumber* numberofcaptions;
@property (nonatomic,retain) NSNumber* numberofpublishvotes;
@property (nonatomic,retain) NSNumber* finishedcaptionid;
@property (nonatomic,retain) NSNumber* datedraftexpires;
@property (nonatomic,retain) NSNumber* finishedphotoid;
@property (nonatomic,retain) NSNumber* topvotedcaptionid;
@property (nonatomic,retain) NSNumber* finishedwriterid;
@property (nonatomic,retain) NSNumber* finishedillustratorid;


- (NSArray*) hashtagList;
- (Photo*) photoWithHighestVotes;
- (Caption*) captionWithHighestVotes;
- (int) numberOfUnreadCaptions;

- (void) updateCaptionWithHighestVotes;
- (void) updateCaptionWithHighestVotes:(Caption*)caption;

//static initializers
+ (Page*)createNewDraftPage;
+ (int)numberOfDrafts;

@end
