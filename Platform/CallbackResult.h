//
//  CallbackResult.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Callback;
@class Response;
@interface CallbackResult : NSObject {
    NSDictionary* m_context;
    Response* m_response;
}

@property (nonatomic,retain) NSDictionary* context;
@property (nonatomic,retain) id  response; 


+ (CallbackResult*) resultForCallback:(Callback*)callback;
@end
