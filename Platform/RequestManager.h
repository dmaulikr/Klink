//
//  RequestManager.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Request;
@interface RequestManager : NSObject {
    NSOperationQueue* m_operationQueue;
    NSOperationQueue* m_enumerationQueue;
}

@property (nonatomic,retain) NSOperationQueue* operationQueue;
@property (nonatomic,retain) NSOperationQueue* enumerationQueue;
+ (RequestManager*)instance;

- (void) submitRequest:(Request*)request;
- (void) submitRequests:(NSArray*)requests;
@end
