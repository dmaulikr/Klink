//
//  FeedData.h
//  Platform
//
//  Created by Jasjeet Gill on 11/20/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"

@interface FeedData : NSObject <IJSONSerializable> {
    NSString* m_key;
    NSNumber* m_objectid;
    NSString* m_objecttype;

}

@property (nonatomic,retain) NSString* key;
@property (nonatomic,retain) NSNumber* objectid;
@property (nonatomic,retain) NSString* objecttype;
@end
