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
#import "Page.h"
#import "PageState.h"
@implementation Query
@synthesize filterObjectType        = m_filterObjectType;
@synthesize attributeExpressions    = m_attributeExpressions;
@synthesize queryOptions            = m_queryOptions;
@synthesize objectIDs               = m_objectIDs;
@synthesize objectTypes             = m_objectTypes;

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
    
    if (self.objectIDs != nil) {
        [newDictionary setValue:self.objectIDs forKey:OBJECTIDS];
    }
    
    if (self.objectTypes != nil) {
        [newDictionary setValue:self.objectTypes forKey:OBJECTTYPES];
    }
    
    NSError* error = nil;
    JKSerializeOptionFlags flags = JKSerializeOptionNone;
    
    NSString *retVal =[newDictionary JSONStringWithOptions:flags error:&error];
    [newDictionary release];
    return retVal;
    
}

- (id) initFromJSON:(NSString *)json {
    self = [super init];
    
    if (self) {
        NSDictionary* dictionary = [json objectFromJSONString];
        self.filterObjectType = [dictionary valueForKey:FILTEROBJECTTYPE];
        self.attributeExpressions = [dictionary valueForKey:ATTRIBUTEEXPRESSIONS];
        self.objectIDs = [dictionary valueForKey:OBJECTIDS];
        self.objectTypes = [dictionary valueForKey:OBJECTTYPES];
        NSDictionary* queryOptionsDictionary = [dictionary valueForKey:QUERYOPTIONS];
        if (queryOptionsDictionary != nil) {
            QueryOptions* qo = [[QueryOptions alloc]initFromJSONDictionary:queryOptionsDictionary];
            self.queryOptions = qo;
            [qo release];
        }
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
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    NSMutableArray* sortDescriptorArray = [NSMutableArray arrayWithObject:sortDescriptor];
    
    //NSArray* feedItems = [resourceContext resourcesWithType:FEED withValueEqual:[userID stringValue] forAttribute:USERID sortBy:DATECREATED sortAscending:NO];
    NSArray* feedItems = [resourceContext resourcesWithType:FEED withValueEqual:[userID stringValue] forAttribute:USERID sortBy:sortDescriptorArray];
  
    
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
    
    
    [sortDescriptor release];
    return query;
}
+ (id) queryForIDs:(NSArray*)objectIDs 
         withTypes:(NSArray*)types {
    
    Query* query = [[[Query alloc]init]autorelease];
    query.objectIDs = objectIDs;
    query.objectTypes =types;
    
    
    return query;
    
}

+ (Query*)queryDrafts {
    Query* query = [[[Query alloc]init]autorelease];
    query.filterObjectType = PAGE;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = STATE;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [[NSNumber numberWithInt:kDRAFT]stringValue];
    
    query.attributeExpressions = [NSArray arrayWithObject:queryExpression];
    
    [queryExpression release];
    return query;
    
}

+ (Query*)queryPages {
    Query* query =  [[[Query alloc] init]autorelease];
    query.filterObjectType = PAGE;
    
    return query;
}

+ (Query*)queryUser:(NSNumber*)userid {
    Query* query = [[[Query alloc]init ]autorelease];
    query.filterObjectType = USER;
    
    QueryExpression* queryExpression = [[QueryExpression alloc]init];
    queryExpression.attributeName = ID;
    queryExpression.opCode = opcode_QUERYEQUALITY;
    queryExpression.value = [userid stringValue];
    
    query.attributeExpressions = [NSArray arrayWithObject:queryExpression];
    
    [queryExpression release];
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
