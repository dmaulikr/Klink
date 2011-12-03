//
//  RequestManager.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "RequestManager.h"
#import "Request.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ResourceContext.h"
#import "AttributeInstanceData.h"
#import "Types.h"
#import "UrlManager.h"
#import "AuthenticationContext.h"
#import "AuthenticationManager.h"
#import "CreateResponse.h"
#import "PutResponse.h"
#import "JSONKit.h"
#import "EnumerationResponse.h"
#import "Macros.h"
#import "GetAuthenticatorResponse.h"
#import "Response.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "ApplicationSettingsDefaults.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#define kREQUEST    @"REQUEST"
#define kATTACHMENTLIST @"ATTACHMENTLIST"

@implementation RequestManager
@synthesize operationQueue = m_operationQueue;
@synthesize enumerationQueue = m_enumerationQueue;
@synthesize imageCache  = m_imageCache;

static RequestManager* sharedInstance;

+ (RequestManager*) instance {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[RequestManager allocWithZone:NULL]init
            ];
        }
        return sharedInstance;
    }
}

- (id) init {
    self = [super init];
    if (self) {
        self.enumerationQueue = [[OperationQueue alloc]init];
        self.operationQueue = [[OperationQueue alloc]init];
        self.imageCache = [[ASIDownloadCache alloc]init];
    }
    return self;
}

- (ASIHTTPRequest*) requestFor:(RequestOperation)opcode 
                       withURL:(NSString*)url 
                  withUserInfo:(NSDictionary*)userInfo {
    ApplicationSettings* settings = [[ApplicationSettingsManager instance] settings];
    
    if (opcode == kCREATE) {
        ASIFormDataRequest* httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        httpRequest.delegate = self;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.userInfo = userInfo;
        httpRequest.timeOutSeconds = [settings.http_timeout_seconds intValue];
        return httpRequest;
    }
    else if (opcode == kMODIFY ||
             opcode == kMODIFYATTACHMENT ||
             opcode == kUPDATEAUTHENTICATOR) {
        ASIFormDataRequest* httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        httpRequest.delegate = self;
        httpRequest.requestMethod = @"POST";
        httpRequest.userInfo = userInfo;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.timeOutSeconds = [settings.http_timeout_seconds intValue];
        return httpRequest;                           
                                   
    }
    else if (opcode == kENUMERATION ||
             opcode == kAUTHENTICATE) {
        ASIHTTPRequest* httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];      
        httpRequest.delegate = self;
        httpRequest.requestMethod = @"GET";
        httpRequest.userInfo = userInfo;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.timeOutSeconds = [settings.http_timeout_seconds intValue];
        return httpRequest; 
        
    }
    else if (opcode == kIMAGEDOWNLOAD) {
        ASIHTTPRequest* httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];      
        httpRequest.delegate = self;
        httpRequest.requestMethod = @"GET";
        httpRequest.userInfo = userInfo;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.timeOutSeconds = 5;
        httpRequest.numberOfTimesToRetryOnTimeout = 3;
        //httpRequest.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        //httpRequest.downloadCache = self.imageCache;
        return httpRequest;

    }
    else if (opcode == kSHARE) {
        ASIFormDataRequest* httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];      
        httpRequest.delegate = self;
        httpRequest.requestMethod = @"POST";
        httpRequest.userInfo = userInfo;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.timeOutSeconds = [settings.http_timeout_seconds intValue];
        return httpRequest;

    }
    return nil;
}
//
//
//- (void) processAttachmentFor:(NSString*)attribute 
//              forTargetResource:(NSNumber*)targetresourceid 
//          withTargetResourceType:(NSString*)targetresourcetype
//            onSuccessCallback:(Callback*)onSuccessCallback
//            onFailureCallback:(Callback*)onFailureCallback{
//    
//    NSString* activityName = @"RequestManager.processAttachmentFor:";
//    //will take the initial target object id
//    //and upload the file location that is contained
//    //within the attribute passed in
//    ResourceContext* context = [ResourceContext instance];
//    
//    Resource* resource = [context resourceWithType:targetresourcetype withID:targetresourceid];
//    Request* request = [Request createAttachmentRequestFor:targetresourceid 
//                                                withString:targetresourcetype 
//                                         onSuccessCallback:onSuccessCallback 
//                                         onFailureCallback:onFailureCallback];
//    
//    SEL selector = NSSelectorFromString(attribute);
//    
//    if ([resource respondsToSelector:selector]) {        
//        NSString* value = [resource performSelector:selector];
//        
//        
//        AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
//        NSURL* url = [UrlManager urlForUploadAttachment:resource.objectid withObjectType:resource.objecttype forAttributeName:attribute withAuthenticationContext:authenticationContext];
//        
//        request.url = [url absoluteString];
//        [request setChangedAttributesList:[NSArray arrayWithObject:attribute]];
//        [request retain];
//        
//        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:request forKey:kREQUEST];
//        ASIFormDataRequest* httpRequest = (ASIFormDataRequest*) [self requestFor:kMODIFYATTACHMENT withURL:[url absoluteString] withUserInfo:userInfo];
//        [httpRequest setFile:value forKey:@"attachment"];
//        httpRequest.delegate = self;
//        httpRequest.didFailSelector = @selector(onRequestFailed:);
//        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
//        
//        LOG_REQUEST(0, @"%@Executing upload attachment request for ID:%@ of Type:%@ for Attribute:%@",activityName,resource.objectid,resource.objecttype,attribute);
//        [self.operationQueue addOperation:httpRequest];
//    }  
//}

- (void) processAttachmentFor:(NSString*)attribute associatedWith:(Request*)request {
    NSString* activityName = @"RequestManager.processAttachmentFor:";
    //will take the initial target object id
    //and upload the file location that is contained
    //within the attribute passed in
    ResourceContext* context = [ResourceContext instance];
    
    Resource* resource = [context resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    
    SEL selector = NSSelectorFromString(attribute);
    
    if ([resource respondsToSelector:selector]) {        
        NSString* value = [resource performSelector:selector];
        
        
        AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
        NSURL* url = [UrlManager urlForUploadAttachment:resource.objectid withObjectType:resource.objecttype forAttributeName:attribute withAuthenticationContext:authenticationContext];
        
        request.url = [url absoluteString];
        [request setChangedAttributesList:[NSArray arrayWithObject:attribute]];
        [request retain];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:request forKey:kREQUEST];
        ASIFormDataRequest* httpRequest = (ASIFormDataRequest*) [self requestFor:kMODIFYATTACHMENT withURL:[url absoluteString] withUserInfo:userInfo];
        [httpRequest setFile:value forKey:@"attachment"];
        httpRequest.delegate = self;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        
        LOG_REQUEST(0, @"%@Executing upload attachment request for ID:%@ of Type:%@ for Attribute:%@",activityName,resource.objectid,resource.objecttype,attribute);
        [self.operationQueue addOperation:httpRequest];
    }  

}

- (void) processAttachmentsForRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processAttachmentsForRequest:";
    NSArray* attachmentAttributeNames = [self attachmentAttributesInRequest:request];
    
    //we create a new request to handle attachment processing
    Request* newRequest = [Request createAttachmentRequestFrom:request];
    
    for (NSString* attachmentAttributeName in attachmentAttributeNames) {
        //submit the attachment for processing
        LOG_REQUEST(0,@"%@Processing Request attachment upload for attribute %@",activityName,attachmentAttributeName);
        [self processAttachmentFor:attachmentAttributeName associatedWith:newRequest];
    }
    
}

//- (void) processAttachmentsForResource:(Resource*)resource 
//                     onSuccessCallback:(Callback*)onSuccessCallback 
//                     onFailureCallback:(Callback*)onFailureCallback
//{
//    NSString* activityName = @"RequestManager.processAttachmentsForResource:";
//    NSArray* attachmentAttributes = [resource attachmentAttributesWithValues];
//    
//  
//   
//    for (NSString* attachmentAttributeName in attachmentAttributes) {
//        AttributeInstanceData* aid = [resource attributeInstanceDataFor:attachmentAttributeName];
//        if ([aid.isdirty boolValue]) {
//            
//            LOG_REQUEST(0,@"%@Processing Resource attachment upload for attribute %@",activityName,attachmentAttributeName);
//            [self processAttachmentFor:attachmentAttributeName 
//                     forTargetResource:resource.objectid 
//                withTargetResourceType:resource.objecttype 
//                     onSuccessCallback:onSuccessCallback 
//                     onFailureCallback:onFailureCallback];
//        }
//
//    }
//}

//called by creatre and put responses to process attachment attributes after the fact
- (void) processModifyAttachment:(Request*) request {
    NSArray* changedAttributes = [request changedAttributesList];
    NSString* attributeName = [changedAttributes objectAtIndex:0];
    [self processAttachmentFor:attributeName associatedWith:request];
}

- (void) processDelete:(Request*) request {
    //TODO: implement delete functionality
}

- (void) processModify:(Request*) request {
    NSString* activityName = @"RequestManager.processModify:";
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    
    //TODO: we need to optimize to only send the JSON fragments which changed
    //for now we will send the whole object
    NSString* json = [resource toJSON];
    

    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    [request retain];
    
    //prior to making the call, we lock attachment attributes that need to be uploaded
    //after the update, so that they are not over-written by the update operation
    NSArray* attachmentAttributesInRequest = [self attachmentAttributesInRequest:request];
    [resource lockAttributes:attachmentAttributesInRequest];
    LOG_REQUEST(0,@"%@Locking %d attachment attributes until Put completes",activityName,[attachmentAttributesInRequest count]);
    
    [resourceContext save:YES onFinishCallback:nil];
    
    //we submit the initial put operation with the request
    //the attachments will be processed on the return leg
    ASIFormDataRequest* httpRequest = (ASIFormDataRequest*)[self requestFor:kMODIFY withURL:request.url withUserInfo:userInfo];
    [httpRequest setPostValue:json forKey:@""];
      
    LOG_REQUEST(0, @"%@Executing put request for ID:%@ of Type:%@ with %d attachments to be processed after",activityName,resource.objectid,resource.objecttype,[attachmentAttributesInRequest count]);
    
    [self.operationQueue addOperation:httpRequest];
}

- (void) processUpdateAuthenticator:(Request*)request {
    NSString* activityName = @"RequestManager.processUpdateAuthenticator:";
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    [request retain];
    
    ASIFormDataRequest* httpRequest = (ASIFormDataRequest*)[self requestFor:kUPDATEAUTHENTICATOR withURL:request.url withUserInfo:userInfo];
    [httpRequest setPostValue:@"" forKey:@""];
    
    
    LOG_REQUEST(0, @"%@Executing update authenticator request",activityName);
    
    [self.operationQueue addOperation:httpRequest];
    
}

- (void) processCreates:(NSArray*) requests {
    //bulk create in one shot
    NSString* activityName = @"RequestManager.processCreates:";
    NSMutableArray* resourcesToCreate = [[NSMutableArray alloc]init];
    
    ResourceContext* resourceContext = [ResourceContext instance];

    NSString* url = nil;
    int attachmentCount = 0;
    
    for (Request* request in requests) {
        Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
       

        NSString* resourceJSON = [resource toJSON];
        [resourcesToCreate addObject:resourceJSON];
        [request retain];
        
        if (url == nil) {
            //need to pull out one of the URLs, it is
            //assumed that all elements have the same URL
            url = request.url;
        }
        
        //we need to lock all attachment attributes so they arent overwritten
        //when the main resource is created/updated from the server  
        NSArray* attachmentAttributes = [self attachmentAttributesInRequest:request];
        [resource lockAttributes:attachmentAttributes];
            
        attachmentCount += [attachmentAttributes count];
        
       
        
        [resourceContext save:YES onFinishCallback:nil];
        
    }
    
    //we now have a json representation of each resource
    NSString* json = [resourcesToCreate JSONString];

        
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:requests forKey:kREQUEST];

    ASIFormDataRequest* httpRequest =(ASIFormDataRequest*) [self requestFor:kCREATE withURL:url withUserInfo:userInfo];
    [httpRequest setPostValue:json forKey:@""];
    
    
    //following code for generating log message
    LOG_REQUEST(0, @"%@Executing bulk create request for %d objects with %d attachments to be processed after",activityName,[requests count],attachmentCount);
    [self.operationQueue addOperation:httpRequest];
    
    
}
- (void) processCreate:(Request*) request {
    //single shot creates
    NSString* activityName = @"RequestManager.Create:";
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    NSString* json = [resource toJSON];
    
    if (resource != nil) {
        //prior to making the call, we lock attachment attributes that need to be uploaded
        //after the create, so that they are not over-written by the create operation
        NSArray* attachmentAttributesInRequest = [self attachmentAttributesInRequest:request];
        [resource lockAttributes:attachmentAttributesInRequest];
        LOG_REQUEST(0,@"%@Locking %d attachment attributes until Create completes",activityName,[attachmentAttributesInRequest count]);
        
        [resourceContext save:YES onFinishCallback:nil];
        
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:request forKey:kREQUEST];
        [request retain];
        ASIFormDataRequest* httpRequest = (ASIFormDataRequest*)[self requestFor:[request.operationcode intValue] withURL:request.url withUserInfo:userInfo];
        [httpRequest setPostValue:json forKey:@""];
        
        LOG_REQUEST(0, @"%@Executing create request for ID:%@ of Type:%@ with %d attachments to be processed after",activityName,resource.objectid,resource.objecttype,[attachmentAttributesInRequest count]);
        
        [self.operationQueue addOperation:httpRequest];
        
        
    }
    else {
        LOG_REQUEST(1,@"%@Could not find resource with ID:%@ of Type:%@ to create in cloud",activityName,resource.objectid,resource.objecttype);
    }
}



- (void) processEnumeration:(Request*)request {
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    ASIHTTPRequest* httpRequest = [self requestFor:[request.operationcode intValue] withURL:request.url withUserInfo:userInfo];
    [self.enumerationQueue addOperation:httpRequest];
}

- (void) processImageDownload:(Request*)request  {
    NSString* activityName = @"RequestManager.processImageDownload:";
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    ASIHTTPRequest* httpRequest = [self requestFor:[request.operationcode intValue] withURL:request.url withUserInfo:userInfo];
    
    NSDictionary* requestUserInfo = request.userInfo;
    NSString* downloadPath = [requestUserInfo valueForKey:IMAGEPATH];
  
    httpRequest.downloadDestinationPath = downloadPath;
    LOG_REQUEST(0,@"%@Beginning download of image at: %@ to local location %@",activityName,request.url,downloadPath);
    
    [self.enumerationQueue addOperation:httpRequest];
}

- (void) processShare:(Request*)request {
    NSString* activityName = @"RequestManager.processShare:";
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    ASIHTTPRequest* httpRequest = [self requestFor:[request.operationcode intValue] withURL:request.url withUserInfo:userInfo];
    LOG_REQUEST(0,@"%@Beginning http request to share at url:%@",activityName,request.url);
    
    [self.operationQueue addOperation:httpRequest];

}


//returns all changed attributes on the request that are also attachments
- (NSArray*) attachmentAttributesInRequest:(Request*)request {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSArray* changedAttributes = [request changedAttributesList];
    Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    
    NSArray* attributeInstanceDataList = [resource attributeInstanceDataForList:changedAttributes];
    
    NSMutableArray* attachmentAttributeNames = [[[NSMutableArray alloc]init]autorelease];
    
    //create a list of attributes that are attachments which need to be uploaded
    for (AttributeInstanceData* aid in attributeInstanceDataList) {
        if ([aid.isurlattachment boolValue]) {
            //the attribute is a url attachment
            //we need to upload it seperately
            [attachmentAttributeNames addObject:aid.attributename];
        }
    }
    
    return attachmentAttributeNames;

}

#pragma mark - Public interface
- (void) submitRequest:(Request*)request {
    NSString* activityName = @"RequestManager.submitRequest:";
        //take in a request
        //get a url
        //create a http request
    if ([request.operationcode intValue] == kCREATE) {
        LOG_REQUEST(0, @"%@Create request submitted to Request Manager",activityName);
        [self processCreate:request];
    }
    else if ([request.operationcode intValue] == kDELETE) {
        LOG_REQUEST(0, @"%Delete request submitted to Request Manager",activityName);

        [self processDelete:request];
    }
    else if ([request.operationcode intValue] == kMODIFY) {
        LOG_REQUEST(0, @"%Modify request submitted to Request Manager",activityName);

        [self processModify:request];
    }
    else if ([request.operationcode intValue] == kMODIFYATTACHMENT) {
        LOG_REQUEST(0, @"%@Modify request submitted to Request Manager",activityName);

        [self processModifyAttachment:request];
    }
    else if ([request.operationcode intValue] == kENUMERATION ||
             [request.operationcode intValue] == kAUTHENTICATE) {
        LOG_REQUEST(0, @"%@Enumeration request submitted to Request Manager",activityName);

        [self processEnumeration:request];
    }
    else if ([request.operationcode intValue] == kIMAGEDOWNLOAD) {
        LOG_REQUEST(0, @"%Image download request submitted to Request Manager",activityName);

        [self processImageDownload:request];
    }
    else if ([request.operationcode intValue] == kUPDATEAUTHENTICATOR) {
        LOG_REQUEST(0, @"%@Update authenticator request submitted to Request Manager",activityName);

        [self processUpdateAuthenticator:request];

    }
    else if ([request.operationcode intValue] == kSHARE) {
        LOG_REQUEST(0, @"%@Share request submitted to Request Manager",activityName);
        
        [self processShare:request];
    }
        
}

- (void) submitRequests:(NSArray*)requests {
    NSString* activityName = @"RequestManager.submitRequests:";
    BOOL isCreateStream = NO;
    
    for (Request* request in requests) {
        if ([request.operationcode intValue] == kCREATE) {
            
            isCreateStream = YES;
        }
        else {
            isCreateStream = NO;
            //we break because we know this is not a homogenous stream of Requests of the 
            //same operation code
            LOG_REQUEST(1,@"%@Bulk submission request failed, as they are not a series of Create requests (not supported currently)",activityName);
            break;
        }
    }
    
    if (isCreateStream) {
        LOG_REQUEST(0, @"%@Bulk create request submitted to Request Manager with %d items",activityName,[requests count]);
        [self processCreates:requests];
    }
    
}

#pragma mark - Async Request Handlers
- (Response*) processEnumerationResponse:(NSString*)responseString withRequest:(Request*)request {
   
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    EnumerationResponse* response = [[EnumerationResponse alloc]initFromJSONDictionary:jsonDictionary];

    return response;
}

- (Response*) processAuthenticateResponse:(NSString*)responseString withRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processAuthenticateResponse:";
    NSError* error = nil;
    NSDictionary* jsonDictionary = [responseString objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error != nil) {
        LOG_REQUEST(1, @"@%Could not deserialize response into JSON object: %@",activityName,error);
        return nil;
    }
    else {
        GetAuthenticatorResponse* response = [[GetAuthenticatorResponse alloc]initFromJSONDictionary:jsonDictionary];
        return response;
    }
    
    
}


- (Response*) processModifyAttachmentResponse:(NSString*)responseString withRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processModifyAttachmentResponse:";

    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    PutResponse* putResponse = [[PutResponse alloc] initFromJSONDictionary:jsonDictionary];
    
    if ([putResponse.didSucceed boolValue]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        Resource* modifiedResource = putResponse.modifiedResource;
        Resource* existingResource = [resourceContext resourceWithType:modifiedResource.objecttype withID:modifiedResource.objectid];
        
        //we need to unlock the attachment attributes
        //so it can be overwritten
        NSArray* changedAttributeList = [request changedAttributesList];
        [existingResource unlockAttributes:changedAttributeList];
        
        
        [existingResource refreshWith:modifiedResource];
        
        
        for (Resource* resource in putResponse.secondaryResults) {
            existingResource = nil;
            existingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid];
            
            if (existingResource != nil) {
                [existingResource refreshWith:resource];
            }
            else {
                //new object , need to create it
                [resourceContext insert:resource];
            }
        }
        
        
        [resourceContext save:NO onFinishCallback:nil];
    }
    else {
        LOG_REQUEST(1, @"%@Attachment upload request failed for ID:%@ with Type:%@ due to Error:%@",activityName,request.targetresourceid,request.targetresourcetype,putResponse.errorMessage);
    }
    return putResponse;
}

- (Response*) processModifyResponse:(NSString*)responseString withRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processModifyResponse:";
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    PutResponse* putResponse = [[PutResponse alloc] initFromJSONDictionary:jsonDictionary];
    
    if ([putResponse.didSucceed boolValue]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        Resource* modifiedResource = putResponse.modifiedResource;
        Resource* existingResource = [resourceContext resourceWithType:modifiedResource.objecttype withID:modifiedResource.objectid];
        
        [existingResource refreshWith:modifiedResource];
        
        
        for (Resource* resource in putResponse.secondaryResults) {
            existingResource = nil;
            existingResource = [resourceContext resourceWithType:resource.objecttype withID:resource.objectid];
            
            if (existingResource != nil) {
                [existingResource refreshWith:resource];
            }
            else {
                //new object , need to create it
                [resourceContext insert:resource];
            }
        }
        
        //we need to unlock any attachment attributes that are still pending processing
        //on this original request
        NSArray* attachmentAttributes = [self attachmentAttributesInRequest:request];
        [existingResource unlockAttributes:attachmentAttributes];
        
        
        [resourceContext save:NO onFinishCallback:nil];
        
        [self processAttachmentsForRequest:request];
        LOG_REQUEST(0, @"%@Put response successfully processed for ID:%@ with Type:%@",activityName,request.targetresourceid,request.targetresourcetype);

        
    }
    else {
         LOG_REQUEST(1, @"%@Put request failed for ID:%@ with Type:%@ due to Error:%@",activityName,request.targetresourceid,request.targetresourcetype,putResponse.errorMessage);
    }
    return putResponse;
    
}

- (Response*) processShareResponse:(NSString*)responseString withRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processShareResponse:";
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    Response* response = [[Response alloc]initFromJSONDictionary:jsonDictionary];
    
    if ([response.didSucceed boolValue]) {
        //when we share, we dont need to do any actions on the response
        LOG_REQUEST(1, @"%@Share request succeeded",activityName);

    }
    else {
        LOG_REQUEST(1, @"%@Share request failed due to Error:%@",activityName,response.errorMessage);
    }
    return response;
}

- (Response*) processUpdateAuthenticatorResponse:(NSString*)responseString 
                                     withRequest:(Request*)request {
    
    NSString* activityName = @"RequestManager.processUpdateAuthenticatorResponse:";
    NSError* error = nil;
    NSDictionary* jsonDictionary = [responseString objectFromJSONStringWithParseOptions:JKParseOptionNone error:&error];
    
    if (error != nil) {
        LOG_REQUEST(1, @"%@Could not deserialize response into JSON object: %@",activityName,error);
        return nil;
    }
    else {
        GetAuthenticatorResponse* response = [[GetAuthenticatorResponse alloc]initFromJSONDictionary:jsonDictionary];
        return response;
    }

}

- (Response*) processCreateResponse:(NSString*)responseString withRequest:(Request*)request {
    NSString* activityName = @"RequestManager.processCreateResponse:";
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    //create a create response handler
    CreateResponse* createResponse = [[CreateResponse alloc] initFromJSONDictionary:jsonDictionary];
    
    if ([createResponse.didSucceed boolValue]) {
        ResourceContext* resourceContext = [ResourceContext instance];
        
        LOG_REQUEST(0,@"%@Create request completed with %d objects created",activityName,[createResponse.createdResources count]);
        
        //we find the target object
        Resource* existingResource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
        
        //we refresh the object with the resource returned by the web service
        Resource* newResource = [createResponse createdResourceWith:request.targetresourceid withTargetResourceType:request.targetresourcetype];
        
        //refresh the existing resource with server returned version.
        [existingResource refreshWith:newResource];
        
        
        //we need to unlock the attachment attributes as they were purposely
        //locked on the submission to prevent them from being overwritten in the r
        //response
        NSArray* attachmentAttributesInRequest = [self attachmentAttributesInRequest:request];
        
        [existingResource unlockAttributes:attachmentAttributesInRequest];
        
        //we mark all of the attributes that were committed by this Create to the server
        //as being clean, except those which are either locked, or attachment attributes
        for (NSString* attributeName in request.changedAttributesList) {
            AttributeInstanceData* aid = [existingResource attributeInstanceDataFor:attributeName];
            
            if (![aid.islocked boolValue] && 
                ![aid.isurlattachment boolValue]) {
                aid.isdirty = [NSNumber numberWithBool:NO];
            }
        }
        
        //we now save the changes we made
        [resourceContext save:NO onFinishCallback:nil];
        
        //we now process all of the attachment attributes in the Request
        [self processAttachmentsForRequest:request];
    }
    else {
        LOG_REQUEST(1, @"%@Create request failed for ID:%@ with Type:%@ due to Error:%@",activityName,request.targetresourceid,request.targetresourcetype,createResponse.errorMessage);
    }
    return createResponse;
}

- (Response*)processImageDownloadResponse:(NSString*)responseString withRequest:(Request*)request {
    //we creare the response manually since there is no JSON to deserialize into an instance
    NSString* activityName = @"RequestManager.processImageDownloadResponse:";
    ImageDownloadResponse* response = [[ImageDownloadResponse alloc]init];
    
    
    //here we verify that the image downloaded successfully
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo = request.userInfo;
    NSString* imagePath = [userInfo valueForKey:IMAGEPATH];
    UIImage* image = [imageManager downloadImageFromFile:imagePath withUserInfo:nil atCallback:nil];
    if (image == nil) {
        //image download failed
        response.didSucceed = [NSNumber numberWithBool:NO];
        response.image = nil;
        response.path = nil;
        
        LOG_REQUEST(1, @"%@Image download failed, photo doesn't exist at specified path %@",activityName,imagePath);
    }
    else {
        response.didSucceed = [NSNumber numberWithBool:YES];
         response.path = imagePath;
        response.image = image;
        response.errorMessage = nil;
         LOG_REQUEST(1, @"%@Image downloaded successfully to location %@",activityName,imagePath);
    }
    
    return response;
    
    
}
 
- (void) processRequestResponse:(Request*)request withResponse:(NSString*)response  {
    NSString* activityName = @"RequestManager.processRequestResponse:";
    
    Response* responseObj = nil;
    if (response != nil) {
        //we only execute this leg if there was a successful response received, in the caase of a HTTP failure and there is no response
        //then this branch is moot
        if ([request.operationcode intValue] == kCREATE) {
            
            //processing a create response
            responseObj = [self processCreateResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kMODIFY) {
            //processing a modify response
            responseObj = [self processModifyResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kMODIFYATTACHMENT) {
            //processing a modify attachment response
            responseObj = [self processModifyAttachmentResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kDELETE) {
            //TODO: implement response handling for deletes
        }
        else if ([request.operationcode intValue] == kENUMERATION) {
            responseObj = [self processEnumerationResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kAUTHENTICATE) {
            responseObj = [self processAuthenticateResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kUPDATEAUTHENTICATOR) {
            responseObj = [self processUpdateAuthenticatorResponse:response withRequest:request];
        }
        else if ([request.operationcode intValue] == kSHARE) {
            responseObj = [self processShareResponse:response withRequest:request];
        }
  
        
    }
    else if ([request.operationcode intValue] == kIMAGEDOWNLOAD) {
         responseObj = [self processImageDownloadResponse:response withRequest:request];
    }
    
    if (responseObj != nil &&
        [responseObj.didSucceed boolValue]) {
        //mark the request being completed
        request.statuscode = [NSNumber numberWithInt:kCOMPLETED];
        LOG_REQUEST(0,@"%@Request completed successfully",activityName);
        //execute the success selector on each request
        if (request.onSuccessCallback != nil) {
            NSMutableDictionary* context = [NSMutableDictionary dictionaryWithObject:request forKey:kREQUEST];
            //insert the request context into the user dictionary as well
            [context addEntriesFromDictionary:request.userInfo];
            request.userInfo = nil;
            [request.onSuccessCallback fireWithResponse:responseObj withContext:context];
        }
      }
    else {
        //mark the request being failed
        request.statuscode = [NSNumber numberWithInt:kFAILED];
        
        LOG_REQUEST(0,@"%@Request failed",activityName);
        //execute the failure selector on each request
        if (request.onFailCallback != nil) {
            NSDictionary* context = [NSDictionary dictionaryWithObject:request forKey:kREQUEST];
            [request.onFailCallback fireWithResponse:responseObj withContext:context];
        }
    }
    


}



- (void) onRequestFailed:(ASIHTTPRequest*)httpRequest {
    NSString* activityName = @"RequestManager.onRequestFailed:";
    NSDictionary* userInfo = httpRequest.userInfo;
    
    NSObject* obj = [userInfo objectForKey:kREQUEST];
    
    LOG_HTTP(1, @"%@HTTP request failed",activityName);
    
    if ([obj isKindOfClass:[NSArray class]]) {
        //it was a bulk operation that failed
        NSArray* requests = [userInfo objectForKey:kREQUEST];
        for (Request* req in requests) {
            req.statuscode = [NSNumber numberWithInt:kFAILED];
            if (req.onFailCallback != nil) {
                [req.onFailCallback fire];
            }
        }
    }
    else {
        //it was a single resource operation that failed
        Request* req = [userInfo objectForKey:kREQUEST];
        if (req.onFailCallback != nil) {
            req.statuscode = [NSNumber numberWithInt:kFAILED];
            [req.onFailCallback fire];
        }
       
    }
}

- (void) onRequestSucceeded:(ASIHTTPRequest*)httpRequest {
    NSString* activityName = @"RequestManager.onRequestSucceededß:";
    NSDictionary* userInfo = httpRequest.userInfo;
    NSString* response = [httpRequest responseString];
    
    LOG_HTTP(0, @"%@HTTP request succeeded",activityName);
    if (userInfo != nil) {
        NSObject* obj = [userInfo objectForKey:kREQUEST];
        
        
        
        if ([obj isKindOfClass:[NSArray class]]) {
            //it was a bulk operation that failed
            NSArray* requests = [userInfo objectForKey:kREQUEST];
            
            //since it is a bulk operation, we only have one http response to
            //process
            
            
            for (Request* request in requests) {
                [self processRequestResponse:request withResponse:response];
                
            }
        }
        else {
            //it was a single resource operation that succeeded
            Request* request = [userInfo objectForKey:kREQUEST];
            [self processRequestResponse:request withResponse:response];
                      
            //we need to process any attachments (if any)
            if ([userInfo valueForKey:kATTACHMENTLIST] != nil) {
                NSArray* attributesWithAttachments = [userInfo valueForKey:kATTACHMENTLIST];
                
                //we process each attachment individually
                for (NSString* attribute in attributesWithAttachments) {
                    [self processAttachmentFor:attribute associatedWith:request];
                }
            }
        }
        
    }
    
    
}

#pragma mark - Enumeration Complete Handler
- (void) onEnumerateComplete:(Callback*)callback {
    
}
@end
