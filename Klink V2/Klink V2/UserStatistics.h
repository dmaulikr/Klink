//
//  UserStatistics.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServerManagedResource.h"
#import "IWireSerializable.h"
#import "TypeNames.h";
#import "AttributeNames.h"

@interface UserStatistics : ServerManagedResource <IWireSerializable> {
@private
}
@property (nonatomic, retain) NSNumber * numberOfNewViews;
@property (nonatomic, retain) NSNumber * numberOfNewCaptions;
@property (nonatomic, retain) NSNumber * userid;
@end
