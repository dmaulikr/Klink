//
//  Photo.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerManagedResource.h"
#import "IWireSerializable.h"
#import "TypeNames.h"
#import "AttributeNames.h"

@interface Photo : ServerManagedResource <IWireSerializable> {
@private
}
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSNumber * numberOfViews;
@property (nonatomic, retain) NSNumber * numberOfCaptions;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * imageurl;
@property (nonatomic, retain) NSString * thumbnailurl;
@property (nonatomic, retain) NSNumber * creatorid;
@property (nonatomic,retain) NSString* creatorname;
@property (nonatomic, retain) NSNumber * themeid;
@property (nonatomic, retain) NSNumber * numberofvotes;

+ (NSString*) getNewPhotoTitle;
@end
