//
//  Photo.h
//  Platform
//
//  Created by Bobby Gill on 10/19/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Caption.h"
#import "Resource.h"

@interface Photo : Resource {
    
}

@property (nonatomic, retain) NSString * displayname;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSNumber * numberofviews;
@property (nonatomic, retain) NSNumber * numberofcaptions;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSString * thumbnailurl;
@property (nonatomic, retain) NSNumber * creatorid;
@property (nonatomic, retain) NSString* creatorname;
@property (nonatomic, retain) NSNumber * themeid;
@property (nonatomic, retain) NSNumber * numberofvotes;

- (Caption*) captionWithHighestVotes;

@end
