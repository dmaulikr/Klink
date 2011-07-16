//
//  QueryExpression.m
//  Klink V2
//
//  Created by Bobby Gill on 7/12/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "QueryExpression.h"
#import "JSONKit.h"
#import "AttributeNames.h"
#import "TypeNames.h"

@implementation QueryExpression
@synthesize attributeName;
@synthesize value;
@synthesize opCode;


- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.attributeName forKey:an_ATTRIBUTENAME];
    [newDictionary setValue:[NSNumber numberWithInt:self.opCode] forKey:an_OPCODE];
    [newDictionary setValue:self.value forKey:an_VALUE];
    

    
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
  
    return retVal;
    
}

//Returns a dictionary containing the contents of this object
- (NSDictionary*)toDictionary {
    NSMutableDictionary *jsonDictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    [jsonDictionary setValue:self.attributeName forKey:an_ATTRIBUTENAME];
    [jsonDictionary setValue:[NSNumber numberWithInt:self.opCode] forKey:an_OPCODE];
    [jsonDictionary setValue:self.value forKey:an_VALUE];

    return jsonDictionary;
}

@end
