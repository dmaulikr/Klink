//
//  ResourceContext.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ResourceContext.h"
#import "PlatformAppDelegate.h"
#import "Query.h"
#import "EnumerationContext.h"
#import "Attributes.h"
#import "UrlManager.h"
#import "CallbackResult.h"
#import "Request.h"
#import "RequestManager.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "Response.h"
#import "EnumerationResponse.h"
#import "GetAuthenticatorResponse.h"
#import "Macros.h"
#import "Types.h"

#define kCallback   @"callback";
@implementation ResourceContext
@synthesize managedObjectContext = __managedObjectContext;

static ResourceContext* sharedInstance;
+ (id) instance {
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[super allocWithZone:NULL]init];
           
        }
        return sharedInstance;
    }
}


- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    __managedObjectContext = appDelegate.managedObjectContext;
    return __managedObjectContext;
                                                            
}

 
  
- (BOOL) doesExistInLocalStore:(NSNumber *)resourceID {
    return NO;
}

- (Request*) requestFor:(Resource*)resource forOperation:(RequestOperation*)opcode onFinishCallback:(Callback*)callback {
 
    Request* request = [Request createInstanceOfRequest];
    [[request initFor:resource.objectid withOperation:(int)opcode withUserInfo:nil onSuccess:callback onFailure:callback]autorelease];
    
    return request;
}

//saves all pending changes to the local persistence store
//and then attempts to push all appropriate changes up to the cloud
- (void) save:(BOOL)saveToCloud 
     onFinishCallback:(Callback *)callback {
    
    NSMutableArray* resourcesToCreateInCloud = [[NSMutableArray alloc]init];
    NSMutableArray* resourceTypesToCreateInCloud = [[NSMutableArray alloc]init];
    
    NSMutableArray* resourcesToUpdateInCloud = [[NSMutableArray alloc]init];
    NSMutableArray* resourcesToDeleteInCloud = [[NSMutableArray alloc]init];
    
    NSMutableArray* createRequests = [[NSMutableArray alloc]init];
    
    
    //get all pending changes
    NSSet* insertedObjects = [self.managedObjectContext insertedObjects];
    NSSet* deletedObjects = [self.managedObjectContext deletedObjects];
    NSSet* updatedObjects = [self.managedObjectContext updatedObjects];
    
    //process created objects
    NSArray* insertedObjectsArray = [insertedObjects allObjects];
    for (int i = 0; i < [insertedObjectsArray count]; i++) {
        
        Resource* resource = [insertedObjectsArray objectAtIndex:i];
        //mark the object as being "dirty"
        if ([resource isKindOfClass:[Resource class]]) {
            if ([resource shouldResourceBeSynchronizedToCloud]) {
                [resourcesToCreateInCloud addObject:resource];
                [resourceTypesToCreateInCloud addObject:resource.objecttype];
               
                //mark newly created object as being dirty, will become clean when
                //it has been successfully created on the server
                [resource markAsDirty];
            }
        }
    }
    
    //process updated objects
    NSArray* updatedObjectsArray = [updatedObjects allObjects];
    for (int i = 0; i < [updatedObjectsArray count]; i++) {
        Resource* resource = [updatedObjectsArray objectAtIndex:i];
        
        
        if ([resource shouldResourceBeSynchronizedToCloud]) {
            [resourcesToUpdateInCloud addObject:resource];
            [resource markAsDirty];
           
        }
    }
    
    
    //process deleted objects
    NSArray* deletedObjectsArray = [deletedObjects allObjects];
    for (int i = 0; i < [deletedObjectsArray count]; i++) {
        Resource* resource = [deletedObjectsArray objectAtIndex:i];
        if ([resource shouldResourceBeSynchronizedToCloud]) {
            [resourcesToDeleteInCloud addObject:resource];
            [resource markAsDirty];
        }
    }
    
    //now we commit the change to the store
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    
    if (error != nil) {
        //todo: log error on saving the context
    }
    
    
    AuthenticationContext* authenticationContext = [[AuthenticationManager instance] contextForLoggedInUser];
    RequestManager* requestManager = [RequestManager instance];
    if (authenticationContext != nil) {
        if ([resourcesToCreateInCloud count] > 0) {
            //we create a bulk set of create requests
            NSURL* url = [UrlManager urlForCreateObjects:resourcesToCreateInCloud withObjectTypes:resourceTypesToCreateInCloud withAuthenticationContext:authenticationContext];
            for (Resource* resource in resourcesToCreateInCloud) {
                Request* request = [self requestFor:resource forOperation:kCREATE onFinishCallback:callback];
                
                //we set each requessts url to be the same
                request.url = [url absoluteString];
                
                [createRequests addObject:request];
            }
            [requestManager submitRequests:createRequests];
        }
    }
    else {
        //TODO: log warning that skipping cloud upload because of unauthenticated state
    }
    
    //TODO: need to put in code to upload updates and deletes to the cloud
}

- (void) executeEnumeration:(NSURL*)url 
           onFinishSelector:(SEL)onfinishselector 
             onFailSelector:(SEL)onfailselector 
               withUserInfo:(NSDictionary*)userInfo {
    
    
}

//Executes the passed in query against the cloud, calls back according to the callback
//parameter after the enumeration has completed
- (void) enumerate:(Query *)query
    useEnumerationContext:(EnumerationContext*)enumerationContext 
    shouldEnumerateSinglePage:(BOOL)shouldEnumerateSinglePage 
    onFinishNotify:(Callback *)callback {
    
    if (enumerationContext == nil) {
        enumerationContext = [[EnumerationContext alloc]init];
    }
    
    
    
    //TODO: need to hook up to Authentication Manager
    AuthenticationContext* authenticationContext = [[AuthenticationContext alloc]init];
    
    NSURL* url = [UrlManager urlForQuery:query withEnumerationContext:enumerationContext withAuthenticationContext:authenticationContext];
    
    if (enumerationContext.isDone != [NSNumber numberWithBool:YES]) {
        
        //Construct the enumeration user info data structure which is passed through to the response handler
        NSMutableDictionary* passedContext = [NSMutableDictionary dictionaryWithObject:url forKey:@"URL"];
        [query retain];
        [enumerationContext retain];
        [callback retain];
        [passedContext setObject:query forKey:QUERY];
        [passedContext setObject:enumerationContext forKey:ENUMERATIONCONTEXT];
        [passedContext setObject:[NSNumber numberWithBool:shouldEnumerateSinglePage] forKey:SHOULDENUMERATESINGLEPAGE];
        [passedContext setObject:callback forKey:ONFINISHCALLBACK];

        [self executeEnumeration:url 
                onFinishSelector:@selector(onEnumerateComplete:) 
                onFailSelector:@selector(onEnumerateFail:) 
                withUserInfo:passedContext];
        
        [enumerationContext release];
    }

    
    
}

#pragma mark - Authentication Enumeration
- (void) getAuthenticatorToken:(NSNumber *)facebookID withName:(NSString *)displayName withFacebookAccessToken:(NSString *)facebookAccessToken withFacebookTokenExpiry:(NSDate *)date onFinishNotify:(Callback *)callback {
    NSString* activityName = @"ResourceContext.getAuthenticatorToken:";
   
 
    Request* request = (Request*)[Request createInstanceOfRequest];
   
    
    request.statuscode =[NSNumber numberWithInt:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kAUTHENTICATE];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    NSURL* url = [UrlManager urlForAuthentication:facebookID withName:displayName withFacebookAccessToken:facebookAccessToken withFacebookTokenExpiry:date];
    
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting Authentication request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];
    
}

#pragma mark - Data Access Methods
- (Resource*)resourceWithType:(NSString *)typeName withID:(NSNumber *)resourceID {
    Resource* retVal = nil;
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%@=%@",RESOURCEID, resourceID];    
        [request setPredicate:predicate];
        
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];

        if (results != nil && [results count] > 0) {
            retVal = [results objectAtIndex:0];
        }
        
       

        
    }
    else {
        //TODO: log an error message here
        //error condition, type doesn't exist
        
    }
    return retVal;
}
 
- (Resource*) singletonResourceWithType:(NSString*)typeName {
    NSString* activityName = @"ResourceContext.singletonResourceWithType:";
    Resource* retVal = nil;
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
        [request setEntity:entityDescription];
        
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        if (results != nil && [results count] == 1) {
            retVal = [results objectAtIndex:0];
        }
        else if (results != nil && [results count] > 1) {
            LOG_RESOURCECONTEXT(1,@"@%@%",activityName,@"Singleton object either doesn't exist, or has multiple instances in the database");
        }
        
               
        
    }
    else {
         LOG_RESOURCECONTEXT(1,@"@%Resource type %@ doesn't exist",activityName,typeName);
    }
    return retVal;

}

#pragma mark - Utility Methods
- (void) markResourceAsBeingSynchronized:(NSNumber *)resourceID withResourceType:(NSString*)type {
    Resource* resource = [self resourceWithType:type withID:resourceID];
    
    [resource markAsClean];
    
    [self save:YES onFinishCallback:nil];
    
}

- (void) markResourcesAsBeingSynchronized:(NSArray *)resources withResourceTypes:(NSArray*)resourceTypes {
    
    int count = 0;
    for (NSNumber* resourceid in resources) {
        NSString* resourceType = [resourceTypes objectAtIndex:count];
        Resource* resource = [self resourceWithType:resourceType withID:resourceid];
        [resource markAsClean];
    }
    [self save:YES onFinishCallback:nil];
}



#pragma mark - Async Event Handlers
- (void) onEnumerateComplete : (CallbackResult*) result {
    //called when an enumerate methods completes
    Response* response = result.response;
    
    
    if ([response isKindOfClass:[EnumerationResponse class]]) {
        //processing enumerationg results
        
        
    }

                
                                                              
                                                        
}

- (void) onEnumerateFailed : (CallbackResult*) result {
    
}
@end
