//
//  CloudEnumerator.m
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CloudEnumerator.h"
#import "NSStringGUIDCategory.h"

@implementation CloudEnumerator
@synthesize enumerationContext = m_enumerationContext;
@synthesize query = m_query;
@synthesize queryOptions = m_queryOptions;
@synthesize isDone = m_isDone;
@synthesize delegate = m_delegate;


- (id) initWithEnumerationContext:(EnumerationContext *)enumerationContext withQuery:(Query *)query withQueryOptions:(QueryOptions *)queryOptions {
    
    self = [super init];
    if (self != nil) {
        self.enumerationContext = enumerationContext;
        self.query = query;
        self.queryOptions = queryOptions;
        m_isEnumerationPending = NO;
    }
    
    return self;
}

- (id) initWithQuery:(Query *)query withQueryOptions:(QueryOptions *)queryOptions {
    
    self = [super init];
    if (self != nil) {
        self.enumerationContext = [[EnumerationContext alloc]init];
        self.query = query;
        self.queryOptions = queryOptions;
         m_isEnumerationPending = NO;
    }
    return self;
}

- (void) enumerateNextPage {
    WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (!m_isEnumerationPending) {
        m_isEnumerationPending = YES;
        NSString* notificationID = [NSString GetGUID];    
        [notificationCenter addObserver:self selector:@selector(onEnumerateComplete:) name:notificationID object:nil];
        
        
        NSURL* url = [UrlManager getEnumerateURLForQuery:self.query withEnumerationContext:self.enumerationContext withAuthenticationContext:authenticationContext];
        [enumerationManager enumerate:url withQuery:self.query withEnumerationContext:self.enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:YES];
    }
    
}

- (void) enumerateUntilEnd {
    WS_EnumerationManager* enumerationManager = [WS_EnumerationManager getInstance];
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (!m_isEnumerationPending) {
        m_isEnumerationPending = YES;
        NSString* notificationID = [NSString GetGUID];    
        [notificationCenter addObserver:self selector:@selector(onEnumerateComplete:) name:notificationID object:nil];
        
        
        NSURL* url = [UrlManager getEnumerateURLForQuery:self.query withEnumerationContext:self.enumerationContext withAuthenticationContext:authenticationContext];
        [enumerationManager enumerate:url withQuery:self.query withEnumerationContext:self.enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:NO];
    }
}

- (void) onEnumerateComplete : (NSNotification*)notification {
    NSDictionary* userInfo = [notification userInfo];
    if ([userInfo objectForKey:an_ENUMERATIONCONTEXT] != [NSNull null]) {
        EnumerationContext* returnedContext = [userInfo objectForKey:an_ENUMERATIONCONTEXT];
        self.enumerationContext = returnedContext;
        self.isDone = [self.enumerationContext.isDone boolValue];
    }
    
    if (self.delegate != nil) {
        [self.delegate onEnumerateComplete];
    }
    m_isEnumerationPending = NO;
}


#pragma mark - Static initializers
+ (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid {
    Query* query = [Query queryCaptionsForPhoto:photoid];
    QueryOptions* queryOptions = [QueryOptions queryForCaptions:photoid];
    EnumerationContext* enumerationContext = [EnumerationContext contextForCaptions:photoid];
    query.queryoptions = queryOptions;
  
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    return enumerator;
    
}

+ (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid {
    Query* query = [Query queryPhotosWithTheme:themeid];
    QueryOptions* queryOptions = [QueryOptions queryForPhotosInTheme];
    EnumerationContext* enumerationContext = [EnumerationContext contextForPhotosInTheme:themeid];
    query.queryoptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    return enumerator;
}

+ (CloudEnumerator*) enumeratorForThemes {
    Query* query = [Query queryThemes];
    QueryOptions* queryOptions = [QueryOptions queryForThemes];
    EnumerationContext* enumerationContext = [EnumerationContext contextForThemes];
    query.queryoptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    return enumerator;
}


@end
