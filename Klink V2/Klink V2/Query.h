//
//  Query.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/17/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"
#import "AttributeNames.h"
#import "JSONKit.h"
#import "QueryOptions.h"


@interface Query : NSObject <IWireSerializable> {
    NSString* filterExpression;
    NSArray* attributeExpressions;
    NSArray* objectIDs;
    NSString* filterobjecttype;
    QueryOptions* queryoptions;
}

- (id)initWithIds:(NSArray*)ids;
+ (id) queryWithObjectType:(NSString*)objectType;
+ (id) queryWithIds:(NSArray*)ids;
+ (id) queryPhotosWithTheme:(NSNumber*)themeID;
+ (id) queryThemes;
+ (id) queryFeedsForUser:(NSNumber*)userID;
+ (id) queryCaptionsForPhoto:(NSNumber*)photoID;
@property (nonatomic,retain) NSString* filterExpression;
@property (nonatomic, copy)NSArray* objectIDs;
@property (nonatomic, retain) NSString* filterobjecttype;
@property (nonatomic,retain) QueryOptions* queryoptions;
@property (nonatomic, retain) NSArray* attributeExpressions;

@end
