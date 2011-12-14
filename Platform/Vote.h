//
//  Vote.h
//  Platform
//
//  Created by Jasjeet Gill on 11/21/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"

@interface Vote : Resource

@property (nonatomic,retain) NSNumber* creatorid;
@property (nonatomic,retain) NSNumber* pollid;
@property (nonatomic,retain) NSNumber* targetid;
@property (nonatomic,retain) NSString* targetobjecttype;

+ (Vote*)createVoteFor:(NSNumber*)pollID forTarget:(NSNumber*)objectid withType:(NSString*)type;
@end
