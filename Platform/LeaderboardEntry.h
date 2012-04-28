//
//  LeaderboardEntry.h
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"

@interface LeaderboardEntry : NSObject <IJSONSerializable>
{
    NSNumber* m_position;
    NSNumber* m_userid;
    NSString* m_username;
    NSNumber* m_points;
    NSString* m_imageurl;
}

@property (nonatomic,retain) NSNumber* position;
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* username;
@property (nonatomic,retain) NSNumber* points;
@property (nonatomic,retain) NSString* imageurl;
@end
