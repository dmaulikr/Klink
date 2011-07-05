//
//  EnumerationResponse.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "IWireSerializable.h"
#import "Response.h"
#import "AttributeNames.h"


@class EnumerationContext;
@interface EnumerationResponse : Response <IWireSerializable> {
    EnumerationContext* enumerationContext;
    NSDate *date;
    NSArray *primaryResults;
    NSArray *secondaryResults;
}

@property (nonatomic,retain) EnumerationContext *enumerationContext;
@property (nonatomic,retain) NSDate* date;
@property (nonatomic,retain) NSArray* primaryResults;
@property (nonatomic,retain) NSArray* secondaryResults;


@end
