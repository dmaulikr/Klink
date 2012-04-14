//
//  DeleteResponse.h
//  Platform
//
//  Created by Jasjeet Gill on 3/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "Response.h"
#import "Attributes.h"
#import "IJSONSerializable.h"

@interface DeleteResponse : Response <IJSONSerializable> {
    NSNumber* m_deletedObjectID;
    NSArray* m_consequentialUpdates;
}
@property (nonatomic,retain) NSArray* consequentialUpdates;
@property (nonatomic,retain) NSNumber* deletedObejctID;
@end