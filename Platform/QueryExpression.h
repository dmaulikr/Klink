//
//  QueryExpression.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"

@interface QueryExpression : NSObject <IJSONSerializable>{
    NSString*   m_attributeName;
    int         m_opCode;
    NSString*   m_value;
}

@property (nonatomic,retain)    NSString* attributeName;
@property (nonatomic, retain)   NSString* value;
@property                       int opCode;

- (NSString*)toJSON;
- (NSDictionary*)toDictionary;

@end
