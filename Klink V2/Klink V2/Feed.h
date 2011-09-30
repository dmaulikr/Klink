//
//  Feed.h
//  Klink V2
//
//  Created by Bobby Gill on 7/24/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManagedResource.h"

@interface Feed : ServerManagedResource {
    
}

@property (nonatomic,retain) NSNumber* userid;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSNumber* targetid;
@property (nonatomic,retain) NSNumber* sequencenumber;
@property (nonatomic,retain) NSNumber* type;
@property (nonatomic,retain) NSNumber* user_hasread;


@end
