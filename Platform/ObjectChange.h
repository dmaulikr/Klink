//
//  ObjectChange.h
//  Platform
//
//  Created by Jasjeet Gill on 5/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectChange : NSManagedObject <IJSONSerializable>

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary withEntityDescription:(NSEntityDescription *)entity insertIntoResourceContext:(ResourceContext *)resourceContext;
- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary;
+ (id) createInstanceOfObjectChangeFromJSON:(NSDictionary*)jsonDictionary;

@property (nonatomic,retain) NSNumber* datecreated;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSNumber* targetobjectid;
@property (nonatomic,retain) NSNumber* objectchange;

@end
