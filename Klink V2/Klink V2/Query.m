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
@synthesize attributeExpressions;

- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];
    [newDictionary setValue:self.objectIDs forKey:an_OBJECTIDS];
    [newDictionary setValue:self.filterExpression forKey:an_FILTEREXPRESSION];
    [newDictionary setValue:self.filterobjecttype forKey:an_FILTEROBJECTTYPE];
    
    if (self.attributeExpressions != nil) {
        NSMutableArray* list =[[NSMutableArray alloc]init];
        for (int i = 0; i < [self.attributeExpressions count];i++) {
            QueryExpression* expression = [self.attributeExpressions objectAtIndex:i];
            NSDictionary* expressionDictionary = [expression toDictionary];
            [list insertObject:expressionDictionary atIndex:i];
        }
        [newDictionary setValue:list forKey:an_ATTRIBUTEEXPRESSIONS];
        [list release];
    }
    
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

#pragma mark - Static constructors for well known view controller uses

+ (Query*) queryWithIds:(NSArray*)ids {
    Query* query = [[[Query alloc]init ]autorelease];
    [query initWithIds:ids];
    return query;
}

+ (Query*) queryWithObjectType:(NSString*)objectType {
    Query* query = [[[Query alloc]init ]autorelease];
    query.filterobjecttype = objectType;
    return query;
    
}

+ (Query*) queryPhotosWithTheme:(NSNumber*)themeID {
    Query* query =  [[[Query alloc] init]autorelease];
    query.filterobjecttype = PHOTO;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = an_THEMEID;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [themeID stringValue];
    
    NSArray* expressions = [NSArray arrayWithObject:queryExpression];
    query.attributeExpressions = expressions;
    
    [queryExpression release];
    return query;
    
}

+ (Query*)queryThemes {
    Query* query =  [[[Query alloc] init]autorelease];
    query.filterobjecttype = tn_THEME;
    
    return query;
}

@end
