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
#define kREQUEST    @"REQUEST"
#define kATTACHMENTLIST @"ATTACHMENTLIST"

@implementation RequestManager
@synthesize operationQueue = m_operationQueue;

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

- (ASIHTTPRequest*) requestFor:(RequestOperation)opcode 
                       withURL:(NSString*)url 
                  withUserInfo:(NSDictionary*)userInfo {
    if (opcode == kCREATE) {
        ASIFormDataRequest* httpRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        httpRequest.delegate = self;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        
        return httpRequest;
    }
    else if (opcode == kMODIFY) {
        ASIHTTPRequest* httpRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        httpRequest.delegate = self;
        httpRequest.requestMethod = @"POST";
        httpRequest.userInfo = userInfo;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        return httpRequest;                           
                                   
    }
    return nil;
}



- (void) processAttachmentFor:(NSString*)attribute associatedWith:(Request*)request {
    //will take the initial target object id
    //and upload the file location that is contained
    //within the attribute passed in
    ResourceContext* context = [ResourceContext instance];
    
    Resource* resource = [context resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    
    SEL selector = NSSelectorFromString(attribute);
    
    if ([resource respondsToSelector:selector]) {        
        NSString* value = [resource performSelector:selector];
        
        
        AuthenticationContext* authenticationContext = [[AuthenticationManager instance]contextForLoggedInUser];
        NSURL* url = [UrlManager urlForUploadAttachment:resource.resourceid withObjectType:resource.resourcetype forAttributeName:attribute withAuthenticationContext:authenticationContext];
        
        ASIFormDataRequest* httpRequest = [ASIFormDataRequest requestWithURL:url];
        [httpRequest setFile:value forKey:@"attachment"];
        httpRequest.delegate = self;
        httpRequest.didFailSelector = @selector(onRequestFailed:);
        httpRequest.didFinishSelector = @selector(onRequestSucceeded:);
        httpRequest.userInfo = nil;
        
        [self.operationQueue addOperation:httpRequest];
    }
}

- (void) processDelete:(Request*) request {
    //TODO: implement delete functionality
}

- (void) processModify:(Request*) request {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    
    NSArray* changedAttributes = request.changedAttributesList;
    
    NSString* json = [resource toJSON:changedAttributes];
    
    //now we have the json representation of all the attributes that changed
    
    //we need to know which attributes are attachment types, as they will need to 
    //be uploaded seperately after the initial set are done
    NSArray* attributeInstanceDataList = [resource attributeInstanceDataForList:changedAttributes];
    
    NSMutableArray* urlAttachmentsList = [[NSMutableArray alloc]init];
    
    for (AttributeInstanceData* aid in attributeInstanceDataList) {
        if ([aid.isurlattachment boolValue]) {
            //the attribute is a url attachment
            //we need to upload it seperately
            [urlAttachmentsList addObject:aid.attributename];
        }
    }
    
    //we now have a list of all attachments that need to be processed
    //we attach it as userinfo to the original request
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:request forKey:kREQUEST];
    [userInfo setObject:urlAttachmentsList forKey:kATTACHMENTLIST];
    
    //we submit the initial put operation with the request
    //the attachments will be processed on the return leg
    ASIFormDataRequest* httpRequest = (ASIFormDataRequest*)[self requestFor:kMODIFY withURL:request.url withUserInfo:userInfo];
    [httpRequest setPostValue:json forKey:@""];
    
    [self.operationQueue addOperation:httpRequest];
}


- (void) processCreates:(NSArray*) requests {
    //bulk create in one shot
    
    NSMutableArray* resourcesToCreate = [[NSMutableArray alloc]init];
    
    ResourceContext* resourceContext = [ResourceContext instance];

    NSString* url = nil;
    
    for (Request* request in requests) {
        Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
        NSString* resourceJSON = [resource toJSON];
        [resourcesToCreate addObject:resourceJSON];
        
        if (url == nil) {
            //need to pull out one of the URLs, it is
            //assumed that all elements have the same URL
            url = request.url;
        }
    }
    
    //we now have a json representation of each resource
    NSString* json = [resourcesToCreate JSONString];

        
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:requests forKey:kREQUEST];

    ASIFormDataRequest* httpRequest =(ASIFormDataRequest*) [self requestFor:kCREATE withURL:url withUserInfo:userInfo];
    [httpRequest setPostValue:json forKey:@""];
    [self.operationQueue addOperation:httpRequest];
    
    
}
- (void) processCreate:(Request*) request {
    //single shot creates
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* resource = [resourceContext resourceWithType:request.targetresourcetype withID:request.targetresourceid];
    NSString* json = [resource toJSON];
    
    if (resource != nil) {
        
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setObject:request forKey:kREQUEST];
        
        ASIFormDataRequest* httpRequest = (ASIFormDataRequest*)[self requestFor:request.operationcode withURL:request.url withUserInfo:userInfo];
        [httpRequest setPostValue:json forKey:@""];
        [self.operationQueue addOperation:httpRequest];
        
        
    }
    else {
        //TODO: log an error for a missing object
    }
}

#pragma mark - Public interface
- (void) submitRequest:(Request*)request {
        //take in a request
        //get a url
        //create a http request
    if (request.operationcode == kCREATE) {
        [self processCreate:request];
    }
    else if (request.operationcode == kDELETE) {
        [self processDelete:request];
    }
    else if (request.operationcode == kMODIFY) {
        [self processModify:request];
    }
        
}

- (void) submitRequests:(NSArray*)requests {
    
    BOOL isCreateStream = NO;
    
    for (Request* request in requests) {
        if (request.operationcode == kCREATE) {
            isCreateStream = YES;
        }
        else {
            isCreateStream = NO;
            //we break because we know this is not a homogenous stream of Requests of the 
            //same operation code
            break;
        }
    }
    
    if (isCreateStream) {
        [self processCreates:requests];
    }
    
}

#pragma mark - Async Request Handlers
- (void) processModifyResponse:(NSString*)responseString withRequest:(Request*)request {
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    PutResponse* putResponse = [[PutResponse alloc] initFromDictionary:jsonDictionary];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* modifiedResource = putResponse.modifiedResource;
    Resource* existingResource = [resourceContext resourceWithType:modifiedResource.resourcetype withID:modifiedResource.resourceid];

    [existingResource refreshWith:modifiedResource];
    
    
    for (Resource* resource in putResponse.secondaryResults) {
        existingResource = nil;
        existingResource = [resourceContext resourceWithType:resource.resourcetype withID:resource.resourceid];
        [existingResource refreshWith:resource];
    }
    
    [resourceContext save:YES onFinishCallback:nil];
    
}

- (void) processCreateResponse:(NSString*)responseString withRequest:(Request*)request {
    NSDictionary* jsonDictionary = [responseString objectFromJSONString];
    
    //create a create response handler
    CreateResponse* createResponse = [[CreateResponse alloc] initFromDictionary:jsonDictionary];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    for (Resource* createdResource in createResponse.createdResources)  {
        Resource* existingResource = [resourceContext resourceWithType:createdResource.resourcetype withID:createdResource.resourceid];
        [existingResource refreshWith:createdResource];
      
    }
    [resourceContext save:YES onFinishCallback:nil];
}


- (void) onRequestFailed:(ASIHTTPRequest*)request {
    NSDictionary* userInfo = request.userInfo;
    
    NSObject* obj = [userInfo objectForKey:kREQUEST];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        //it was a bulk operation that failed
        NSArray* requests = [userInfo objectForKey:kREQUEST];
        for (Request* request in requests) {
            //mark the request has having failed
            request.statuscode = kFAILED;
            
            //execute the fail selector on each request
            if (request.onFailCallback != nil) {
                [request.onFailCallback fire];
            }
        }
    }
    else {
        //it was a single resource operation that failed
        Request* request = [userInfo objectForKey:kREQUEST];
        request.statuscode = kFAILED;
        if (request.onFailCallback != nil) {
            [request.onFailCallback fire];
        }
    }
}

- (void) onRequestSucceeded:(ASIHTTPRequest*)request {
    NSDictionary* userInfo = request.userInfo;
    NSString* response = [request responseString];
    if (userInfo != nil) {
        NSObject* obj = [userInfo objectForKey:kREQUEST];
        ResourceContext* context = [ResourceContext instance];
        
        
        if ([obj isKindOfClass:[NSArray class]]) {
            //it was a bulk operation that failed
            NSArray* requests = [userInfo objectForKey:kREQUEST];
            for (Request* request in requests) {
                //process the specific request response
                if (request.operationcode == kCREATE) {
                    
                    //processing a create response
                    [self processCreateResponse:response withRequest:request];
                }
                else if (request.operationcode == kMODIFY) {
                    //processing a modify response
                    [self processModifyResponse:response withRequest:request];
                }
                else if (request.operationcode == kDELETE) {
                    //TODO: implement response handling for deletes
                }
                
                //mark the request being completed
                request.statuscode = kCOMPLETED;
                
                //execute the success selector on each request
                if (request.onSuccessCallback != nil) {
                    [request.onSuccessCallback fire];
                }
                
                //we need to mark an object as being "synchronized" to the cloud
                
                
                [context markResourceAsBeingSynchronized:request.targetresourceid withResourceType:request.targetresourcetype];
            }
        }
        else {
            //it was a single resource operation that succeeded
            Request* request = [userInfo objectForKey:kREQUEST];
            
            if (request.onSuccessCallback != nil) {
                [request.onSuccessCallback fire];
            }
            [context markResourceAsBeingSynchronized:request.targetresourceid withResourceType:request.targetresourcetype];
            
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
@end
