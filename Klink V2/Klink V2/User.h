//
//  User.h
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

@interface User : ServerManagedResource <IWireSerializable> {
@private
}
@property (nonatomic, retain) NSString * displayname;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber* numberofvotes;
@property (nonatomic, retain) NSNumber* numberofviews;
@property (nonatomic, retain) NSNumber* numberofcaptions;
@property (nonatomic, retain) NSNumber* rank;
@property (nonatomic, retain) NSString* username;

+ (User*) getUserForId:(NSNumber*)userid;
@end
