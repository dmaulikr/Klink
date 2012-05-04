//
//  Achievement.h
//  Platform
//
//  Created by Jasjeet Gill on 5/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Achievement : Resource


@property (nonatomic,retain) NSNumber* dateexpires;
@property (nonatomic,retain) NSNumber* type;
@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSString* descr;
@end
