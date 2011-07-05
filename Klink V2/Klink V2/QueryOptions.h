//
//  QueryOptions.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"
#import "JSONKit.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "ApplicationSettings.h"
@interface QueryOptions : NSObject <IWireSerializable> {
    BOOL includelinkedobjects;
    NSString *referencingattribute;
    NSString *referencingobjecttype;
    int maxlinksreturnedperobject;
    BOOL sortAscending;
    NSString* sortattribute;
}

@property BOOL includelinkedobjects;
@property (nonatomic,retain) NSString* referencingattribute;
@property (nonatomic,retain) NSString* referencingobjecttype;
@property int maxlinksreturnedperobject;
@property BOOL sortAscending;
@property (nonatomic,retain) NSString* sortattribute;

+(QueryOptions*)queryForTopics;
- (NSDictionary*)toDictionary;
@end
