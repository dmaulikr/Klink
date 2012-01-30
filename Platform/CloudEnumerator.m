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
#import "PageState.h"
#import "Page.h"
#import "UserDefaultSettings.h"
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
@synthesize userInfo = m_userInfo;
@synthesize results = m_results;
@synthesize resultsLock = m_resultsLock;
- (id) initWithEnumerationContext:(EnumerationContext *)enumerationContext withQuery:(Query *)query withQueryOptions:(QueryOptions *)queryOptions {
    
    self = [super init];
    if (self != nil) {
        self.enumerationContext = enumerationContext;
        self.query = query;
        self.lastExecutedTime = nil;
        self.queryOptions = queryOptions;
        m_isEnumerationPending = NO;
        
        NSMutableArray* r = [[NSMutableArray alloc]init];
        self.results = r;
        [r release];  
        
        NSLock* lock = [[NSLock alloc]init];
        self.resultsLock = lock;
        [lock release];
    }
    
    return self;
}

- (void) dealloc {
    //[self.enumerationContext release];
    self.query = nil;
    self.queryOptions = nil;
    self.userInfo = nil;
    self.identifier = nil;
    self.delegate = nil;
    self.resultsLock = nil;
    self.results = nil;
    [super dealloc];
}

- (id) initWithQuery:(Query *)query withQueryOptions:(QueryOptions *)queryOptions {
    
    self = [super init];
    if (self != nil) {
        EnumerationContext* ec = [[EnumerationContext alloc]init];
        self.enumerationContext = ec;
        [ec release];
        
        self.query = query;
        self.queryOptions = queryOptions;
         m_isEnumerationPending = NO;
        self.lastExecutedTime = nil;
        
        NSMutableArray* r = [[NSMutableArray alloc]init];
        self.results = r;
        [r release];
       
    }
    return self;
}

- (BOOL) hasEnoughTimeLapsedBetweenConsecutiveSearches {
    long secondsSinceLastSearch = 0;
    bool hasEnoughTimeLapsedBetweenConsecutiveSearches;
    
    hasEnoughTimeLapsedBetweenConsecutiveSearches = YES;
    
        
    if (self.lastExecutedTime != nil) {
        NSDate* currentDate = [NSDate date];
        secondsSinceLastSearch = [currentDate timeIntervalSinceDate:self.lastExecutedTime];

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
    
    [request updateRequestStatus:kPENDING];
    //request.statuscode = [NSNumber numberWithInt:kPENDING];
    
    Callback* fcb = [[Callback alloc]initWithTarget:self withSelector:@selector(onEnumerateComplete:) withContext:userInfo];
    request.onFailCallback = fcb;
    [fcb release];
    
    
    Callback* cb = [[Callback alloc]initWithTarget:self withSelector:@selector(onEnumerateComplete:) withContext:userInfo];
    request.onSuccessCallback = cb;
    [cb release];
    
    request.userInfo = userInfo;
    return request;
}

- (BOOL) canEnumerate 
{
    //returns a flag indicating whether the enuemerator is in a state to be executed
    //again, which is a AND of its is loading and timeElapsed property
    BOOL hasEnoughTimeLapsedBetweenConsecutiveSearches = [self hasEnoughTimeLapsedBetweenConsecutiveSearches];
    
    return (hasEnoughTimeLapsedBetweenConsecutiveSearches && !m_isEnumerationPending);
}

- (void) enumerate:(BOOL)enumerateSinglePage {
    AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
    NSURL* url = [UrlManager urlForQuery:self.query withEnumerationContext:self.enumerationContext withAuthenticationContext:authenticationContext];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:enumerateSinglePage] forKey:kEnumerateSinglePage];
    

    
    Request* request = [self requestFor:url forOperation:kENUMERATION withUserInfo:userInfo];
    
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];

}

- (BOOL) hasReturnedObjectWithID:(NSNumber *)objectid 
{
    BOOL retVal = NO;
    //returns a boolean indicating whether the results array
    //contains the specified object id
    [self.resultsLock lock];
    for (Resource* resource in self.results) 
    {
        if ([resource.objectid isEqualToNumber:objectid])
        {
            //yes it has
            retVal = YES;
            break;
        }
    }
    [self.resultsLock unlock];
    return retVal;
                                
}

- (void) enumerateNextPage:(NSDictionary*)userInfo {
    NSString* activityName = @"CloudEnumerator.enumerateNextPage:"; 
    BOOL hasEnoughTimeLapsedBetweenConsecutiveSearches = [self hasEnoughTimeLapsedBetweenConsecutiveSearches];
    
    
    if (!m_isEnumerationPending &&
        hasEnoughTimeLapsedBetweenConsecutiveSearches) {
        LOG_ENUMERATION(0, @"%@Beginning to enumerate a single page of results",activityName);
        self.userInfo = userInfo;
        self.lastExecutedTime = [NSDate date];
        m_isEnumerationPending = YES;
        
        [self enumerate:YES];
    }
    else {
        LOG_ENUMERATION(1, @"%@Could not execute enumerate either because an existing enumeration is pending or not enough time has lapsed to run the next enumeration",activityName);
    }
    
    
}


- (void) enumerateUntilEnd:(NSDictionary*)userInfo {
    NSString* activityName = @"CloudEnumerator.enumerateUntilEnd:";
    BOOL hasEnoughTimeLapsedBetweenConsecutiveSearches = [self hasEnoughTimeLapsedBetweenConsecutiveSearches];
    
    
    if (!m_isEnumerationPending &&
        hasEnoughTimeLapsedBetweenConsecutiveSearches &&
        self.enumerationContext != nil) {
        LOG_ENUMERATION(0, @"%@Beginning to enumerate until all results of the query are downloaded",activityName);
        self.userInfo = userInfo;
        self.lastExecutedTime = [NSDate date];
        m_isEnumerationPending = YES;
        
        [self enumerate:NO];
    
    }
    else {
        //no execute case
        LOG_ENUMERATION(1, @"%@Could not execute enumerate either because an existing enumeration is pending or not enough time has lapsed to run the next enumeration",activityName);
    }
}
- (void) reset {
    //resets an enumerator to a default state
    self.lastExecutedTime = nil;
    self.enumerationContext.isDone = NO;
    self.enumerationContext.pageNumber = 0;
    self.enumerationContext.numberOfResultsReturned = 0;
    m_isEnumerationPending = NO;
    //we clear the results cache
    [self.resultsLock lock];
    [self.results removeAllObjects];
    [self.resultsLock unlock];
    
}

- (void) onEnumerateComplete:(CallbackResult*)callbackResult {
    NSString* activityName = @"CloudEnumerator.onEnumerationComplete:";
    EnumerationResponse* response = (EnumerationResponse*)callbackResult.response;
    if ([response.didSucceed boolValue]) {
        EnumerationContext* returnedContext = response.enumerationContext;
        
        if (returnedContext == nil) {
            LOG_ENUMERATION(1,@"%@Detected a receipt of a null enumeration context from response",activityName);
        }
        
        
        self.enumerationContext = returnedContext;
        self.isDone = [returnedContext.isDone boolValue];
        
        
        
        NSDictionary* userInfo = callbackResult.context;
        BOOL shouldEnumerateSinglePage = [[userInfo valueForKey:kEnumerateSinglePage] boolValue];
        
        ResourceContext* resourceContext = [ResourceContext instance];
        
        LOG_ENUMERATION(0,@"%@Enumeration succeeded with %d primary results and %d secondary results returned",activityName, [response.primaryResults count], [response.secondaryResults count]);
        
        
        
        
        //process the returned results
        if (response.primaryResults != nil) {
            for (Resource* resource in response.primaryResults) {
                Resource* existingResource = nil;
                BOOL isSingletonType = [TypeInstanceData isSingletonType:resource.objecttype];
                //we add all returned data to the inner cache
                [self.resultsLock lock];
                [self.results addObject:resource];
                [self.resultsLock unlock];
                
                if (!isSingletonType) {
                    existingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid];
                }
                else {
                    existingResource = [resourceContext singletonResourceWithType:resource.objecttype];
                }

                //Resource* exisitingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid] ;
                
                if (existingResource == nil) {
                    //this is a new object
                    [resourceContext insert:resource];
                }
                else {
                    //updating an existing object
                    [existingResource refreshWith:resource];
                }
            }
        }
        
        //process any secondary objects
        if (response.secondaryResults != nil) {
            for (Resource* resource in response.secondaryResults) {
                Resource* existingResource = nil;
                BOOL isSingletonType = [TypeInstanceData isSingletonType:resource.objecttype];
                
                //we add all returned data to the inner cache
                [self.resultsLock lock];
                [self.results addObject:resource];
                [self.resultsLock unlock];
                
                if (!isSingletonType) {
                    existingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid];
                }
                else {
                    existingResource = [resourceContext singletonResourceWithType:resource.objecttype];
                }
                
                if (existingResource == nil) {
                    //this is a new object
                    [resourceContext insert:resource];
                }
                else {
                    //updating an existing object
                    [existingResource refreshWith:resource];
                }
            }

        }
        
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        
        if (!self.isDone) {
            //enumeration is still open
            
            if (!shouldEnumerateSinglePage) {
                //should continue enumeration till end
                LOG_ENUMERATION(0, @"%@Enumeration context remains open, enumerating next page",activityName);
                [self enumerate:NO];
            }
            else {
                LOG_ENUMERATION(0, @"%@Enumerate sinlge page complete, enumeration context remains open",activityName);
                m_isEnumerationPending = NO;
                [self performSelectorOnMainThread:@selector(callOnEnumerationCompleteOnDelegateWith:) withObject:self.userInfo waitUntilDone:YES];
               
            }
        }
        else {
            LOG_ENUMERATION(0, @"%@Enumeration context is complete",activityName);
            m_isEnumerationPending = NO;
                   [self performSelectorOnMainThread:@selector(callOnEnumerationCompleteOnDelegateWith:) withObject:self.userInfo waitUntilDone:YES];
            
            
        }
    }
    else {
        //enumeration failed
        LOG_ENUMERATION(1,@"%@Enumeration failed due to error: %@",activityName,response.errorMessage);
        m_isEnumerationPending = NO;
        [self performSelectorOnMainThread:@selector(callOnEnumerationCompleteOnDelegateWith:) withObject:self.userInfo waitUntilDone:YES];    }
  
}

- (void) callOnEnumerationCompleteOnDelegateWith:(NSDictionary*)userInfo {
    [self.delegate onEnumerateComplete:self withResults:self.results withUserInfo:userInfo];
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

+ (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid {
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    Query* query = [Query queryCaptionsForPhoto:photoid];
    QueryOptions* queryOptions = [QueryOptions queryForCaptions:photoid];
    EnumerationContext* enumerationContext = [EnumerationContext contextForCaptions:photoid];
    query.queryOptions = queryOptions;
  
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.identifier = [photoid stringValue];
    enumerator.secondsBetweenConsecutiveSearches = [settings.caption_enumeration_timegap intValue];
    return enumerator;
    
}

+ (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid {
    //ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    Query* query = [Query queryPhotosWithTheme:themeid];
    QueryOptions* queryOptions = [QueryOptions queryForPhotos];
    EnumerationContext* enumerationContext = [EnumerationContext contextForPhotosInTheme:themeid];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.identifier = [themeid stringValue];
    enumerator.secondsBetweenConsecutiveSearches = 0;
    return enumerator;
}

+ (CloudEnumerator*) enumeratorForUser:(NSNumber *)userid {
    Query* query = [Query queryUser:userid];
    QueryOptions* queryOptions = [QueryOptions queryForUser:userid];
    EnumerationContext* enumerationContext = [EnumerationContext contextForUser:userid];
    query.queryOptions = queryOptions;
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.identifier = [userid stringValue];
    enumerator.secondsBetweenConsecutiveSearches = 5;
    return enumerator;
}



+ (CloudEnumerator*) enumeratorForPages {
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    
    //we need to get the last date published in the store
   
    NSNumber* numPublished = [NSNumber numberWithInt:kPUBLISHED];
     ResourceContext* resourceContext = [ResourceContext instance];
    Page* page = (Page*)[resourceContext resourceWithType:PAGE withValueEqual:[numPublished stringValue] forAttribute:STATE sortBy:DATEPUBLISHED sortAscending:NO];
    
    //we also check a user default setting
    //if hasDownloadedBook is set to false, we return an enumerator for the entire book, if not, we return a optimized enumerator
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasDownloadedBook = [defaults boolForKey:setting_HASDOWNLOADEDBOOK];
    
    Query* query = nil;
    
    if (page == nil || !hasDownloadedBook) {
        //in this case we dont have any pages
        query = [Query queryPages];
    }
    else {
        query = [Query queryPages:page.datepublished];
    }
    
    QueryOptions* queryOptions = [QueryOptions queryForPages];
    EnumerationContext* enumerationContext = [EnumerationContext contextForPages];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.secondsBetweenConsecutiveSearches = [settings.page_enumeration_timegap intValue];
    return enumerator;
}

//Returns a enumerator to use in trhe ProductionLogViewController
+ (CloudEnumerator*) enumeratorForDrafts {
    //we need to create an enumeration for all Drafts 
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    Query* query = [Query queryDrafts];
    QueryOptions* queryOptions = [QueryOptions queryForDrafts];
    EnumerationContext* enumerationContext = [EnumerationContext contextForDrafts];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.secondsBetweenConsecutiveSearches = [settings.page_enumeration_timegap intValue];
    return enumerator;

    
    
    
}
+ (CloudEnumerator*) enumeratorForApplicationSettings:(NSNumber*)userid {
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    Query* query = [Query queryApplicationSettings:userid];
    QueryOptions* queryOptions = [QueryOptions queryForApplicationSettings:userid];
    EnumerationContext* enumerationContext = [EnumerationContext contextForApplicationSettings:userid];
    query.queryOptions = queryOptions;

    CloudEnumerator* enumerator = [[[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions]autorelease];
    enumerator.secondsBetweenConsecutiveSearches = [settings.page_enumeration_timegap intValue];
    return enumerator;
}

#pragma mark - Static Initializers for Defined Queries
+ (CloudEnumerator*) enumeratorForIDs:(NSArray*)objectIDs 
            withTypes:(NSArray*)objectTypes 
             
{
    Query* query = [Query queryForIDs:objectIDs withTypes:objectTypes];
    QueryOptions* queryOptions = [QueryOptions queryForObjectIDs:objectIDs withTypes:objectTypes];
    EnumerationContext* enumerationContext = [EnumerationContext contextForObjectIDs:objectIDs withTypes:objectTypes];
    query.queryOptions = queryOptions;
    
    CloudEnumerator* enumerator = [[CloudEnumerator alloc]initWithEnumerationContext:enumerationContext withQuery:query withQueryOptions:queryOptions];
    [enumerator autorelease];
    
    return enumerator;
    
    
}
@end
