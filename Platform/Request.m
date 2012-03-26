//
//  Request.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Request.h"
#import "Types.h"
#import "Macros.h"
#import "IDGenerator.h"
@implementation Request
@synthesize onFailCallback      = m_onFailCallback;
@synthesize onSuccessCallback   = m_onSuccessCallback;
@synthesize userInfo            = m_userInfo;
@synthesize downloadSize        = m_downloadSize;
@synthesize uploadSize          = m_uploadSize;
@synthesize sentBytes           = m_sentBytes;
@synthesize downloadedBytes     = m_downloadedBytes;
@synthesize delegate            = m_delegate;
@synthesize childRequests       = m_childRequests;
@synthesize parentRequest       = m_parentRequest;
@synthesize progress            = m_progress;
@dynamic targetresourceid;
@dynamic operationcode;
@dynamic statuscode;
@dynamic url;
@dynamic changedattributes;
@dynamic targetresourcetype;
@dynamic errormessage;
@dynamic objectid;

#define kDelimeter @","


#pragma initializers
- (id) initWithEntity:(NSEntityDescription*)entity insertIntoResourceContext:(ResourceContext*)resourceContext {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    if (self) {
        self.statuscode = [NSNumber numberWithInt:kPENDING];
        self.downloadSize = 0;
        self.sentBytes = 0;
        self.downloadSize = 0;
        self.downloadedBytes = 0;
        self.parentRequest = nil;
        
        NSMutableArray* cr = [[NSMutableArray alloc]init];
        self.childRequests = cr;
        [cr release];
    }
    return self;
}
- (id) initFor:(NSNumber *)objectid
withTargetObjectType:(NSString*)objecttype
 withOperation:(int)opcode
withChangedAttributes:(NSArray*)changedAttributes
  withUserInfo:(NSDictionary *)userInfo 
     onSuccess:(Callback *)onSuccessCallback 
     onFailure:(Callback *)onFailureCallback 
{
   
    NSString* activityName = @"Request.initRequest:";
    
    //initialize the request to be pending
    self.statuscode = [NSNumber numberWithInt:kPENDING];
    self.targetresourcetype = objecttype;
    self.targetresourceid = objectid;
    self.operationcode = [NSNumber numberWithInt:opcode];
    self.onFailCallback = onFailureCallback;
    self.onSuccessCallback = onSuccessCallback;
    self.userInfo = userInfo;
    self.downloadSize = 0;
    self.sentBytes = 0;
    self.downloadSize = 0;
    self.downloadedBytes = 0;
    
    [self setChangedAttributesList:changedAttributes];
    
//    NSMutableArray* cr = [[NSMutableArray alloc]init];
//    self.childRequests = cr;
//    [cr release];
    
//    if (opcode != kMODIFYATTACHMENT && 
//        opcode != kCREATE &&
//        opcode != kDELETE) {
//        //attachments dont have children
//        //we do not process attachments for creates
//        //we do not process attachments for deletes
//        
//        NSArray* attachmentsInThisRequest = [self attachmentAttributesInRequest];
//        //we have a list of all attachments that will need to be processed
//        //we iterate through them and create child Requests for them
//        for (NSString* attributeName in attachmentsInThisRequest) {
//            Request* childRequest = [Request createAttachmentRequestFrom:self forAttribute:attributeName];            
//            //add the request to our child collection
//            [self.childRequests addObject:childRequest];
//        }
//
//        
//    }
    
    LOG_REQUEST(0, @"%@Initialized new Request %@ for TargetID:%@, TargetType:%@, OperationCode:%d, #ChildRequests:%d",activityName,self.objectid,objectid,objecttype,opcode,[self.childRequests count]);
    
    return self;
}

- (NSArray*) attachmentAttributesInRequest {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSArray* changedAttributes = [self changedAttributesList];
    Resource* resource = [resourceContext resourceWithType:self.targetresourcetype withID:self.targetresourceid];
    
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
- (NSArray*)changedAttributesList {
    return [self.changedattributes componentsSeparatedByString:kDelimeter];
}
- (void) setChangedAttributesList:(NSArray*)changedAttributeList {
    self.changedattributes =  @"";
    
    for (int i = 0; i < [changedAttributeList count]; i++) {
        self.changedattributes = [NSString stringWithFormat:@"%@%@",self.changedattributes,[changedAttributeList objectAtIndex:i]];
        
        if (i < [changedAttributeList count]-1) {
            self.changedattributes = [NSString stringWithFormat:@"%@%@",self.changedattributes,kDelimeter];
        }
    }
    

}

- (void) dealloc {
    self.childRequests = nil;
    self.parentRequest = nil;
}

- (int) numberOfChildRequestsCompleted {
    //returns an integer representing the number of childrequests that are in the pending state
    int retVal = 0;
    
    for (Request* request in self.childRequests) {
        if ([request.statuscode intValue] != kPENDING) {
            retVal++;
        }
    }
    return retVal;
}

- (void) updateRequestProgressIndicator {
    NSString* activityName = @"Request.updateRequestProgressIndicator:";
    float progressDenominator = 1;
    float progressNumerator = 0;
    
    if ([self.statuscode intValue] != kPENDING) {
        progressNumerator++;
    }
    
    if ([self.childRequests count] > 0) {
        //has child requests
        
        //we need to set the progress float to being a proportion of the number
        //of child requests still pending
        progressNumerator += [self numberOfChildRequestsCompleted];
        progressDenominator += [self.childRequests count];
        
        
    }
    
    //now we update our progress float
    self.progress = progressNumerator / progressDenominator;
    LOG_REQUEST(0, @"%@Updating Request %@ progress indicator to be %f (%f/%f)",activityName,self.objectid,self.progress,progressNumerator,progressDenominator);
    //we also need to update the Parent's request progres indicator
    if (self.parentRequest != nil) {
        [self.parentRequest updateRequestProgressIndicator];
    }
    
        //we report back to the delegate about the request's progress change
        [self.delegate request:self setProgress:self.progress];
    

}
- (void) updateRequestStatus:(RequestStatus)status {
    NSString* activityName = @"Request.updateRequestStatus:";
    self.statuscode = [NSNumber numberWithInt:status];
     
    LOG_REQUEST(0, @"%@Request %@ status changed to %d",activityName,self.objectid,status);
    //we need to update this Request's progress meter
    [self updateRequestProgressIndicator];
    
}
- (NSDictionary*)putAttributeOperations {
    NSMutableDictionary* retVal = [[[NSMutableDictionary alloc]init]autorelease];
    NSArray* changedAttributes = [self changedAttributesList];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Resource* resource = [resourceContext resourceWithType:self.targetresourcetype withID:self.targetresourceid];
    
    for(NSString* changedAttribute in changedAttributes) {
       
                   
                PutAttributeOperation* attributeOperation = [resource putAttributeOperationFor:changedAttribute];
                [retVal setValue:attributeOperation forKey:changedAttribute];
    
    }
    return retVal;
}

#pragma mark - ASIProgressDelegate Members


- (void) request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes {
 //   NSString* activityName = @"Request.requestDidSendBytes:";
    self.sentBytes += bytes;
    //LOG_REQUEST(0, @"%@Sent %qi bytes, total bytes sent: %qi, total upload size:%qi",activityName,bytes,self.sentBytes,self.uploadSize);
}

- (void) request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
//     NSString* activityName = @"Request.incrementUploadSizeBy::";
    self.uploadSize += newLength;
    //LOG_REQUEST(0, @"%@Incrementing upload size by %qi bytes, total upload size:%qi",activityName,newLength,self.uploadSize);
}

- (void) request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength {
  //   NSString* activityName = @"Request.incrementDownloadSizeBy:";
    self.downloadSize += newLength;
    //LOG_REQUEST(0, @"%@Incrementing download size by %qi bytes, total download size:%qi",activityName,newLength,self.downloadSize);
}

- (void) request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
 //    NSString* activityName = @"Request.requestDidReceiveBytes:";
    self.downloadedBytes += bytes;
    //LOG_REQUEST(0, @"%@Received %qi bytes, total bytes received: %qi, total download size:%qi",activityName,bytes,self.downloadedBytes,self.downloadSize);

}

#pragma mark - Static Initializers

+ (id) createInstanceOfRequest {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:REQUEST inManagedObjectContext:resourceContext.managedObjectContext];
    Request* retVal = [[Request alloc]initWithEntity:entity insertIntoResourceContext:nil];
    //give it an objectid
    retVal.objectid = [[IDGenerator instance] generateNewId:REQUEST];
    [retVal autorelease];
    return retVal;
}

+ (id) createAttachmentRequestFor:(NSNumber*)resourceid 
                       withString:(NSString*)resourcetype
                onSuccessCallback:(Callback*)onSuccessCallback
                onFailureCallback:(Callback*)onFailCallback
{
    Request* newRequest = [Request createInstanceOfRequest];
    newRequest.onFailCallback = onFailCallback;
    newRequest.onSuccessCallback = onSuccessCallback;
    newRequest.operationcode =[NSNumber numberWithInt:kMODIFYATTACHMENT];
    newRequest.targetresourceid = resourceid;
    newRequest.targetresourcetype = resourcetype;
    newRequest.statuscode =[NSNumber numberWithInt:kPENDING];
    return newRequest;
}

+ (id) createAttachmentRequestFrom:(Request *)request forAttribute:(NSString*)attributeName{
    Request* newRequest = [Request createInstanceOfRequest];
    newRequest.onFailCallback = request.onFailCallback;
    newRequest.onSuccessCallback = request.onSuccessCallback;
    newRequest.operationcode =[NSNumber numberWithInt:kMODIFYATTACHMENT];
    newRequest.targetresourceid = request.targetresourceid;
    newRequest.targetresourcetype = request.targetresourcetype;
    newRequest.statuscode =[NSNumber numberWithInt:kPENDING];
    [newRequest setChangedAttributesList:[NSArray arrayWithObject:attributeName]];
    
    newRequest.parentRequest = request;
    return newRequest;
    
}
@end
