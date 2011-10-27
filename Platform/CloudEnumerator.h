//
//  CloudEnumerator.h
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Query.h"
#import "QueryOptions.h"
#import "EnumerationContext.h"

@protocol CloudEnumeratorDelegate <NSObject> 
@optional
- (void) onEnumerateComplete;

@end



@interface CloudEnumerator : NSObject {
    BOOL m_isEnumerationPending;
    EnumerationContext*         m_enumerationContext;
    Query*                      m_query;
    QueryOptions*               m_queryOptions;
    BOOL                        m_isDone;
    id<CloudEnumeratorDelegate> m_delegate;
    NSDate*                     m_lastExecutedTime;
    long                        m_secondsBetweenConsecutiveSearches;
    NSString*                   m_identifier;
    
}
@property (nonatomic,retain) NSString*              identifier;
@property (nonatomic,retain) EnumerationContext*    enumerationContext;
@property (nonatomic,retain) Query*                 query;
@property (nonatomic,retain) QueryOptions*          queryOptions;
@property BOOL                                      isDone;
@property (nonatomic,retain) NSDate*                lastExecutedTime;
@property long                                      secondsBetweenConsecutiveSearches;
@property BOOL                                      isLoading;
@property (nonatomic,retain) id<CloudEnumeratorDelegate>   delegate;



- (id)  initWithEnumerationContext:
                  (EnumerationContext*)enumerationContext
                  withQuery:(Query*)query
                  withQueryOptions:(QueryOptions*)queryOptions;


- (id) initWithQuery:
                (Query *)query 
                withQueryOptions:(QueryOptions *)queryOptions;


- (void) enumerateNextPage;
- (void) enumerateUntilEnd;


//static initializers
+ (CloudEnumerator*) enumeratorForFeeds:(NSNumber*)userid;
+ (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid;
+ (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid;
+ (CloudEnumerator*) enumeratorForPages;
@end
