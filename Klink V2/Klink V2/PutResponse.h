//
//  PutResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "AttributeNames.h"
#import "ServerManagedResource.h"

@interface PutResponse : Response {
    id modifiedResource;
}

@property (nonatomic,retain) id modifiedResource;

@end
