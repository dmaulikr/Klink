//
//  WS_EnumerationManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Test_Project_2AppDelegate.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "EnumerationContext.h"
#import "ASIHTTPRequest.h"
#import "UrlManager.h"
#import "JSONKit.h"
#import "EnumerationResponse.h"
#import "Query.h"
@interface WS_EnumerationManager : NSObject {
    NSOperationQueue *queryQueue;
    
}

@property (nonatomic,retain) NSOperationQueue *queryQueue;

- (id) init;
- (void) enumerateObjectsWithIds: (NSArray*)ids  
                withQueryOptions:(QueryOptions*)queryOptions
                  onFinishNotify:(NSString*)notificationTarget;
- (void) enumerateObjectsWithType:(NSString*)objectType 
           maximumNumberOfResults:(NSNumber*)maxResults 
           withQueryOptions:(QueryOptions*)queryOptions
           onFinishNotify:(NSString*)notificationTarget;

- (void) execute:(NSURL*)url onFinishSelector:(SEL)onfinishselector onFailSelector:(SEL)onfailselector withUserInfo:(NSDictionary*)userInfo;

- (void) enumerate:(NSURL*)url withQuery:(Query*)query withEnumerationContext:(EnumerationContext*)enumerationContext  onFinishNotify:notificationTarget;

+ (NSString*) getTypeName;
+ (WS_EnumerationManager*) getInstance;

@end
