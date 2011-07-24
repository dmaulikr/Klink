//
//  QueryOptions.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"
#import "JSONKit.h"
#import "AttributeNames.h"
#import "TypeNames.h"
#import "ApplicationSettings.h"
@interface QueryOptions : NSObject <IWireSerializable> {
    BOOL includelinkedobjects;
    NSString *referencingattribute;
    NSString *referencingobjecttype;
    int maxlinksreturnedperobject;
    BOOL linked_results_sortAscending;
    NSString* linked_results_sortattribute;
    
    BOOL primary_results_sortascending;
    NSString* primary_results_sortattribute;
}

@property BOOL includelinkedobjects;
@property (nonatomic,retain) NSString* referencingattribute;
@property (nonatomic,retain) NSString* referencingobjecttype;
@property int maxlinksreturnedperobject;
@property BOOL linked_results_sortAscending;
@property (nonatomic,retain) NSString* linked_results_sortattribute;
@property (nonatomic, retain) NSString* primary_results_sortattribute;
@property BOOL primary_results_sortascending;

+(QueryOptions*)queryForTopics;
+(QueryOptions*)queryForPhotos;
+(QueryOptions*)queryForThemes;
+(QueryOptions*)queryForPhotosInTheme;
+(QueryOptions*)queryForFeedsForUser:(NSNumber*)userID;
- (NSDictionary*)toDictionary;
@end
