//
//  Feed.h
//  Platform
//
//  Created by Bobby Gill on 10/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface Feed : Resource {
    
}


@property (nonatomic,retain) NSNumber* hasopened;
@property (nonatomic,retain) NSNumber* hasseen;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,retain) NSNumber* type;
@property (nonatomic,retain) NSNumber* targetobjectid;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSNumber* userid;
@end
