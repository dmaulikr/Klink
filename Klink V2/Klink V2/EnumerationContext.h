//
//  EnumerationContext.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWireSerializable.h"
#import "AttributeNames.h"
#import "JSONKit.h"
#import "BLLog.h"
#import "ApplicationSettings.h"

@class Theme;
@class Photo;
@interface EnumerationContext : NSObject <IWireSerializable>{
    NSNumber* isDone;
    NSNumber* pageSize;
    NSNumber* numberOfResultsReturned;
    NSNumber* pageNumber;
    NSNumber* maximumNumberOfResults;
}

@property (nonatomic,retain) NSNumber* pageSize;
@property (nonatomic,retain) NSNumber* numberOfResultsReturned;
@property (nonatomic,retain) NSNumber* pageNumber;
@property (nonatomic,retain) NSNumber* isDone;
@property (nonatomic,retain) NSNumber* maximumNumberOfResults;


+ (EnumerationContext*) contextForPhotosInTheme:(Theme*)theme;
+ (EnumerationContext*) contextForThemes;
+ (EnumerationContext*) contextForCaptions:(Photo*)photo;
- (id) init;
@end
