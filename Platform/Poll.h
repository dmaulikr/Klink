//
//  Poll.h
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Poll : Resource

@property (nonatomic,retain) NSNumber* dateexpires;
@property (nonatomic,retain) NSNumber* winningobjectid;
@property (nonatomic,retain) NSNumber* winningobjecttype;
@property (nonatomic,retain) NSNumber* state;
@property (nonatomic,retain) NSArray*  polldata;
@property (nonatomic,retain) NSNumber* hasvoted;
@end
