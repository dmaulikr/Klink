//
//  QueryExpression.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "QueryExpression.h"
#import "Attributes.h"
#import "JSONKit.h"

@implementation QueryExpression
@synthesize attributeName   = m_attributeName;
@synthesize value           = m_value;
@synthesize opCode          = m_opCode;

- (NSString*)toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.attributeName forKey:ATTRIBUTENAME];
    [newDictionary setValue:[NSNumber numberWithInt:self.opCode] forKey:OPCODE];
    [newDictionary setValue:self.value forKey:VALUE];

    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *jsonDictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    [jsonDictionary setValue:self.attributeName forKey:ATTRIBUTENAME];
    [jsonDictionary setValue:[NSNumber numberWithInt:self.opCode] forKey:OPCODE];
    [jsonDictionary setValue:self.value forKey:VALUE];
    
    return jsonDictionary;
}
@end
