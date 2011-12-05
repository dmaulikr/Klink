//
//  PutAttributeOperation.h
//  Platform
//
//  Created by Jasjeet Gill on 12/4/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef enum {
    kADD,
    kREMOVE,
    kREPLACE
} PutOperationAttributeCode;

@interface PutAttributeOperation : NSObject {
    PutOperationAttributeCode m_operationCode;
    id m_value;
}

@property PutOperationAttributeCode operationCode;
@property (nonatomic, retain) id    value;

//static initializers
+ (PutAttributeOperation*)putOperationWithCode:(int)putOperationAttributeCode withValue:(id)value;
@end
