//
//  PutResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import "Attributes.h"
#import "Resource.h"

@interface PutResponse : Response {
    id      m_modifiedResource;
    NSArray *m_secondaryResults;
}

@property (nonatomic,retain) id         modifiedResource;
@property (nonatomic,retain) NSArray*   secondaryResults;

@end
