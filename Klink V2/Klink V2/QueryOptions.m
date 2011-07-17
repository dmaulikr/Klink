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
@synthesize linked_results_sortAscending;
@synthesize linked_results_sortattribute;
@synthesize primary_results_sortascending;
@synthesize primary_results_sortattribute;

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
    [jsonDictionary setValue:[NSNumber numberWithBool:self.linked_results_sortAscending] forKey:an_LINKED_RESULTS_SORTASCENDING];
    [jsonDictionary setValue:self.linked_results_sortattribute forKey:an_LINKED_RESULTS_SORTATTRIBUTE];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.primary_results_sortascending] forKey:an_PRIMARY_RESULTS_SORTASCENDING];
    [jsonDictionary setValue:self.primary_results_sortattribute forKey:an_PRIMARY_RESULTS_SORTATTRIBUTE];
    return jsonDictionary;
}

#pragma mark - static initializers for well known view controller use cases
+(QueryOptions*)queryForTopics {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease]; 
    newQuery.referencingattribute=an_PHOTOID;
    newQuery.referencingobjecttype =CAPTION;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = size_NUMLINKEDOBJECTSTOTRETURN;
    newQuery.linked_results_sortAscending = YES;
    newQuery.linked_results_sortattribute=an_DATECREATED;
    newQuery.primary_results_sortascending = YES;
    newQuery.primary_results_sortattribute = an_DATECREATED;
    return newQuery;
}

+(QueryOptions*)queryForPhotos {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=an_PHOTOID;
    newQuery.referencingobjecttype =CAPTION;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = size_NUMLINKEDOBJECTSTOTRETURN;
    newQuery.linked_results_sortAscending = YES;
    newQuery.linked_results_sortattribute=an_DATECREATED;
    newQuery.primary_results_sortascending = YES;
    newQuery.primary_results_sortattribute = an_DATECREATED;
    return newQuery;

}

+(QueryOptions*)queryForThemes {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=an_THEMEID;
    newQuery.referencingobjecttype = PHOTO;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = pageSize_THEMELINKEDOBJECTS;
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute = an_DATECREATED;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = an_DATECREATED;
    return newQuery;
}

+(QueryOptions*)queryForPhotosInTheme {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = YES;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = an_DATECREATED;
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute = an_DATECREATED;
    newQuery.referencingattribute=an_PHOTOID;
    newQuery.referencingobjecttype=CAPTION;
    newQuery.maxlinksreturnedperobject=1;
    return newQuery;
    
}

@end
