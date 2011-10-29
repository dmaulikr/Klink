//
//  Query.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Query.h"
#import "Attributes.h"
#import "QueryExpression.h"
#import "Types.h"
#import "OpCodes.h"
#import "JSONKit.h"
#import "Feed.h"
#import "ResourceContext.h"
@implementation Query
@synthesize filterObjectType        = m_filterObjectType;
@synthesize attributeExpressions    = m_attributeExpressions;
@synthesize queryOptions            = m_queryOptions;


- (NSString*) toJSON {
    NSMutableDictionary* newDictionary = [[NSMutableDictionary alloc] init];

    [newDictionary setValue:self.filterObjectType forKey:FILTEROBJECTTYPE];
    
    if (self.attributeExpressions != nil) {
        NSMutableArray* list =[[NSMutableArray alloc]init];
        for (int i = 0; i < [self.attributeExpressions count];i++) {
            QueryExpression* expression = [self.attributeExpressions objectAtIndex:i];
            NSDictionary* expressionDictionary = [expression toDictionary];
            [list insertObject:expressionDictionary atIndex:i];
        }
        [newDictionary setValue:list forKey:ATTRIBUTEEXPRESSIONS];
        [list release];
    }
    
    if (self.queryOptions != nil) {
        NSDictionary* queryOptionsDictionary = [self.queryOptions toDictionary];
        [newDictionary setValue:queryOptionsDictionary forKey:QUERYOPTIONS];
    }
    
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;
    
}

- (id) initFromJSON:(NSString *)json {
    NSDictionary* dictionary = [json objectFromJSONString];
    self.filterObjectType = [dictionary valueForKey:FILTEROBJECTTYPE];
    self.attributeExpressions = [dictionary valueForKey:ATTRIBUTEEXPRESSIONS];
    
    NSDictionary* queryOptionsDictionary = [dictionary valueForKey:QUERYOPTIONS];
    if (queryOptionsDictionary != nil) {
        self.queryOptions = [[QueryOptions alloc]initFromJSONDictionary:queryOptionsDictionary];
    }
    return self;
}

#pragma mark - Static Initializers
+ (id) queryPhotosWithTheme:(NSNumber*)themeID {
    Query* query =  [[[Query alloc] init]autorelease];
    query.filterObjectType = PHOTO;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = THEMEID;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [themeID stringValue];
    
    NSArray* expressions = [NSArray arrayWithObject:queryExpression];
    query.attributeExpressions = expressions;
    
    //query.queryOptions = [QueryOptions queryForPhotosInTheme];
    [queryExpression release];
    
    return query;
}

+ (Query*)queryFeedsForUser : (NSNumber*)userID {
    Query* query = [[[Query alloc]init]autorelease];
    query.filterObjectType = FEED;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = USERID;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [userID stringValue];
    
    NSMutableArray* expressions = [NSMutableArray arrayWithObject:queryExpression];
    [queryExpression release];
    
    //we need to query the database to find the feed object with the highest id for this user
    ResourceContext* resourceContext = [ResourceContext instance];
    NSArray* feedItems = [resourceContext resourcesWithType:FEED withValueEqual:[userID stringValue] forAttribute:USERID sortBy:DATECREATED sortAscending:NO];
  
    
    if ([feedItems count] > 0) {
        QueryExpression* queryExpression2 = [[QueryExpression alloc]init];
        queryExpression2.attributeName = ID;
        queryExpression2.opCode = opcode_QUERYGREATERTHAN;
        Feed* feedItem = [feedItems objectAtIndex:0];
        queryExpression2.value = [feedItem.objectid stringValue];
        [expressions addObject:queryExpression2];
        [queryExpression2 release];
    }
    
    
    query.attributeExpressions = expressions;
    
    
    
    return query;
}

+ (Query*)queryPages {
    Query* query =  [[[Query alloc] init]autorelease];
    //TODO: change "theme" to "page" when implemented on the server
    query.filterObjectType = @"theme";
    
    return query;
}


+ (Query*)queryCaptionsForPhoto:(NSNumber*)photoID {
    Query* query = [[[Query alloc]init ]autorelease];
    query.filterObjectType = CAPTION;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = PHOTOID;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [photoID stringValue];
    
    NSArray* expressions = [NSArray arrayWithObject:queryExpression];
    query.attributeExpressions = expressions;
    
    [queryExpression release];
    return query;
}
@end
