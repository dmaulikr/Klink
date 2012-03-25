//
//  Follow.h
//  Platform
//
//  Created by Jasjeet Gill on 3/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Follow : Resource
@property (nonatomic,retain) NSNumber* followeruserid;
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* username;
@property (nonatomic,retain) NSString* followername;
@property (nonatomic,retain) NSString* followerimageurl;
@property (nonatomic,retain) NSString* userimageurl;


//Static methods
+ (BOOL) doesFollowExistFor:(NSNumber*)userid withFollowerID:(NSNumber*)followeruserid;
//Static initializers
+ (Follow*) createFollowFor:(NSNumber*)userid withFollowerID:(NSNumber*)followeruserid;
+ (void)unfollowFor:(NSNumber*)userid withFollowerID:(NSNumber*)followeruserid;
@end
