//
//  EnumerationResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "Response.h"
#import "IJSONSerializable.h"


@class EnumerationContext;
@interface EnumerationResponse : Response  {
    EnumerationContext* m_enumerationContext;
    NSDate*             m_date;
    NSArray*            m_primaryResults;
    NSArray*            m_secondaryResults;
}


@property (nonatomic,retain) EnumerationContext*    enumerationContext;
@property (nonatomic,retain) NSDate*                date;
@property (nonatomic,retain) NSArray*               primaryResults;
@property (nonatomic,retain) NSArray*               secondaryResults;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary;


@end
