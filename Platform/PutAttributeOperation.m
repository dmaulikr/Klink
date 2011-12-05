//
//  PutAttributeOperation.m
//  Platform
//
//  Created by Jasjeet Gill on 12/4/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "PutAttributeOperation.h"



@implementation PutAttributeOperation
@synthesize operationCode = m_operationCode;
@synthesize value = m_value;


+ (PutAttributeOperation*)putOperationWithCode:(int)putOperationAttributeCode 
                                     withValue:(id)value {
    
    PutAttributeOperation* retVal = [[[PutAttributeOperation alloc]init]autorelease];
    retVal.operationCode = putOperationAttributeCode;
    retVal.value = value;
    return retVal;
}
@end
