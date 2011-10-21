//
//  RequestManager.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OperationQueue.h"
@class Request;
@interface RequestManager : NSObject {
    OperationQueue* m_operationQueue;
    OperationQueue* m_enumerationQueue;
}

@property (nonatomic,retain) OperationQueue* operationQueue;
@property (nonatomic,retain) OperationQueue* enumerationQueue;
+ (RequestManager*)instance;
- (NSArray*)    attachmentAttributesInRequest:(Request*)request;
- (void) submitRequest:(Request*)request;
- (void) submitRequests:(NSArray*)requests;
@end
