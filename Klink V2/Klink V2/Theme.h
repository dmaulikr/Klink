//
//  Theme.h
//  Klink V2
//
//  Created by Bobby Gill on 7/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManagedResource.h"
#import <CoreData/CoreData.h>
@interface Theme : ServerManagedResource <IWireSerializable>{
@private
}

- (NSArray*) arrayForHashtags;
@property (nonatomic, retain) NSNumber* creatorid;
@property (nonatomic, retain) NSString* creatorname;
@property (nonatomic, retain) NSString* descr;
@property (nonatomic, retain) NSString* displayname;
@property (nonatomic, retain) NSString* homeimageurl;
@property (nonatomic, retain) NSString* hashtags;
@end
