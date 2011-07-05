//
//  Response.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"
#import "AttributeNames.h"
#import "BLLog.h"

@class ServerManagedResource;
@interface Response : NSObject <IWireSerializable> {
    NSNumber* didSucceed;
    NSNumber* errorCode;
    NSString* errorMessage;
    
}
- (id) initFromDictionary:(NSDictionary*)jsonDictionary;
@property (nonatomic, retain) NSNumber* errorCode;
@property (nonatomic, retain) NSString* errorMessage;
@property (nonatomic, retain) NSNumber* didSucceed;

@end
