//
//  IJSONSerializable.h
//  Platform
//
//  Created by Bobby Gill on 10/11/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResourceContext;
@protocol IJSONSerializable <NSObject>

@optional
- (NSString*) toJSON;
- (NSString*) toJSON:(NSArray*)attributeNames;
- (id) initFromJSON:(NSString*)json;
- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary;
- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext;
@end
