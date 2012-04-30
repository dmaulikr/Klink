//
//  LeaderboardEntry.m
//  Platform
//
//  Created by Jasjeet Gill on 4/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "LeaderboardEntry.h"
#import "Attributes.h"
@implementation LeaderboardEntry
@synthesize userid = m_userid;
@synthesize points = m_points;
@synthesize position = m_position;
@synthesize username = m_username;
@synthesize imageurl = m_imageurl;


- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    self.userid = [jsonDictionary valueForKey:USERID];
    self.username = [jsonDictionary valueForKey:USERNAME];
    self.position = [jsonDictionary valueForKey:POSITION];
    self.points = [jsonDictionary valueForKey:POINTS];
    self.imageurl = [jsonDictionary valueForKey:IMAGEURL];
    return self;
}

@end
