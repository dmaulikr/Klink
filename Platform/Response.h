//
//  Response.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"
@interface Response : NSObject <IJSONSerializable> {
    NSNumber* m_didSucceed;
    NSNumber* m_errorCode;
    NSString* m_errorMessage;
    
}
- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary;
@property (nonatomic, retain) NSNumber* errorCode;
@property (nonatomic, retain) NSString* errorMessage;
@property (nonatomic, retain) NSNumber* didSucceed;

@end
