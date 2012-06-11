//
//  CreateResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "Response.h"
#import "Attributes.h"
#import "IJSONSerializable.h"
@interface CreateResponse : Response <IJSONSerializable> {
    NSArray* createdResources;
    NSArray* m_secondaryResults;
    NSArray* m_consequentialUpdates;
    NSArray* m_consequentialInserts;
}

@property (nonatomic,retain) NSArray* createdResources;
@property (nonatomic,retain) NSArray* consequentialUpdates;
@property (nonatomic,retain) NSArray* consequentialInserts;
@property (nonatomic,retain) NSArray* secondaryResults;
-(Resource*) createdResourceWith:(NSNumber*)resourceid withTargetResourceType:(NSString*)targetresourcetype;
@end
