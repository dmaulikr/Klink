//
//  CreateResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManagedResource.h"
#import "AttributeNames.h"

@interface CreateResponse : Response {
    NSArray* createdResources;
}

@property (nonatomic,retain) NSArray* createdResources;

@end
