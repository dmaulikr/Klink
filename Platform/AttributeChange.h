//
//  AttributeChange.h
//  Platform
//
//  Created by Jasjeet Gill on 4/11/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "IJSONSerializable.h"

@interface AttributeChange : NSManagedObject <IJSONSerializable>

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity insertIntoResourceContext:(ResourceContext*)resourceContext;

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary;
+ (id) createInstanceOfAttributeChangeFromJSON:(NSDictionary *)jsonDictionary; 

@property (nonatomic,retain) NSNumber* targetobjectid;
@property (nonatomic,retain) NSString* targetobjecttype;
@property (nonatomic,retain) NSString* attributename;
@property (nonatomic,retain) NSNumber* delta;
@property (nonatomic,retain) NSString* oldvalue;
@property (nonatomic,retain) NSString* newvalue;
@property (nonatomic,retain) NSNumber* opcode;
@property (nonatomic,retain) NSNumber* hasbeenprocessed;
@end
