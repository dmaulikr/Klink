//
//  EnumerationContext.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONKit.h"
#import "IJSONSerializable.h"
@interface EnumerationContext : NSObject <IJSONSerializable> {
    NSNumber* m_isDone;
    NSNumber* m_pageSize;
    NSNumber* m_numberOfResultsReturned;
    NSNumber* m_pageNumber;
    NSNumber* m_maximumNumberOfResults;
}

@property (nonatomic,retain) NSNumber* pageSize;
@property (nonatomic,retain) NSNumber* numberOfResultsReturned;
@property (nonatomic,retain) NSNumber* pageNumber;
@property (nonatomic,retain) NSNumber* isDone;
@property (nonatomic,retain) NSNumber* maximumNumberOfResults;

- (NSString*) toJSON;
- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary;

+ (EnumerationContext*) contextForFeeds:        (NSNumber*)userid;
+ (EnumerationContext*) contextForPhotosInTheme:(NSNumber*)themeid;
+ (EnumerationContext*) contextForPages;
+ (EnumerationContext*) contextForCaptions:     (NSNumber*)photoid;
- (id) init;
- (NSString*) toJSON;
@end
