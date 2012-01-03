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
            
        }
        return sharedInstance;
    }
}


- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    NSThread* thread = [NSThread currentThread];
    
    if ([thread isMainThread]) {
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
           // threadContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
           // [threadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
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
}

- (void) onContextDidSave:(NSNotification*)notification {
    NSString* activityName = @"ResourceContext.onContextDidSave:";
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext* sender = notification.object;
    NSMutableSet* keysToRemove = [[NSMutableSet alloc]init];
    
    if (appDelegate.managedObjectContext != sender) {
        //lets propagate the notification to all contexts
        NSManagedObjectContext* appDelContext = appDelegate.managedObjectContext;
        LOG_RESOURCECONTEXT(0, @"%@ Received NSManagedObjectContextDidSaveNotification from %p on background thread, propagating to context %p on main thread",activityName,sender,appDelContext);
        
        NSArray* updates = [[notification.userInfo objectForKey:@"inserted"]allObjects];
        for (NSInteger i = [updates count]-1;i >=0; i--) {
            [[appDelegate.managedObjectContext objectWithID:[[updates objectAtIndex:i]objectID]]willAccessValueForKey:nil];
        }
        
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
                
                NSArray* updates = [[notification.userInfo objectForKey:@"updated"]allObjects];
                for (NSInteger i = [updates count]-1;i >=0; i--) {
                    [[appDelegate.managedObjectContext objectWithID:[[updates objectAtIndex:i]objectID]]willAccessValueForKey:nil];
                }
                
                LOG_RESOURCECONTEXT(0, @"%@ Received NSManagedObjectContextDidSaveNotification from %p propagating to context %p on background thread",activityName,sender, context);
                [context mergeChangesFromContextDidSaveNotification:notification];
            }
        }
        else {
//            LOG_RESOURCECONTEXT(0, @"%@ Marking managed context for cancelled or deallocated thread %p for deletion",activityName,key);
//            [keysToRemove addObject:key];
        }
        
    }
     [self.managedObjectContextsLock unlock];
    //at this point we need to remove all of the keys in the NSSet from the NSDictionary
//    int currentNumKeys = [self.managedObjectContexts count];
//    int numKeysToRemove = [keysToRemove count];
//    LOG_RESOURCECONTEXT(0, @"%@Removing %d managedObjectContexts leaving the system with %d active managedObjectContexts",activityName,numKeysToRemove,(currentNumKeys-numKeysToRemove));
//    
//    for (NSString* keyToRemove in [keysToRemove allObjects]) {
//        [self.managedObjectContexts removeObjectForKey:keysToRemove];
//    }
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
    
    
    NSMutableArray* resourcesToDeleteInCloud = [[NSMutableArray alloc]init];
    
    NSMutableArray* createRequests = [[NSMutableArray alloc]init];
    NSMutableArray* putRequests = [[NSMutableArray alloc]init];
    
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
                    
                    //is this Put-Attachment request?
                    if ([changedAttributes count] == 1) {
                        //if the one changed attribute is an attachment type, then this is
                        //a Put-Attachment request
                        NSString* changedAttribute = [changedAttributes objectAtIndex:0];
                        AttributeInstanceData* aid = [resource attributeInstanceDataFor:changedAttribute];
                        if ([aid.isurlattachment boolValue]) {
                            //yes, it is an attachment
                            request = [self requestFor:resource forOperation:kMODIFYATTACHMENT  withChangedAttributes:changedAttributes  onFinishCallback:callback trackProgressWith:progressDelegate];
                            
                        }
                        else {
                            //no it is not an attachment
                            request = [self requestFor:resource forOperation:kMODIFY  withChangedAttributes:changedAttributes onFinishCallback:callback
                                       trackProgressWith:progressDelegate];
                        }
                        [resource markAsDirty:changedAttributes];
                        
                        
                    }
                    else if ([changedAttributes count] > 1) {
                        //must be a put modify operation since there are more than 1 changed attributes
                        request = [self requestFor:resource forOperation:kMODIFY withChangedAttributes:changedAttributes onFinishCallback:callback
                            trackProgressWith:progressDelegate];
                        [resource markAsDirty:changedAttributes];
                    }
                    else {
                        //no changed attribute values to sync
                        //do nothing
                        request = nil;
                    }
                    
                    
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
                        else if (request.operationcode == [NSNumber numberWithInt:kMODIFYATTACHMENT]) {
                            NSString *changedAttribute = [[request changedAttributesList] objectAtIndex:0];
                            request.url = [[UrlManager urlForUploadAttachment:request.targetresourceid withObjectType:request.targetresourcetype forAttributeName:changedAttribute withAuthenticationContext:authenticationContext] absoluteString];
                        }
                        [retVal addObject:request];
                        [putRequests addObject:request];
                    }
                    
                } 
            }
            
            
        }
    }
    
    
    //process deleted objects
    if (saveToCloud) {
        NSArray* deletedObjectsArray = [deletedObjects allObjects];
        for (int i = 0; i < [deletedObjectsArray count]; i++) {
            Resource* resource = [deletedObjectsArray objectAtIndex:i];
            if ([resource shouldResourceBeSynchronizedToCloud]) {
                [resourcesToDeleteInCloud addObject:resource];
                [resource markAsDirty];
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
    updatedObjects = [self.managedObjectContext updatedObjects];
    NSArray* uArray = [updatedObjects allObjects];
    for (NSManagedObject* object in uArray) {
       [self.managedObjectContext refreshObject:object mergeChanges:YES];
    }
    [self.managedObjectContext save:&error];
    
    if (error != nil) {
        LOG_RESOURCECONTEXT(1, @"%@Error when saving data to persistence store:%@",activityName,error);
        
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
    [resourcesToDeleteInCloud release];
    [resourceTypesToCreateInCloud release];
    [resourcesToCreateInCloud release];
    [resourceIDsToCreateInCloud release];
    [putRequests release];
    [createRequests release];
    
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
- (void) getAuthenticatorToken:(NSNumber *)facebookID 
                      withName:(NSString *)displayName 
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
    
    NSURL* url = [UrlManager urlForAuthentication:facebookID withName:displayName withFacebookAccessToken:facebookAccessToken withFacebookTokenExpiry:date withDeviceToken:deviceToken];
    
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
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];

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
        
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:request error:&error];
        [request release];
        
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
