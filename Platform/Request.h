//
//  Request.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callback.h"
#import <CoreData/CoreData.h>
#import "PutAttributeOperation.h"
#import "ASIProgressDelegate.h"
typedef enum {
    kCREATE,
    kMODIFY,
    kMODIFYATTACHMENT,
    kDELETE,
    kENUMERATION,
    kAUTHENTICATE,
    kIMAGEDOWNLOAD,
    kUPDATEAUTHENTICATOR,
    kSHARE
} RequestOperation;

typedef enum {
    kPENDING,
    kCOMPLETED,
    kFAILED
} RequestStatus;

@class Request;
@protocol RequestProgressDelegate <NSObject>
- (void) initializeWith:(NSArray*)requests;
- (void) request:(Request*)request setProgress:(float)progress;

@end

@interface Request : NSManagedObject <ASIProgressDelegate>{
    NSDictionary*   m_userInfo;
    Callback*       m_onSuccessCallback;
    Callback*       m_onFailCallback;
    
    long long       m_downloadSize;
    long long       m_uploadSize;
    long long       m_sentBytes;
    long long       m_downloadedBytes;
    float           m_progress;
    id <RequestProgressDelegate> m_delegate;
    
    NSString*       m_errorMessage;
    
    NSMutableArray* m_childRequests;
    Request*        m_parentRequest;
    
    NSArray*        m_consequentialUpdates;
    
}

@property (nonatomic,retain) NSDictionary* userInfo;
@property (nonatomic,retain) Callback*  onSuccessCallback;
@property (nonatomic,retain) Callback*  onFailCallback;
@property (nonatomic,retain) NSNumber*    operationcode;
@property (nonatomic,retain) NSNumber*    statuscode;
@property (nonatomic,retain) NSNumber*  targetresourceid;
@property (nonatomic,retain) NSString*  url;
@property (nonatomic,retain) NSString*  changedattributes;
@property (nonatomic,retain) NSString*  targetresourcetype;
@property                    long long  downloadSize;
@property                    long long  uploadSize;
@property                    long long  sentBytes;
@property                    long long  downloadedBytes;
@property (nonatomic,retain) NSString*  errormessage;
@property                    float      progress;
@property (nonatomic,retain) NSMutableArray*    childRequests;
@property (nonatomic,retain) Request*           parentRequest;
@property (nonatomic,retain) NSNumber*  objectid;
@property (nonatomic,retain) NSArray*   consequentialUpdates;

@property (nonatomic,retain) id<RequestProgressDelegate> delegate;


- (id) initFor:(NSNumber*)objectid 
withTargetObjectType:(NSString*)objecttype
 withOperation:(int)opcode 
withChangedAttributes:(NSArray*)changedAttributes
  withUserInfo:(NSDictionary*)userInfo 
     onSuccess:(Callback*)onSuccessCallback 
     onFailure:(Callback*)onFailureCallback;


- (NSDictionary*)putAttributeOperations;
- (void) updateRequestStatus:(RequestStatus)status;
- (NSArray*) attachmentAttributesInRequest;
- (NSArray*)changedAttributesList;
- (void) setChangedAttributesList:(NSArray*)changedAttributeList;

+ (id)          createInstanceOfRequest;
+ (id)          createAttachmentRequestFrom:(Request*)request 
                               forAttribute:(NSString*)attributeName;
+ (id)          createAttachmentRequestFor:(NSNumber*)resourceid 
                                withString:(NSString*)resourcetype
                                onSuccessCallback:(Callback*)onSuccessCallback
                         onFailureCallback:(Callback*)onFailCallback;
@end
