//
//  Query.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryOptions.h"
#import "IJSONSerializable.h"

@interface Query : NSObject <IJSONSerializable> {
    NSArray*        m_attributeExpressions;
    NSString*       m_filterObjectType;
    QueryOptions*   m_queryOptions;
    NSArray*        m_objectIDs;
    NSArray*        m_objectTypes;
}

@property (nonatomic,retain) NSArray*       attributeExpressions;
@property (nonatomic,retain) NSString*      filterObjectType;
@property (nonatomic,retain) QueryOptions*  queryOptions;
@property (nonatomic,retain) NSArray*       objectIDs;
@property (nonatomic,retain) NSArray*       objectTypes;

- (NSString*) toJSON;
- (id) initFromJSON:(NSString*)json;

//static initializers
+ (id) queryPhotosWithTheme:(NSNumber*)themeID;
+ (id) queryFeedsForUser:(NSNumber*)userID;
+ (id) queryCaptionsForPhoto:(NSNumber*)photoID;
+ (id) queryPages:(NSNumber*)afterDate;
+ (id) queryPages;
+ (id) queryDrafts;
+ (id) queryUser:(NSNumber*)userID;
+ (id) queryForIDs:(NSArray*)objectIDs withTypes:(NSArray*)types;
+ (id) queryApplicationSettings:(NSNumber*)userid;
+ (id) queryForFollowers:(NSNumber*)userid;
+ (id) queryForFollowing:(NSNumber*)userid;

@end
