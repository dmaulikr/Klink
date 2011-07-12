//
//  QueryOptions.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "QueryOptions.h"


@implementation QueryOptions
@synthesize referencingattribute;
@synthesize includelinkedobjects;
@synthesize referencingobjecttype;
@synthesize maxlinksreturnedperobject;
@synthesize sortAscending;
@synthesize sortattribute;

- (NSString*) toJSON {
    NSDictionary *jsonDictionary = [self toDictionary];

    NSString* retVal = [jsonDictionary JSONString];
    return retVal;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *jsonDictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    [jsonDictionary setValue:self.referencingattribute forKey:an_REFERENCINGATTRIBUTE];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.includelinkedobjects] forKey:an_INCLUDELINKEDOBJECTS];
    [jsonDictionary setValue:self.referencingobjecttype forKey:an_REFERENCINGOBJECTTYPE];
    [jsonDictionary setValue:[NSNumber numberWithInt:self.maxlinksreturnedperobject] forKey:an_MAXLINKSRETURNEDPEROBJECT];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.sortAscending] forKey:an_SORTASCENDING];
    [jsonDictionary setValue:self.sortattribute forKey:an_SORTATTRIBUTE];
    return jsonDictionary;
}
+(QueryOptions*)queryForTopics {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease]; 
    newQuery.referencingattribute=an_PHOTOID;
    newQuery.referencingobjecttype =CAPTION;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = size_NUMLINKEDOBJECTSTOTRETURN;
    newQuery.sortAscending = YES;
    newQuery.sortattribute=an_DATECREATED;
    return newQuery;
}

+(QueryOptions*)queryForPhotos {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=an_PHOTOID;
    newQuery.referencingobjecttype =CAPTION;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = size_NUMLINKEDOBJECTSTOTRETURN;
    newQuery.sortAscending = YES;
    newQuery.sortattribute=an_DATECREATED;
    return newQuery;

}

+(QueryOptions*)queryForThemes {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=an_THEMEID;
    newQuery.referencingobjecttype = PHOTO;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = size_NUMLINKEDOBJECTSTOTRETURN;
    newQuery.sortAscending = NO;
    newQuery.sortattribute = an_DATECREATED;
    return newQuery;
}

@end
