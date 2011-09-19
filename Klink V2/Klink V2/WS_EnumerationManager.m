//
//  WS_EnumerationManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "WS_EnumerationManager.h"
#import "ServerManagedResource.h"
#import "ApplicationSettings.h"
#import "Theme.h"
#import "GetAuthenticatorResponse.h"
#import "Photo.h"
@implementation WS_EnumerationManager
@synthesize queryQueue;

static  WS_EnumerationManager* sharedManager;  

#pragma mark - Initializers / Singleton Accessors
+ (WS_EnumerationManager*) getInstance {
    NSString* activityName = @"WS_EnumerationManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[super allocWithZone:NULL]init];
        } 
        [BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}

- (id) init {
    self.queryQueue = [[NSOperationQueue alloc] init];
    return self;
}

- (void)dealloc
{
    [self.queryQueue release];
    [super dealloc];
}

-(void) enumerateObjectsWithIds: (NSArray*)ids withQueryOptions:(QueryOptions*)queryOptions onFinishNotify:(NSString*)notificationTarget{
//    NSString* activityName = @"WS_EnumerationManager.enumerateObjectsWithIds:";
    
    
    //need to construct an asynchronous enumeration request
    EnumerationContext *enumerationContext = [[EnumerationContext alloc]init];
    enumerationContext.pageSize = [NSNumber numberWithInt:pageSize_PHOTO];
    enumerationContext.maximumNumberOfResults =[NSNumber numberWithInt:[ids count]];
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    
  
        Query* query = [Query queryWithIds:ids];
        query.queryoptions = queryOptions;
//        NSURL *url = [UrlManager getEnumerateURLForIDs:ids withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
        NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
        
        [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationTarget];
    
    
    
}


- (void)enumerateObjectsWithType:(NSString*)objectType maximumNumberOfResults:(NSNumber*)maxResults withQueryOptions:(QueryOptions *)queryOptions onFinishNotify:(NSString*)notificationTarget {
//    NSString* activityName = @"WS_EnumerationManager.enumerateObjectsWithType:";
    
    //need to construct an asynchronous enumeration request
    EnumerationContext *enumerationContext = [[EnumerationContext alloc]init];
    AuthenticationContext *authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    
    enumerationContext.maximumNumberOfResults = maxResults;
    enumerationContext.pageSize =[NSNumber numberWithInt:pageSize_PHOTO];
    
            Query* query = [Query queryWithObjectType:objectType];
        query.queryoptions = queryOptions;
        NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
        
        [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationTarget];

    
    
    
}

- (void) enumerateThemes:(NSNumber*)maximumNumberOfResults withQueryOptions:(QueryOptions*)queryOptions onFinishNotify:(NSString*)notificationID {
    
    [self enumerateObjectsWithType:tn_THEME maximumNumberOfResults:maximumNumberOfResults withQueryOptions:queryOptions onFinishNotify:notificationID];
    
}

- (void) getUser:(NSNumber*)userID
        onFinishNotify:(NSString*)notificationID{
    
    QueryOptions* queryOptions = [QueryOptions queryForUser:userID];
    [self enumerateObjectsWithIds:[NSArray arrayWithObject:userID] withQueryOptions:queryOptions onFinishNotify:notificationID];
}

- (void) enumerateFeeds:
           (NSNumber *)maximumNumberOfResults 
           withPageSize:(NSNumber *)pageSize 
            withQueryOptions:(QueryOptions *)queryOptions 
            onFinishNotify:(NSString *)notificationID 
            useEnumerationContext:(EnumerationContext *)enumerationContext 
            shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage {
    
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    if (enumerationContext == nil) {
        enumerationContext = [[EnumerationContext alloc]init];
        enumerationContext.pageSize = pageSize;
        enumerationContext.maximumNumberOfResults = maximumNumberOfResults;
        
    }
    
    
    if (authenticationContext != nil) {
        //need to be authenticated to enumerate feeds for a user
        
        Query* query = [Query queryFeedsForUser:authenticationContext.userid];
        query.queryoptions = queryOptions;
        NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
        [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:shouldEnumerateSinglePage];
    }
}

- (void) enumerateCaptionsForPhoto:
                    (Photo*)photo
                      withPageSize:(NSNumber*)pageSize
                  withQueryOptions:(QueryOptions*)queryOptions
                    onFinishNotify:(NSString*)notificationID
             useEnumerationContext:(EnumerationContext*)enumerationContext
         shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage  {
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    if (enumerationContext == nil) {
        enumerationContext = [[EnumerationContext alloc]init];
        enumerationContext.pageSize = pageSize;
        enumerationContext.maximumNumberOfResults =[NSNumber numberWithInt:maxsize_CAPTIONDOWNLOAD];
    }
    
    Query* query = [Query queryCaptionsForPhoto:photo.objectid];
    query.queryoptions = queryOptions;
    NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
    [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:shouldEnumerateSinglePage];
    
    
}


- (void) enumerateThemes: (NSNumber*)maximumNumberOfResults
            withPageSize:(NSNumber*)pageSize
        withQueryOptions:(QueryOptions*)queryOptions 
          onFinishNotify:(NSString*)notificationID
   useEnumerationContext:(EnumerationContext*)enumerationContext
shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage {
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    if (enumerationContext == nil) {
        enumerationContext = [[EnumerationContext alloc]init];
        enumerationContext.pageSize = pageSize;
        enumerationContext.maximumNumberOfResults = maximumNumberOfResults;
        
    }
    
    
        Query* query = [Query queryThemes];
        query.queryoptions = queryOptions;
        NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
        [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:shouldEnumerateSinglePage];

}


- (void) enumeratePhotosInTheme:(Theme*)theme withQueryOptions:(QueryOptions*)queryOptions onFinishNotify:(NSString*)notificationID useEnumerationContext:(EnumerationContext*)enumerationContext shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage{
    
//    NSString* activityName = @"WS_EnumerationManager.enumeratePhotosInTheme:";
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
    
    Query* query = [Query queryPhotosWithTheme:theme.objectid];
    query.queryoptions = queryOptions;
    NSURL *url = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
    [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationID shouldEnumerateSinglePage:shouldEnumerateSinglePage];
    
}
#pragma mark - Enumeration Result Handlers

- (void) onEnumerateComplete:(ASIHTTPRequest*)request {
    NSString* activityName = @"WS_EnumerationManager.onEnumerateComplete:";
    NSDictionary* response = [[request responseString] objectFromJSONString];
    
   
    
    EnumerationResponse* enumerationResponse = [[EnumerationResponse alloc]initFromDictionary:response];
//    EnumerationContext* enumerationContext = [enumerationResponse.enumerationContext retain];
    if (enumerationResponse.didSucceed == [NSNumber numberWithBool:YES]) {
        
        NSString* message = [NSString stringWithFormat:@"enumeration succeeded, returned: %@",[request responseString]];
        [BLLog v:activityName withMessage:message];
        NSDictionary* passedContext = [request userInfo];
        BOOL shouldEnumerateSinglePage = [[passedContext objectForKey:an_SHOULDENUMERATESINGLEPAGE] boolValue];
        
        //process primary & secondary results
        for (int i = 0; i < [enumerationResponse.primaryResults count]; i++) {
            [ServerManagedResource refreshWithServerVersion:[enumerationResponse.primaryResults objectAtIndex:i]];
        }
        
        for (int i = 0; i < [enumerationResponse.secondaryResults count]; i++) {
            [ServerManagedResource refreshWithServerVersion:[enumerationResponse.secondaryResults objectAtIndex:i]];
        }
        
        Query* query = [passedContext objectForKey:an_QUERY];        
        EnumerationContext* newEnumerationContext = enumerationResponse.enumerationContext;
        NSString* notificationTarget = nil;
        
        
        //need to now re-execute for the next enumeration context
        if (enumerationResponse.enumerationContext.isDone == [NSNumber numberWithBool:YES] ||
            shouldEnumerateSinglePage) {
            //enumeration is complete, or the user context specified says that only a single enumerations hould be executed
            if ([passedContext objectForKey:an_ONFINISHNOTIFY] != [NSNull null]) {
                notificationTarget = [passedContext objectForKey:an_ONFINISHNOTIFY];
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:enumerationResponse.enumerationContext forKey:an_ENUMERATIONCONTEXT];
                NSNotificationCenter *notifcationCenter = [NSNotificationCenter defaultCenter];
                
                [notifcationCenter postNotificationName:notificationTarget object:self userInfo:userInfo];
            }
            
            
            NSString* message = [NSString stringWithFormat:@"enumeration finished"];
                [BLLog v:activityName withMessage:message];        
        }
        else {
           
            AuthenticationContext* newAuthenticationContext = [[AuthenticationManager getInstance]getAuthenticationContext];
            
            NSString* notificationTarget = nil;
            if ([passedContext objectForKey:an_ONFINISHNOTIFY] != [NSNull null]) {
                notificationTarget = [passedContext objectForKey:an_ONFINISHNOTIFY];
            }

            
            NSURL* newURL = [UrlManager getEnumerateURLForQuery:query withEnumerationContext:newEnumerationContext withAuthenticationContext:newAuthenticationContext];
            
            NSString* message = [NSString stringWithFormat:@"enumeration remains open, with %@ results downloaded",enumerationResponse.enumerationContext.numberOfResultsReturned];
            
            [BLLog v:activityName withMessage:message];
            [self enumerate:newURL withQuery:query withEnumerationContext:newEnumerationContext onFinishNotify:notificationTarget];
            

        }
//TODO: memory leak        
//        [query release];
//        [newEnumerationContext release];
//        
//        if (notificationTarget != nil) {
//            [notificationTarget release];
//        }
    
    
    }
    else {
        //enumeration did not succeed
        NSString* message =[NSString stringWithFormat:@"enumeration failed with error: ",enumerationResponse.errorMessage];
        [BLLog e:activityName withMessage:message];
    }
}

- (void) onEnumerateFail:(ASIHTTPRequest*)request {
    NSString* activityName = @"WS_EnumerationManager.onEnumerateFail:";
    NSURL *url = [request.userInfo objectForKey:@"URL"];
    
    NSString* message = [NSString stringWithFormat:@"Enumeration failed for URL: %@",url];
    [BLLog e:activityName withMessage:message];
    
    NSDictionary* passedContext = [request userInfo];
    if ([passedContext objectForKey:an_ONFINISHNOTIFY] != [NSNull null]) {
        NSString* notificationTarget = [passedContext objectForKey:an_ONFINISHNOTIFY];
        NSNotificationCenter *notifcationCenter = [NSNotificationCenter defaultCenter];
        
        [notifcationCenter postNotificationName:notificationTarget object:self userInfo:nil];
    }
}

#pragma mark - Enumeration Executers
- (void) enumerate:(NSURL*)url withQuery:(Query*)query withEnumerationContext:(EnumerationContext*)enumerationContext
    onFinishNotify:(id)notificationTarget{
       
    [self enumerate:url withQuery:query withEnumerationContext:enumerationContext onFinishNotify:notificationTarget shouldEnumerateSinglePage:NO];
}


- (void) enumerate:(NSURL*)url withQuery:(Query*)query withEnumerationContext:(EnumerationContext *)enumerationContext onFinishNotify:(id)notificationTarget shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage {
    if (enumerationContext.isDone != [NSNumber numberWithBool:YES]) {
        
        //Construct the enumeration user info data structure which is passed through to the response handler
        NSMutableDictionary* passedContext = [NSMutableDictionary dictionaryWithObject:url forKey:@"URL"];
        [query retain];
        [enumerationContext retain];
        [notificationTarget retain];
        [passedContext setObject:query forKey:an_QUERY];
        [passedContext setObject:enumerationContext forKey:an_ENUMERATIONCONTEXT];
        [passedContext setObject:[NSNumber numberWithBool:shouldEnumerateSinglePage] forKey:an_SHOULDENUMERATESINGLEPAGE];
        if (notificationTarget != nil) {
            [passedContext setObject:notificationTarget forKey:an_ONFINISHNOTIFY];
        }
        
        
        
        [self execute:url onFinishSelector:@selector(onEnumerateComplete:) 
       onFailSelector:@selector(onEnumerateFail:) withUserInfo:passedContext];
        
    }
}

- (void) execute:(NSURL*)url onFinishSelector:(SEL)onfinishselector onFailSelector:(SEL)onfailselector withUserInfo:(NSDictionary*)userInfo {    
    NSString* activityName = @"WS_EnumerationManager.execute:";

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];    
    [request setUserInfo:userInfo];
    [request setDidFinishSelector:onfinishselector];
    [request setDidFailSelector:onfailselector];
    [request setTimeOutSeconds:timeout_ENUMERATION];
    [self.queryQueue addOperation:request];
    
    NSString *message = [[NSString alloc] initWithFormat:@"submitted query at url: %@",url];
    [BLLog v:activityName withMessage:message];
    [message release];

}


#pragma mark - Authentication Mechanisms
//will user Facebook access token to retrieve a valid session token for the currently logged-in user
- (void) getAuthenticatorToken:(NSNumber*)facebookID withName:(NSString*)name withFacebookAccessToken:(NSString*)facebookAccessToken withFacebookTokenExpiry:(NSDate*)date onFinishNotify:(NSString*)notificationID {
    
//    NSString* activityName = @"WS_EnumerationManager.getAuthenticatorToken:";
    NSURL* url = [UrlManager getAuthenticationURL:facebookID withName:name withFacebookAccessToken:facebookAccessToken withFacebookTokenExpiry:date];
    
    NSMutableDictionary* passedContext = [[NSMutableDictionary alloc]init];
    [passedContext setValue:notificationID forKey:an_ONFINISHNOTIFY];
    
    [self execute:url onFinishSelector:@selector(onGetAuthenticatorFinished:) onFailSelector:@selector(onGetAuthenticatorFailed:) withUserInfo:passedContext];
    
   
    
    
}

- (void) onGetAuthenticatorFinished:(ASIHTTPRequest*)request {
    NSString* activityName = @"WS_EnumerationManager.onGetAuthenticatorFinished:";
    
    //need to pull the authenticator and send it to the authentication manager
    NSString* jsonResponse = [request responseString];
    NSDictionary* jsonDictionary = [jsonResponse objectFromJSONString];
    
    GetAuthenticatorResponse* getAuthenticatorResponse = [[GetAuthenticatorResponse alloc]initFromDictionary:jsonDictionary];
    NSDictionary* userInfo = [request userInfo];
    if ([getAuthenticatorResponse.didSucceed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        
        NSString* notificationID = [userInfo valueForKey:an_ONFINISHNOTIFY];
        
        NSMutableDictionary* notificationUserInfo = [[NSMutableDictionary alloc]init];
        [notificationUserInfo setValue:getAuthenticatorResponse.authenticationcontext forKey:an_AUTHENTICATIONCONTEXT];
        [notificationUserInfo setValue:getAuthenticatorResponse.user forKey:an_USER];
        
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:notificationID object:self userInfo:notificationUserInfo];
        
        
    }
    else {
    
        NSString* message = [NSString stringWithFormat:@"request failed due to %@",getAuthenticatorResponse.errorMessage];
        [BLLog e:activityName withMessage:message];
    }
    
    [getAuthenticatorResponse release];
    [userInfo release];
    
    
}

- (void) onGetAuthenticatorFailed:(ASIHTTPRequest*)request {
    
}

//Receives the result of the enumeration request, parsees outbound enumeration context
//and continues to pull until done.
- (void) enumerateObjectsWithIds_Complete:(ASIHTTPRequest*)request{
     NSString* activityName = @"WS_EnumerationManager.enumerateObjectsWithIds_Complete:";
    //TODO: Implement parsing of enumeration context values
    
    //Deserialize enumeration result
    NSDictionary* response = [[request responseString] objectFromJSONString];
    
    NSString* message = [[NSString alloc]initWithFormat:@"query completed for url: %@",[request responseString]];
    [BLLog v:activityName withMessage:message];
    [message release];
    
    EnumerationResponse* enumerationResponse = [[EnumerationResponse alloc]initFromDictionary:response];
    
    //At this point objects are deserialized, now need to commit them to the store
    for (int i = 0; i < [enumerationResponse.primaryResults count]; i++) {
        [DataLayer commitResource:[enumerationResponse.primaryResults objectAtIndex:i] calledBy:self];
    }
    
    //TODO: error state, how should this method behave if it gets malformed text back?
}

- (void) requestWentWrong:(ASIHTTPRequest*)request {
    NSString* activityName = @"WS_EnumerationManager.requestWentWrong:";
    NSError* response = [request error];
    NSString* message = [[NSString alloc]initWithFormat:@"query failed for url: %@ due to %@:",[request originalURL], response];
    [BLLog e:activityName withMessage:message];
}

+(NSString*) getTypeName {
    return @"WS_EnumerationManager";
}
@end
