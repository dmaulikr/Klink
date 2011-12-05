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

@interface Request : NSManagedObject {
    NSDictionary*   m_userInfo;
    Callback*       m_onSuccessCallback;
    Callback*       m_onFailCallback;
    
    
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


- (id) initFor:(NSNumber*)objectid 
withTargetObjectType:(NSString*)objecttype
 withOperation:(int)opcode 
  withUserInfo:(NSDictionary*)userInfo 
     onSuccess:(Callback*)onSuccessCallback 
     onFailure:(Callback*)onFailureCallback;


- (NSDictionary*)putAttributeOperations;


- (NSArray*)changedAttributesList;
- (void) setChangedAttributesList:(NSArray*)changedAttributeList;

+ (id)          createInstanceOfRequest;
+ (id)          createAttachmentRequestFrom:(Request*)request;
+ (id)          createAttachmentRequestFor:(NSNumber*)resourceid 
                                withString:(NSString*)resourcetype
                                onSuccessCallback:(Callback*)onSuccessCallback
                         onFailureCallback:(Callback*)onFailCallback;
@end
