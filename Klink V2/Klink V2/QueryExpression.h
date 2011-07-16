//
//  QueryExpression.h
//  Klink V2
//
//  Created by Bobby Gill on 7/12/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"

@interface QueryExpression : NSObject <IWireSerializable> {
    NSString* attributeName;
    int opCode;
    NSString* value;
}
@property (nonatomic,retain) NSString* attributeName;
@property (nonatomic, retain) NSString* value;
@property int opCode;

- (NSDictionary*)toDictionary;
@end
