//
//  CloudEnumerator.m
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CloudEnumerator.h"
#import "NSStringGUIDCategory.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "UrlManager.h"
#import "Request.h"
#import "RequestManager.h"
#import "CallbackResult.h"
#import "EnumerationResponse.h"
#import "Macros.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"

#define kEnumerateSinglePage    @"enumerateSinglePage"

@implementation CloudEnumerator
@synthesize enumerationContext = m_enumerationContext;
@synthesize query = m_query;
@synthesize queryOptions = m_queryOptions;
@synthesize isDone = m_isDone;
@synthesize delegate = m_delegate;
@synthesize lastExecutedTime = m_lastExecutedTime;
@synthesize secondsBetweenConsecutiveSearches = m_secondsBetweenConsecutiveSearches;
@synthesize identifier = m_identifier;
@synthesize isLoading = m_isEnumerationPending;
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

- (BOOL) hasEnoughTimeLapsedBetweenConsecutiveSearches {
    long secondsSinceLastSearch = 0;
    bool hasEnoughTimeLapsedBetweenConsecutiveSearches;
    
    hasEnoughTimeLapsedBetweenConsecutiveSearches = YES;
    NSDate* currentDate = [NSDate date];
    secondsSinceLastSearch = [currentDate timeIntervalSinceDate:self.lastExecutedTime];
    
    if (self.lastExecutedTime != nil) {
        if (secondsSinceLastSearch > self.secondsBetweenConsecutiveSearches) {
            hasEnoughTimeLapsedBetweenConsecutiveSearches = YES;
        }
        else {
            hasEnoughTimeLapsedBetweenConsecutiveSearches = NO;
        }
    }
    return hasEnoughTimeLapsedBetweenConsecutiveSearches;
}

- (Request*) requestFor:(NSURL*)url forOperation:(int)operationCode withUserInfo:(NSDictionary*)userInfo {
    Request* request = [Request createInstanceOfRequest];
    request.url = [url absoluteString];
    request.operationcode = [NSNumber numberWithInt:operationCode];
    request.statuscode = [NSNumber numberWithInt:kPENDING];
    request.onFailCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onEnumerateComplete:) withContext:userInfo];;
     request.onSuccessCallback = [[Callback alloc]initWithTarget:self withSelector:@selector(onEnumerateComplete:) withContext:userInfo];;
    request.userInfo = userInfo;
    return request;
}


- (void) enumerateNextPage {
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
     
    BOOL hasEnoughTimeLapsedBetweenConsecutiveSearches = [self hasEnoughTimeLapsedBetweenConsecutiveSearches];
    
    if (!m_isEnumerationPending &&
        hasEnoughTimeLapsedBetweenConsecutiveSearches) {
        
        self.lastExecutedTime = [NSDate date];
        m_isEnumerationPending = YES;
        
        NSURL* url = [UrlManager urlForQuery:self.query withEnumerationContext:self.enumerationContext withAuthenticationContext:authenticationContext];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kEnumerateSinglePage];
        
            
        Request* request = [self requestFor:url forOperation:kENUMERATION withUserInfo:userInfo];
        
        RequestManager* requestManager = [RequestManager instance];
        [requestManager submitRequest:request];
    }
    
    
}


- (void) enumerateUntilEnd {
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];    
    BOOL hasEnoughTimeLapsedBetweenConsecutiveSearches = [self hasEnoughTimeLapsedBetweenConsecutiveSearches];
    

    if (!m_isEnumerationPending &&
        hasEnoughTimeLapsedBetweenConsecutiveSearches) {        
        self.lastExecutedTime = [NSDate date];
        m_isEnumerationPending = YES;
        
        NSURL* url = [UrlManager urlForQuery:self.query withEnumerationContext:self.enumerationContext withAuthenticationContext:authenticationContext];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:kEnumerateSinglePage];
        
        Request* request = [self requestFor:url forOperation:kENUMERATION withUserInfo:userInfo];
        RequestManager* requestManager = [RequestManager instance];
        [requestManager submitRequest:request];
    
    }
}

- (void) onEnumerateComplete:(CallbackResult*)callbackResult {
    NSString* activityName = @"CloudEnumerator.onEnumerationComplete:";
    EnumerationResponse* response = (EnumerationResponse*)callbackResult.response;
    if ([response.didSucceed boolValue]) {
        EnumerationContext* returnedContext = response.enumerationContext;
        self.enumerationContext = returnedContext;
        self.isDone = [returnedContext.isDone boolValue];
        
        NSDictionary* userInfo = callbackResult.context;
        BOOL shouldEnumerateSinglePage = [[userInfo valueForKey:kEnumerateSinglePage] boolValue];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
        LOG_ENUMERATION(0,@"%@Enumeration succeeded with %d primary results and %d secondary results returned",activityName, [response.primaryResults count], [response.secondaryResults count]);
        
        //process the returned results
        if (response.primaryResults != nil) {
            for (Resource* resource in response.primaryResults) {
                
                Resource* exisitingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid] ;
                
                if (exisitingResource == nil) {
                    //this is a new object
                    [resourceContext insert:resource];
                }
                else {
                    //updating an existing object
                    [exisitingResource refreshWith:resource];
                }
            }
        }
        
        //process any secondary objects
        if (response.secondaryResults != nil) {
            for (Resource* resource in response.secondaryResults) {
             
                Resource* exisitingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid] ;
                
                if (exisitingResource == nil) {
                    //this is a new object
                    [resourceContext insert:resource];
                }
                else {
                    //updating an existing object
                    [exisitingResource refreshWith:resource];
                }
            }

        }
        
        [resourceContext save:YES onFinishCallback:nil];
        
        if (!self.isDone) {
            //enumeration is still open
            
            if (!shouldEnumerateSinglePage) {
                //should continue enumeration till end
                [self enumerateUntilEnd];
            }
        }
        else {
            LOG_ENUMERATION(0, @"%@Enumeration is complete",activityName);
        }
    }
    else {
        //enumeration failed
        LOG_ENUMERATION(1,@"%@Enumeration failed due to error: %@",activityName,response.errorMessage);
    }
    m_isEnumerationPending = NO;
}


#pragma mark - Static initializers

+ (CloudEnumerator*) enumeratorForFeeds:(NSNumber *)userid {
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    Query* query = [Query queryFeedsForUser:userid];
    QueryOptions* queryOptions = [QueryOptions queryForFeedsForUser:userid];
    EnumerationContext* enumerationContext = [EnumerationContext contextForFeeds:userid];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.identifier = [userid stringValue];
    enumerator.secondsBetweenConsecutiveSearches = [settings.feed_enumeration_timegap intValue];
    return enumerator;
}
//
//+ (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid {
//    
//    Query* query = [Query queryCaptionsForPhoto:photoid];
//    QueryOptions* queryOptions = [QueryOptions queryForCaptions:photoid];
//    EnumerationContext* enumerationContext = [EnumerationContext contextForCaptions:photoid];
//    query.queryoptions = queryOptions;
//  
//    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
//    enumerator.identifier = [photoid stringValue];
//    enumerator.secondsBetweenConsecutiveSearches = threshold_CAPTION_ENUMERATION_TIME_GAP;
//    return enumerator;
//    
//}
//
+ (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid {
    Query* query = [Query queryPhotosWithTheme:themeid];
    QueryOptions* queryOptions = [QueryOptions queryForPhotosInTheme];
    EnumerationContext* enumerationContext = [EnumerationContext contextForPhotosInTheme:themeid];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.identifier = [themeid stringValue];
    enumerator.secondsBetweenConsecutiveSearches = 60;
    return enumerator;
}
//
//+ (CloudEnumerator*) enumeratorForThemes {
//    Query* query = [Query queryThemes];
//    QueryOptions* queryOptions = [QueryOptions queryForThemes];
//    EnumerationContext* enumerationContext = [EnumerationContext contextForThemes];
//    query.queryoptions = queryOptions;
//    
//    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
//    enumerator.secondsBetweenConsecutiveSearches = threshold_THEME_ENUMERATION_TIME_GAP;
//    return enumerator;
//}


@end
