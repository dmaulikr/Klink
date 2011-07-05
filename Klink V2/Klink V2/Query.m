//
//  Query.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/17/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Query.h"


@implementation Query
@synthesize  objectIDs;
@synthesize filterExpression;
@synthesize filterobjecttype;
@synthesize queryoptions;

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.objectIDs forKey:an_OBJECTIDS];
    [newDictionary setValue:self.filterExpression forKey:an_FILTEREXPRESSION];
    [newDictionary setValue:self.filterobjecttype forKey:an_FILTEROBJECTTYPE];
    
    if (self.queryoptions != nil) {
        NSDictionary* queryOptionsDictionary = [self.queryoptions toDictionary];
        [newDictionary setValue:queryOptionsDictionary forKey:an_QUERYOPTIONS];
    }
    
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;

}

- (id)initWithIds:(NSArray*)ids {
    self.objectIDs = ids;
    
    return self;
}

+ (Query*) queryWithIds:(NSArray*)ids {
    Query* query = [[Query alloc]autorelease];
    [query initWithIds:ids];
    return query;
}

+ (Query*) queryWithObjectType:(NSString*)objectType {
    Query* query = [[Query alloc]autorelease];
    query.filterobjecttype = objectType;
    return query;
    
}
@end
