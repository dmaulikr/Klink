//
//  QueryOptions.m
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "QueryOptions.h"
#import "Attributes.h"
#import "Types.h"
#import "ApplicationSettings.h"
#import "ApplicationSettingsManager.h"
#import "JSONKit.h"

@implementation QueryOptions
@synthesize  includelinkedobjects           = m_includelinkedobjects;
@synthesize  referencingattribute           = m_referencingattribute;
@synthesize  referencingobjecttype          = m_referencingobjecttype;
@synthesize  maxlinksreturnedperobject      = m_maxlinksreturnedperobject;
@synthesize linked_results_sortAscending    = m_linked_results_sortAscending;
@synthesize linked_results_sortattribute    = m_linked_results_sortattribute;
@synthesize primary_results_sortattribute   = m_primary_results_sortattribute;
@synthesize primary_results_sortascending   = m_primary_results_sortascending;

- (id) initFromJSON:(NSString *)json {
    NSDictionary* jsonDictionary = [json objectFromJSONString];
    return [self initFromJSONDictionary:jsonDictionary];
}

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    
    if (self) {
        self.includelinkedobjects = [[jsonDictionary valueForKey:INCLUDELINKEDOBJECTS]boolValue];
        self.referencingattribute = [jsonDictionary valueForKey:REFERENCINGATTRIBUTE];
        self.referencingobjecttype = [jsonDictionary valueForKey:REFERENCINGOBJECTTYPE];
        self.maxlinksreturnedperobject = [[jsonDictionary valueForKey:MAXLINKSRETURNEDPEROBJECT] intValue];
        self.linked_results_sortAscending = [[jsonDictionary valueForKey:LINKED_RESULTS_SORTASCENDING]boolValue];
        self.linked_results_sortattribute = [jsonDictionary valueForKey:LINKED_RESULTS_SORTATTRIBUTE];
        self.primary_results_sortascending = [[jsonDictionary valueForKey:PRIMARY_RESULTS_SORTASCENDING]boolValue];
        self.primary_results_sortattribute = [jsonDictionary valueForKey:PRIMARY_RESULTS_SORTATTRIBUTE];

    }
    return self;
}

- (NSString*) toJSON {
    NSDictionary *jsonDictionary = [self toDictionary];
    
    NSString* retVal = [jsonDictionary JSONString];
    return retVal;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *jsonDictionary = [[[NSMutableDictionary alloc]init]autorelease];
    
    [jsonDictionary setValue:self.referencingattribute forKey:REFERENCINGATTRIBUTE];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.includelinkedobjects] forKey:INCLUDELINKEDOBJECTS];
    [jsonDictionary setValue:self.referencingobjecttype forKey:REFERENCINGOBJECTTYPE];
    [jsonDictionary setValue:[NSNumber numberWithInt:self.maxlinksreturnedperobject] forKey:MAXLINKSRETURNEDPEROBJECT];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.linked_results_sortAscending] forKey:LINKED_RESULTS_SORTASCENDING];
    [jsonDictionary setValue:self.linked_results_sortattribute forKey:LINKED_RESULTS_SORTATTRIBUTE];
    [jsonDictionary setValue:[NSNumber numberWithBool:self.primary_results_sortascending] forKey:PRIMARY_RESULTS_SORTASCENDING];
    [jsonDictionary setValue:self.primary_results_sortattribute forKey:PRIMARY_RESULTS_SORTATTRIBUTE];
    return jsonDictionary;
}

#pragma mark - Static Initializers
+(QueryOptions*)queryForPhotos {
    ApplicationSettings* settingsObjects = [[ApplicationSettingsManager instance]settings];
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=PHOTOID;
    newQuery.referencingobjecttype =CAPTION;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = [settingsObjects.numberoflinkedobjectstoreturn intValue];
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute=NUMBEROFVOTES;
    newQuery.primary_results_sortascending = YES;
    newQuery.primary_results_sortattribute = DATECREATED;
    return newQuery;
    
}

+ (QueryOptions*)queryForApplicationSettings:(NSNumber *)userid {
    QueryOptions* newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = NO;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = VERSION;  
    return newQuery;
}

+ (QueryOptions*)queryForDrafts {
    ApplicationSettings* settingsObjects = [[ApplicationSettingsManager instance]settings];
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=THEMEID;
    newQuery.referencingobjecttype =PHOTO;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = [settingsObjects.numberoflinkedobjectstoreturn intValue];
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute=NUMBEROFVOTES;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = DATECREATED;
    return newQuery;
}

+(QueryOptions*)queryForPhotosInTheme {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = YES;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = NUMBEROFVOTES;
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute = NUMBEROFVOTES;
    newQuery.referencingattribute=PHOTOID;
    newQuery.referencingobjecttype=CAPTION;
    newQuery.maxlinksreturnedperobject=1;
    return newQuery;
    
}

+(QueryOptions*)queryForPages {
     ApplicationSettings* settingsObjects = [[ApplicationSettingsManager instance]settings];
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=THEMEID;
    newQuery.referencingobjecttype = PHOTO;
    newQuery.includelinkedobjects = YES;
    newQuery.maxlinksreturnedperobject = [settingsObjects.numberoflinkedobjectstoreturn intValue];
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute = DATECREATED;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = DATECREATED;
    return newQuery;
}

+(QueryOptions*)queryForFeedsForUser:(NSNumber *)userID {
    QueryOptions *newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = YES;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = DATECREATED;
    
    return newQuery;
}

+(QueryOptions*)queryForCaptions:(NSNumber*)photoID{
    QueryOptions* newQuery = [[QueryOptions alloc]autorelease];
    newQuery.referencingattribute=nil;
    newQuery.referencingobjecttype = nil;
    newQuery.includelinkedobjects = NO;
    newQuery.maxlinksreturnedperobject = 0;
    newQuery.linked_results_sortAscending = NO;
    newQuery.linked_results_sortattribute = DATECREATED;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = DATECREATED;

    return newQuery;
}

+ (QueryOptions*)queryForUser:(NSNumber *)userID {
    QueryOptions* newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = NO;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = DATECREATED;  
    return newQuery;

}

+(QueryOptions*)queryForObjectIDs:(NSArray*)objectIDs 
                        withTypes:(NSArray*)objectTypes 
{
    QueryOptions* newQuery = [[QueryOptions alloc]autorelease];
    newQuery.includelinkedobjects = NO;
    newQuery.primary_results_sortascending = NO;
    newQuery.primary_results_sortattribute = nil;
    return newQuery;
}
@end
