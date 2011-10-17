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

typedef enum {
    kCREATE,
    kMODIFY,
    kDELETE
} RequestOperation;

typedef enum {
    kPENDING,
    kCOMPLETED,
    kFAILED
} RequestStatus;

@interface Request : Resource {
    NSDictionary*   m_userInfo;
    Callback*       m_onSuccessCallback;
    Callback*       m_onFailCallback;
    
    
}

@property (nonatomic,retain) NSDictionary* userInfo;
@property (nonatomic,retain) Callback*  onSuccessCallback;
@property (nonatomic,retain) Callback*  onFailCallback;
@property  int    operationcode;
@property  int    statuscode;
@property (nonatomic,retain) NSNumber*  targetresourceid;
@property (nonatomic,retain) NSString*  url;
@property (nonatomic,retain) NSString*  changedattributes;
@property (nonatomic,retain) NSArray*   changedAttributesList;
@property (nonatomic,retain) NSString*  targetresourcetype;
- (id) initFor:(NSNumber*)objectid 
 withOperation:(int)opcode 
  withUserInfo:(NSDictionary*)userInfo 
     onSuccess:(Callback*)onSuccessCallback 
     onFailure:(Callback*)onFailureCallback;


@end
