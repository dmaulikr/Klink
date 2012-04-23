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
#import "IDGenerator.h"
#import "DateTimeHelper.h"
#import "EventManager.h"

#define kCallback   @"callback"
#define kTHREAD     @"thread"
#define kCONTEXT    @"context"

@implementation ResourceContext

@synthesize managedObjectContext = __managedObjectContext;

@synthesize managedObjectContexts = m_managedObjectContexts;

@synthesize managedObjectContextsLock = m_lock;

static ResourceContext* sharedInstance;
//static NSMutableDictionary* managedObjectContexts;

+ (id) instance {
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[super allocWithZone:NULL]init];
            [sharedInstance clean];
        }
        return sharedInstance;
    }
}


- (NSManagedObjectContext*)managedObjectContext {
   // NSString* activityName = @"ResourceContext.managedObjectContext:";
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    NSThread* thread = [NSThread currentThread];
    
    if ([thread isMainThread]) {
       // LOG_RESOURCECONTEXT(0, @"%@Main thread being returned managedObjectContext at memory %p",activityName,appDelegate.managedObjectContext);
        return appDelegate.managedObjectContext;
    }
    else {
        //created from background thread
        // a key to cache the context for the given thread
        NSString *threadKey = [NSString stringWithFormat:@"%p", thread];
        
        if ( [self.managedObjectContexts objectForKey:threadKey] == nil ) {
            // create a context for this thread
            NSManagedObjectContext *threadContext = [[[NSManagedObjectContext alloc] init] autorelease];
            [threadContext setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
            [threadContext setMergePolicy:NSRollbackMergePolicy];
           // [threadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            //[threadContext setMergePolicy:NSOverwriteMergePolicy];
          //  LOG_RESOURCECONTEXT(0, @"%@Background thread being returned context at address %p",activityName,threadContext);
            NSUndoManager* contextUndoManager = [[NSUndoManager alloc]init];
            [contextUndoManager setLevelsOfUndo:20];
            threadContext.undoManager = contextUndoManager;
            [contextUndoManager release];

            
            // cache the context for this thread
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:thread forKey:kTHREAD];
            [userInfo setValue:threadContext forKey:kCONTEXT];
            
            //we grab the lock
            [self.managedObjectContextsLock lock];
            [self.managedObjectContexts setObject:userInfo forKey:threadKey];
            [self.managedObjectContextsLock unlock];
            [userInfo release];
            return threadContext;
        }
        else {
            NSDictionary* userInfo = [self.managedObjectContexts objectForKey:threadKey];
          //  LOG_SECURITY(0, @"%@Grabbed context at address %p",activityName,[userInfo objectForKey:kCONTEXT]);
            return [userInfo objectForKey:kCONTEXT];
        }
    }
    
    
                                                            
}


- (id) init {
    self = [super init];
    if (self) {
        NSMutableDictionary* d = [[NSMutableDictionary alloc]init];
        self.managedObjectContexts = d;
        [d release];
        
        NSLock* l = [[NSLock alloc]init];
        self.managedObjectContextsLock = l;
        [l release];
        
        
               
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(onContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(onThreadDidExit:) name:NSThreadWillExitNotification object:nil];
        
    }
    return self;
}

#pragma mark - NSNotification Handlers
- (void) onThreadDidExit:(NSNotification*)notification {
    NSString* activityName = @"ResourceContext.onThreadDidExit:";
    NSThread* thread = notification.object;
    NSString *threadKey = [NSString stringWithFormat:@"%p", thread];
    int threadCount = [self.managedObjectContexts count];
    LOG_RESOURCECONTEXT(0, @"%@Removing thread managed object context with address %@ leaving %d thread contexts in pool",activityName,threadKey, threadCount-1);
    
    //grab the lock
    [self.managedObjectContextsLock lock];
    [self.managedObjectContexts removeObjectForKey:threadKey];
    [self.managedObjectContextsLock unlock];
    LOG_RESOURCECONTEXT(0, @"%@Removed thread managed object context!",activityName);
}

- (void) onContextDidSave:(NSNotification*)notification {
    NSString* activityName = @"ResourceContext.onContextDidSave:";
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext* sender = notification.object;
    NSMutableSet* keysToRemove = [[NSMutableSet alloc]init];
    NSThread* currentThread = [NSThread currentThread];
    
    if (![currentThread isMainThread]) {
        //lets propagate the notification to all contexts
        NSManagedObjectContext* appDelContext = appDelegate.managedObjectContext;
        LOG_RESOURCECONTEXT(0, @"%@ Received NSManagedObjectContextDidSaveNotification from %p on background thread, propagating to context %p on main thread",activityName,sender,appDelContext);
        
        [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];
    }
    
    
     [self.managedObjectContextsLock lock];
    for (NSString* key in self.managedObjectContexts) {
        //grab le lock
       
        NSDictionary* userInfo = [self.managedObjectContexts objectForKey:key];
       
        NSManagedObjectContext* context = [userInfo objectForKey:kCONTEXT];
        NSThread* thread = [userInfo objectForKey:kTHREAD];
        
        //let us first see if the thread is even activ
        if (thread != nil && !thread.isCancelled) {
            if (context != nil && 
                context != sender) {
                LOG_RESOURCECONTEXT(0, @"%@ Received NSManagedObjectContextDidSaveNotification from %p propagating to context %p on background thread",activityName,sender, context);
                [context mergeChangesFromContextDidSaveNotification:notification];
            }
        }

        
    }
     [self.managedObjectContextsLock unlock];

    [keysToRemove release];
}

  
- (BOOL) doesExistInLocalStore:(NSNumber *)resourceID {
    return NO;
}

- (Request*) requestFor:(Resource*)resource 
           forOperation:(RequestOperation)opcode 
  withChangedAttributes:(NSArray*)changedAttributesList 
       onFinishCallback:(Callback*)callback 
      trackProgressWith:(id<RequestProgressDelegate>)delegate {
 
    Request* request = [Request createInstanceOfRequest];
    [request initFor:resource.objectid withTargetObjectType:resource.objecttype withOperation:(int)opcode withChangedAttributes:changedAttributesList withUserInfo:nil onSuccess:callback onFailure:callback];
    request.delegate = delegate;
    return request;
}

- (void) insert:(Resource *)resource {
    [self.managedObjectContext insertObject:resource];
    
    if (!resource.iswebservicerepresentation) {
        //mark the object as being completely dirty
        [resource markAsDirty];
    }
}



///Given a specified obejct id and key, it will mark the object for removal
//within this instances managedobjectcontext
- (void) delete:(NSNumber *)objectID withType:(NSString *)type
{
    NSString* activityName = @"ResourceContext.deleteObject:";
    Resource* resource = [self resourceWithType:type withID:objectID];
    
    if (resource != nil) 
    {
        [self.managedObjectContext deleteObject:resource];
        LOG_RESOURCECONTEXT(0, @"%@Marked object id: %@ with object type:%@ for deletion",activityName,objectID,type);
    }
    else {
        LOG_RESOURCECONTEXT(0, @"%@Could not find object id: %@ with object type:%@ to delete",activityName,objectID,type);
        
    }
}

//saves all pending changes to the local persistence store
//and then attempts to push all appropriate changes up to the cloud
- (NSArray*) save:(BOOL)saveToCloud 
     onFinishCallback:(Callback *)callback
    trackProgressWith:(id<RequestProgressDelegate>)progressDelegate
{
    
    NSString* activityName = @"ResourceContext.save:";
    
    
    
    NSMutableArray* retVal = [[[NSMutableArray alloc]init]autorelease];
    NSMutableArray* resourcesToCreateInCloud = [[NSMutableArray alloc]init];
    NSMutableArray* resourceIDsToCreateInCloud = [[NSMutableArray alloc]init];
    NSMutableArray* resourceTypesToCreateInCloud = [[NSMutableArray alloc]init];
   // NSMutableArray* resourcesToDeleteInCloud = [[NSMutableArray alloc]init];
    
   
    
    NSMutableArray* createRequests = [[NSMutableArray alloc]init];
    NSMutableArray* putRequests = [[NSMutableArray alloc]init];
    NSMutableArray* deleteRequests = [[NSMutableArray alloc]init];
    
    //get all pending changes
    NSSet* insertedObjects = [self.managedObjectContext insertedObjects];
    NSSet* updatedObjects = [self.managedObjectContext updatedObjects];
    NSSet* deletedObjects = [self.managedObjectContext deletedObjects];
    
    //process created objects
    NSArray* insertedObjectsArray = [insertedObjects allObjects];
    for (int i = 0; i < [insertedObjectsArray count]; i++) {
        
        Resource* resource = [insertedObjectsArray objectAtIndex:i];
        //mark the object as being "dirty"
        if ([resource isKindOfClass:[Resource class]]) {
            
            //generate objectid,datecreated and datemodified attributes for the objects
            if (resource.objectid == nil ||
                [resource.objectid isEqualToNumber:[NSNumber numberWithInt:0]]) {
                
                resource.objectid = [[IDGenerator instance ]generateNewId:resource.objecttype];
            }
            
            NSDate* currentDate = [NSDate date];
            if (resource.datecreated == nil||
                [resource.datecreated isEqualToNumber:[NSNumber numberWithInt:0]]) {
                resource.datecreated = [NSNumber numberWithDouble:[DateTimeHelper convertDateToDouble:currentDate]];
            }
            
            if (resource.datemodified == nil ||
                [resource.datemodified isEqualToNumber:[NSNumber numberWithInt:0]]) {
                resource.datemodified = [NSNumber numberWithDouble:[DateTimeHelper convertDateToDouble:currentDate]];
            }
            
            if (resource.typeinstancedata == nil) {
                [resource createTypeInstanceData:self];
            }
            
            if (resource.attributeinstancedata == nil ||
                [resource.attributeinstancedata count] == 0) {
                [resource createAttributeInstanceData:self];
            }
            
            
            //determine which, if any of the newly created objects should be synchronized
            if (saveToCloud) {
                if ([resource shouldResourceBeSynchronizedToCloud]) {
                    [resourcesToCreateInCloud addObject:resource];
                    [resourceIDsToCreateInCloud addObject:resource.objectid];
                    [resourceTypesToCreateInCloud addObject:resource.objecttype];
                    
                    //mark newly created object as being dirty, will become clean when
                    //it has been successfully created on the server
                    [resource markAsDirty];
                }
            }
            
            

        }
    }
    
    //process updated objects
    NSArray* updatedObjectsArray = [updatedObjects allObjects];
    
    if (saveToCloud) {
        for (int i = 0; i < [updatedObjectsArray count]; i++) {
            
            Resource* resource = [updatedObjectsArray objectAtIndex:i];
            
            if ([resource isKindOfClass:[Resource class]]) {
                if ([resource shouldResourceBeSynchronizedToCloud]) {
                    //get a list of attributes that are changed on the object
                    NSArray* changedAttributes = [resource changedAttributesToSynchronizeToCloud];
                    Request* request = nil;
                    if ([changedAttributes count] > 0) 
                    {
                        
                        
                        request = [self requestFor:resource forOperation:kMODIFY withChangedAttributes:changedAttributes onFinishCallback:callback
                                 trackProgressWith:progressDelegate];
                        [resource markAsDirty:changedAttributes];
                        if (request != nil) {
                            //we append the changed attribute names to the request
                            //[request setChangedAttributesList:changedAttributes];
                            
                            AuthenticationContext* authenticationContext = [[AuthenticationManager instance] contextForLoggedInUser];
                            
                            //we need to calculate the url for the request
                            if (request.operationcode ==[NSNumber numberWithInt:kMODIFY]) {
                                NSDictionary* attributeOperations = [request putAttributeOperations];
                                NSArray* attributeNames = [attributeOperations allKeys];
                                NSMutableArray* attributeValues = [[NSMutableArray alloc]initWithCapacity:[attributeNames count]];
                                NSMutableArray* attributeOperationCodes = [[NSMutableArray alloc]initWithCapacity:[attributeNames count]];
                                
                                for (NSString* attributeName in attributeNames) {
                                    PutAttributeOperation* putOperation = [attributeOperations valueForKey:attributeName];
                                    [attributeValues addObject:putOperation.value];
                                    [attributeOperationCodes addObject:[NSNumber numberWithInt:putOperation.operationCode]];
                                }
                                
                                //now all of our arrays are populated we can generate the url
                                request.url = [[UrlManager urlForPutObject:request.targetresourceid withObjectType:request.targetresourcetype withAttributes:attributeNames withAttributeValues:attributeValues withOperationCodes:attributeOperationCodes withAuthenticationContext:authenticationContext]absoluteString];
                                
                                [attributeValues release];
                                [attributeOperationCodes release];
                            }
                            [retVal addObject:request];
                            [putRequests addObject:request];
                        }
                    }
                    
                } 
            }
            
            
        }
    }
    
    //let us process the deletes
    NSArray* deletedObjectsArray = [deletedObjects allObjects];
    if ([deletedObjects count] > 0 &&
        saveToCloud == YES) 
    {
        //we have deleted objects, and we are going to be saving to the cloud
        for (int i = 0; i < [deletedObjects count]; i++) 
        {
            Resource* resource = [deletedObjectsArray objectAtIndex:i];
            if ([resource isKindOfClass:[Resource class]]) 
            {
                //it is an actual Resource that was deleted
                if ([resource shouldResourceBeSynchronizedToCloud]) 
                {
                    AuthenticationContext* authenticationContext = [[AuthenticationManager instance] contextForLoggedInUser];
                    //we should post the delete of this object to the cloud
                    Request* request = [self requestFor:resource forOperation:kDELETE withChangedAttributes:nil onFinishCallback:callback trackProgressWith:progressDelegate];
                    //lets now get the url for the request
                    request.url = [[UrlManager urlForDeleteObject:request.targetresourceid withObjectType:request.targetresourcetype withAuthenticationContext:authenticationContext] absoluteString];
                    //we got the url now we need to add it to the request array
                    [deleteRequests addObject:request];
                    [retVal addObject:request];
                }
            }
        }
    }
    

    //now we commit the change to the store
    //let us raise events
    EventManager* eventManager = [EventManager instance];
    [eventManager raiseEventsForInsertedObjects:insertedObjects];
    [eventManager raiseEventsForUpdatedObjects:updatedObjects];
    [eventManager raiseEventsForDeletedObjects:deletedObjects];

    NSError* error = nil;
    
    [self.managedObjectContext processPendingChanges];
    int undoLevels = [self.managedObjectContext.undoManager groupingLevel];
    if (undoLevels > 1) {

        LOG_REQUEST(0, @"%@Detected open undo group, closing it and then saving",activityName);
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    
    [self.managedObjectContext processPendingChanges];
    
    //we loop through all updated objects now to ensure we have the latest versions
  //  updatedObjects = [self.managedObjectContext updatedObjects];
//    NSArray* uArray = [updatedObjects allObjects];
//    for (NSManagedObject* object in uArray) {
//       [self.managedObjectContext refreshObject:object mergeChanges:YES];
//    }
    
    
    [self.managedObjectContext save:&error];
    
    if (error != nil) {
        LOG_RESOURCECONTEXT(1, @"%@Error when saving data to persistence store:%@",activityName,error);
        NSArray* conflictList = [error.userInfo objectForKey:@"conflictList"];
        for (NSMergeConflict* conflict in conflictList) {
            NSManagedObject* conflictingObject = conflict.sourceObject;            
            NSString* entityName = [conflictingObject.entity name];
            
            if ([entityName isEqualToString:ATTRIBUTEINSTANCEDATA]) {
                AttributeInstanceData* aid = (AttributeInstanceData*)conflictingObject;
                
                NSString* attributeName = aid.attributename;
                LOG_RESOURCECONTEXT(2, @"%@Conflicting Attribute Instance Type forAttributeName:%@",activityName,attributeName);
                
            }
            else if ([entityName isEqualToString:TYPEINSTANCEDATA]) {
                TypeInstanceData* tid = (TypeInstanceData*)conflictingObject;
                NSString* objectTypeName = tid.typename;
                LOG_RESOURCECONTEXT(1, @"%@Conflicting Type Instance Type forTypeName:%@",activityName,objectTypeName);
            }
            else  {
                Resource* resource = (Resource*)conflictingObject;
                LOG_RESOURCECONTEXT(1,@"%@Conflicting Object With Type:%@ and ID:%@",activityName,resource.objecttype,resource.objectid);
            }
            
        }
    }
    else {
         
        if (saveToCloud) {
            int numberOfCreates = [resourcesToCreateInCloud count];
            int numberOfUpdates = [putRequests count];
            
            LOG_RESOURCECONTEXT(0, @"%@Saved changes to persistence store successfully, which resulted in  %d create operations, and %d put operations with the cloud",activityName,numberOfCreates,numberOfUpdates);
            
            //process  requests
            AuthenticationContext* authenticationContext = [[AuthenticationManager instance] contextForLoggedInUser];
            RequestManager* requestManager = [RequestManager instance];
            
            if (authenticationContext != nil) {
                
                //process creates
                if ([resourcesToCreateInCloud count] > 0) {
                    
                    //we create a bulk set of create requests
                    NSURL* url = [UrlManager urlForCreateObjects:resourceIDsToCreateInCloud withObjectTypes:resourceTypesToCreateInCloud withAuthenticationContext:authenticationContext];
                    for (Resource* resource in resourcesToCreateInCloud) {
                        //we need to add the attributes that were created on the object
                        NSArray* changedAttributes = [resource attributesWithValues];
                        
                        Request* request = [self requestFor:resource forOperation:kCREATE withChangedAttributes:changedAttributes onFinishCallback:callback
                            trackProgressWith:progressDelegate];
                        

                        //[request setChangedAttributesList:changedAttributes];
                        
                        //we set each requessts url to be the same
                        request.url = [url absoluteString];
                        [retVal addObject:request];
                        [createRequests addObject:request];
                    }
                    [requestManager submitRequests:createRequests];
                }
                
                //process updates
                if ([putRequests count] > 0) {
                    //TODO:implement bulk processing for updates
                    for (Request* request in putRequests) {
                        
                        //we submit put requests one at a time, since the server doesnt support
                        //a bulk put protocol as of yet
                        [requestManager submitRequest:request];
                    }
                }
                
                //process delete requests
                if ([deleteRequests count] > 0) {
                    for (Request* request in deleteRequests) {
                        //we submit the delete one at a time, we will not support bulk deletes yet
                        [requestManager submitRequest:request];
                    }
                }
            }
            else {
                
                LOG_RESOURCECONTEXT(1, @"%@Skipping upload of  objects to cloud as the user is unauthenticated",activityName);
            }
        }
        else {
            //if no, then we do not perform a sync to the cloud
            LOG_RESOURCECONTEXT(0, @"%@Skipping upload of  objects to cloud as this option was disabled",activityName);

        }
    }
    
    [resourceTypesToCreateInCloud release];
    [resourcesToCreateInCloud release];
    [resourceIDsToCreateInCloud release];
    [putRequests release];
    [createRequests release];
    [deleteRequests release];
    [progressDelegate initializeWith:retVal];
    
   
    return retVal;
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
    
    BOOL shouldReleaseEnumerationContext = NO;
    if (enumerationContext == nil) {
        enumerationContext = [[EnumerationContext alloc]init];
        shouldReleaseEnumerationContext = YES;
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
    
    if (shouldReleaseEnumerationContext) {
        [enumerationContext release];
    }
    [authenticationContext release];
    
    
}

#pragma mark - Authentication Enumeration
- (void) createUserAndGetAuthenticatorTokenWithEmail:(NSString*)email 
                                        withPassword:(NSString*)password
                                     withDisplayName:(NSString*)displayName
                                        withUsername:(NSString*)username 
                                     withDeviceToken:(NSString*)deviceToken 
                                      onFinishNotify:(Callback*)callback
                                   trackProgressWith:(id<RequestProgressDelegate>)progressDelegate
{
        //this method creates a user account ont he server and logs the user in
    NSString* activityName = @"ResourceContext.createUserAndGetAuthenticatorTokenWithEmail:";
    Request* request = (Request*)[Request createInstanceOfRequest];
    [request updateRequestStatus:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kUPDATEAUTHENTICATOR];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    NSURL* url = [UrlManager urlForCreateUserAccount:email withPassword:password withDisplayName:displayName withUsername:(NSString*)username withDeviceToken:deviceToken];
    request.url = [url absoluteString];
    request.delegate = progressDelegate;
    LOG_SECURITY(0, @"%@Submitting Create User and Authenticate request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
   
    
    [progressDelegate initializeWith:[NSArray arrayWithObject:request]];
    
     [requestManager submitRequest:request];

}

- (void) updateAuthenticatorWithFacebook:(NSString*)facebookID 
                         withAccessToken:(NSString*)facebookAccessToken
                          withExpiryDate:(NSDate*)facebookAccessTokenExpiry
                          onFinishNotify:(Callback*)callback
{
    NSString* activityName = @"ResourceContext.updateAuthenticatorWithFacebook:";
    Request* request = (Request*)[Request createInstanceOfRequest];
    
    [request updateRequestStatus:kPENDING];
    //request.statuscode =[NSNumber numberWithInt:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kUPDATEAUTHENTICATOR];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    AuthenticationContext* context = [[AuthenticationManager instance]contextForLoggedInUser];
    
    NSURL* url = [UrlManager urlForUpdateAuthenticatorWithFacebookURL:facebookID withToken:facebookAccessToken withExpiry:facebookAccessTokenExpiry withAuthenticationContext:context];

    
    
    
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting update authentication with Facebook request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];
    
}

- (void) getAuthenticatorTokenWithEmail:(NSString*)email 
                              withPassword:(NSString*)password 
                           withDeviceToken:(NSString*)deviceToken 
                            onFinishNotify:(Callback*)callback
{
    NSString* activityName = @"ResourceContext.getAuthenticatorTokenWithPassword:";
    Request* request = (Request*)[Request createInstanceOfRequest];
    [request updateRequestStatus:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kAUTHENTICATE];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    NSURL* url = [UrlManager urlForPasswordAuthentication:email withPassword:password withDeviceToken:deviceToken];
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting Password Authentication request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];
    
}


- (void) getAuthenticatorTokenWithTwitter:(NSNumber*)twitterID 
                          withTwitterName:(NSString*)twitterName 
                          withAccessToken:(NSString*)twitterAccessToken 
                    withAccessTokenSecret:(NSString*)twitterAccessTokenSecret
                           withExpiryDate:(NSString*)twitterTokenExpiry 
                          withDeviceToken:(NSString*)deviceToken
                           onFinishNotify:(Callback*)callback
{
    NSString* activityName  = @"ResourceContext.getAuthenticatorToken:";
    
    Request* request = (Request*)[Request createInstanceOfRequest];
    
    [request updateRequestStatus:kPENDING];
    //request.statuscode =[NSNumber numberWithInt:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kAUTHENTICATE];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    NSURL* url = [UrlManager urlForAuthenticationWithTwitter:twitterID withTwitterName:twitterName withAccessToken:twitterAccessToken withAccessTokenSecret:twitterAccessTokenSecret withExpiryDate:twitterTokenExpiry withDeviceToken:deviceToken];
    
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting Authentication request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];

    
}


- (void) getAuthenticatorToken:(NSNumber *)facebookID 
                      withName:(NSString *)displayName 
                     withEmail:(NSString *)email
       withFacebookAccessToken:(NSString *)facebookAccessToken 
       withFacebookTokenExpiry:(NSDate *)date 
                withDeviceToken:(NSString *)deviceToken
                onFinishNotify:(Callback *)callback {
    NSString* activityName = @"ResourceContext.getAuthenticatorToken:";
   
 
    Request* request = (Request*)[Request createInstanceOfRequest];
   
      [request updateRequestStatus:kPENDING];
    //request.statuscode =[NSNumber numberWithInt:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kAUTHENTICATE];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    NSURL* url = [UrlManager urlForAuthentication:facebookID withName:displayName withEmail:email withFacebookAccessToken:facebookAccessToken withFacebookTokenExpiry:date withDeviceToken:deviceToken];
    
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting Authentication request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];
    
}


- (void) updateAuthenticatorWithTwitter:(NSString*)twitterUserID 
                        withAccessToken:(NSString*)twitterAccessToken
                  withAccessTokenSecret:(NSString*)twitterAccessTokenSecret
                         withExpiryDate:(NSString*)twitterTokenExpiry
                         onFinishNotify:(Callback*)callback 
{
     NSString* activityName = @"ResourceContext.updateAuthenticatorWithTwitter:";
    
    Request* request = (Request*)[Request createInstanceOfRequest];
    
     [request updateRequestStatus:kPENDING];
    //request.statuscode =[NSNumber numberWithInt:kPENDING];
    request.operationcode =[NSNumber numberWithInt:kUPDATEAUTHENTICATOR];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    
    AuthenticationContext* context = [[AuthenticationManager instance]contextForLoggedInUser];
    
    NSURL* url = [UrlManager urlForUpdateAuthenticatorURL:twitterUserID withToken:twitterAccessToken withTokenSecret:twitterAccessTokenSecret withExpiry:twitterTokenExpiry withAuthenticationContext:context];
    
   
    
    request.url = [url absoluteString];
    
    LOG_SECURITY(0, @"%@Submitting update authentication request to RequestManager with url %@",activityName,request.url);
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];

    
}

#pragma mark - Data Access Methods
- (Resource*)resourceWithType:(NSString *)typeName withID:(NSNumber *)resourceID {
    NSString* activityName = @"ResourceContext.resourceWithType:";
    Resource* retVal = nil;
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
        [request setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@",RESOURCEID, resourceID];    
        [request setPredicate:predicate];
        
        NSError* error = nil;
        NSManagedObjectContext* context = self.managedObjectContext;
        //LOG_SECURITY(0, @"%@Grabbing context at memory address %p",activityName,context);
        NSArray* results = [context executeFetchRequest:request error:&error];

        [request release];
        if (results != nil && [results count] > 0) {
            retVal = [results objectAtIndex:0];
        }
    }
    else {
        //TODO: log an error message here
        LOG_RESOURCECONTEXT(1,@"%@Could not find object with ID:%@ and Type:%@",activityName,typeName,resourceID);
        
    }
    return retVal;
}

//this method will go through the entire store and detect any objects
//that are partially created, or invalid and erase them
- (void) clean 
{
    NSString* activityName = @"ResourceContext.clean:";
    
    //we need to find all the objects which may have been
    //created locally but werent successfully uploaded due to crash
    //we look for attributeinstancedata objects with objectid being dirty
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:ATTRIBUTEINSTANCEDATA inManagedObjectContext:self.managedObjectContext];
    
    
    if (entityDescription) 
    {
        NSFetchRequest* request = [[NSFetchRequest alloc]init];
        [request setEntity:entityDescription];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"attributename=%@ AND isdirty=1",OBJECTID];
        [request setPredicate:predicate];
        
        NSError* error = nil;
        NSManagedObjectContext* context = self.managedObjectContext;
        NSArray* results = [context executeFetchRequest:request error:&error];
        
        [request release];
        
        //now we have the queried objects
        for (AttributeInstanceData* aid in results) 
        {
            Resource* resourceToDelete = [aid valueForKey:@"resource"];
            LOG_RESOURCECONTEXT(0, @"%@Detected Resource with %@ and type %@ is a create stub and will be deleted",activityName,resourceToDelete.objectid,resourceToDelete.objecttype);
            
            [self delete:resourceToDelete.objectid withType:resourceToDelete.objecttype];
        }
        
        //now we save
        error = nil;
        [self.managedObjectContext save:&error];
        
        if (error != nil) 
        {
            LOG_RESOURCECONTEXT(1, @"%@ could not clean object context due to %@",activityName,[error localizedDescription]);
        
        }
        else
        {
            LOG_RESOURCECONTEXT(0, @"%@ Successfully cleaned local store of stub and corrupted objects",activityName);
        }
                                  
    }
}

- (Resource*) resourceWithType:(NSString*)typeName 
                withValueEqual:(NSString*)value 
                  forAttribute:(NSString*)attributeName 
                        sortBy:(NSString*)sortByAttribute 
                 sortAscending:(BOOL)sortAscending {
    Resource* retVal = nil;
    
    NSSortDescriptor* sortDescriptor = nil;
    NSMutableArray* sortDescriptorArray = nil;
    
    if (sortByAttribute != nil) {
        sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortByAttribute ascending:sortAscending];
        sortDescriptorArray = [NSMutableArray arrayWithObject:sortDescriptor];
    }
    
    NSArray* retValues = [self resourcesWithType:typeName withValueEqual:value forAttribute:attributeName sortBy:sortDescriptorArray];
    
    if (retValues != nil && [retValues count] > 0) {
        retVal = [retValues objectAtIndex:0];
    }
    
    if (sortDescriptor != nil) {
        [sortDescriptor release];
    }
    
    return retVal;
    
}



- (Resource*) resourceWithType:(NSString*)typeName 
                withValueEqual:(NSString*)value 
                  forAttribute:(NSString*)attributeName 
                        sortBy:(NSArray*)sortDescriptorArray {
    Resource* retVal = nil;
    NSArray* retValues = [self resourcesWithType:typeName withValueEqual:value forAttribute:attributeName sortBy:sortDescriptorArray];
    
    if (retValues != nil && [retValues count] > 0) {
        retVal = [retValues objectAtIndex:0];
    }
    return retVal;
    
}

- (Resource*) resourceWithType:(NSString*)typeName 
               withValuesEqual:(NSArray*)valuesArray 
                 forAttributes:(NSArray*)attributeNameArray 
                        sortBy:(NSArray*)sortDescriptorArray {
    NSString* activityName = @"ResourceContext.resourceWithType:withValuesEqual:forAttributes:sortBy:";
    Resource* retVal = nil;
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        //we need to create a predicate string for all the values in the query request array
        NSString* resourceQuery = nil;
        for (int i = 0; i < [valuesArray count]; i++) {
            if (i > 0) {
                resourceQuery = [NSString stringWithFormat:@"%@ AND %@=%@",resourceQuery,[valuesArray objectAtIndex:i],[attributeNameArray objectAtIndex:i]];
            }
            else {
                resourceQuery = [NSString stringWithFormat:@"%@=%@",[valuesArray objectAtIndex:i],[attributeNameArray objectAtIndex:i]];
            }
        }
        
        //now we have the query for our predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:resourceQuery];    
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptorArray];
        [request setEntity:entityDescription];
        
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        [request release];
        
        if (results != nil && [results count] > 0) {
            retVal = [results objectAtIndex:0];
        }
        else {
            LOG_RESOURCECONTEXT(1,@"%@Could not find object with query: %@", activityName, resourceQuery);
        }
    }
    else {
        LOG_RESOURCECONTEXT(1,@"%@Could not create entity description for type: %@", activityName, typeName);
        
    }
    return retVal;
    
}

- (NSArray*) resourcesWithType:(NSString *)typeName 
               withValuesEqual:(NSArray *)valuesArray 
                 forAttributes:(NSArray *)attributeNameArray 
                        sortBy:(NSArray *)sortDescriptorArray
{
    NSString* activityName = @"ResourceContext.resourcesWithTypeArray";
    NSArray* retVal = nil;
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        //we need to create a predicate string for all the values in the query request array
        NSString* resourceQuery = nil;
        for (int i = 0; i < [valuesArray count]; i++) {
            if (i > 0) {
                resourceQuery = [NSString stringWithFormat:@"%@ AND %@=%@",resourceQuery,[valuesArray objectAtIndex:i],[attributeNameArray objectAtIndex:i]];
            }
            else {
                resourceQuery = [NSString stringWithFormat:@"%@=%@",[valuesArray objectAtIndex:i],[attributeNameArray objectAtIndex:i]];
            }
        }
        
        //now we have the query for our predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:resourceQuery];    
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptorArray];
        [request setEntity:entityDescription];
        
        NSError* error = nil;
        LOG_RESOURCECONTEXT(0, @"%@Executing fetch against managedObjectContext for resources with type:%@",activityName,typeName);
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        [request release];
        
        if (results != nil && [results count] > 0) {
            retVal = results;
        }
        else {
            LOG_RESOURCECONTEXT(1,@"%@Could not find object with query: %@", activityName, resourceQuery);
        }
    }
    else {
        LOG_RESOURCECONTEXT(1,@"%@Could not create entity description for type: %@", activityName, typeName);
        
    }
    return retVal;
    
    
}

- (NSArray*)  resourcesWithType:(NSString*)typeName 
           withValueLessThan:(NSString*)value 
                   forAttribute:(NSString*)attributeName 
                         sortBy:(NSArray*)sortDescriptorArray
{
    NSString* activityName = @"ResourceContext.resourcesWithTypeGreaterThan:";
    NSArray* retVal = nil;
    
    
    NSManagedObjectContext *appContext = self.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    if (attributeName != nil && 
        value != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K<%@",attributeName,value];    
        [request setPredicate:predicate];
    }
    
    if (sortDescriptorArray != nil) {
        [request setSortDescriptors:sortDescriptorArray];
    }
    
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
        LOG_RESOURCECONTEXT(1, @"%@Error fetching results from data layer for attribute:%@ with error:%@",activityName,attributeName,error);
    }
    
    else {
        
        retVal = results;
    }
    [request release];
    
    return retVal; 
}


- (NSArray*)  resourcesWithType:(NSString*)typeName 
                 withValueEqual:(NSString*)value 
                   forAttribute:(NSString*)attributeName 
                         sortBy:(NSArray*)sortDescriptorArray {
    
    NSString* activityName = @"ResourceContext.resourcesWithType:";
    NSArray* retVal = nil;
    
    
    NSManagedObjectContext *appContext = self.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    if (attributeName != nil && 
        value != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@",attributeName,value];    
        [request setPredicate:predicate];
    }
    
    if (sortDescriptorArray != nil) {
        [request setSortDescriptors:sortDescriptorArray];
    }
    
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
        LOG_RESOURCECONTEXT(1, @"%@Error fetching results from data layer for attribute:%@ with error:%@",activityName,attributeName,error);
    }
    
    else {
       
        retVal = results;
    }
    [request release];
    
    return retVal; 

}


 
- (Resource*) singletonResourceWithType:(NSString*)typeName {
    NSString* activityName = @"ResourceContext.singletonResourceWithType:";
    Resource* retVal = nil;
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:typeName inManagedObjectContext:self.managedObjectContext];
    
    if (entityDescription) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
        [request setEntity:entityDescription];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@",OBJECTTYPE,typeName];
        [request setPredicate:predicate];
        
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
        [request release];
        
        if (results != nil && [results count] == 1) {
            retVal = [results objectAtIndex:0];
        }
        else if (results != nil && [results count] > 1) {
            LOG_RESOURCECONTEXT(1,@"%@%@",activityName,@"Singleton object either doesn't exist, or has multiple instances in the database");
            retVal = [results objectAtIndex:0];
        }
        
               
        
    }
    else {
         LOG_RESOURCECONTEXT(1,@"%@Resource type %@ doesn't exist",activityName,typeName);
    }
    return retVal;

}

#pragma mark - Utility Methods
- (void) markResourceAsBeingSynchronized:(NSNumber *)resourceID withResourceType:(NSString*)type {
    Resource* resource = [self resourceWithType:type withID:resourceID];
    
    [resource markAsClean];
    
        
}

- (void) markResourcesAsBeingSynchronized:(NSArray *)resources withResourceTypes:(NSArray*)resourceTypes {
    
    int count = 0;
    for (NSNumber* resourceid in resources) {
        NSString* resourceType = [resourceTypes objectAtIndex:count];
        Resource* resource = [self resourceWithType:resourceType withID:resourceid];
        [resource markAsClean];
    }

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
