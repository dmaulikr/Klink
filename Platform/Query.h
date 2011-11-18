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
}

@property (nonatomic,retain) NSArray*       attributeExpressions;
@property (nonatomic,retain) NSString*      filterObjectType;
@property (nonatomic,retain) QueryOptions*  queryOptions;

- (NSString*) toJSON;
- (id) initFromJSON:(NSString*)json;

//static initializers
+ (id) queryPhotosWithTheme:(NSNumber*)themeID;
+ (id) queryFeedsForUser:(NSNumber*)userID;
+ (id) queryCaptionsForPhoto:(NSNumber*)photoID;
+ (id) queryPages;
+ (id) queryUser:(NSNumber*)userID;
@end
