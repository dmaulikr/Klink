//
//  Resource.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TypeInstanceData.h"
#import "AttributeInstanceData.h"
#import "LoggerClient.h"
#import "IJSONSerializable.h"
#import "PutAttributeOperation.h"

@class ResourceContext;
@interface Resource : NSManagedObject <IJSONSerializable> {
    ResourceContext*    m_resourceContext;
    BOOL                m_iswebservicerepresentation;
}
@property   (nonatomic,retain)  TypeInstanceData*   typeinstancedata;
@property   (nonatomic,retain)  NSNumber*           objectid;
@property   (nonatomic,retain)  NSString*           objecttype;
@property   (nonatomic,retain)  NSNumber*           datecreated;
@property   (nonatomic,retain)  NSNumber*           datemodified;
@property   (nonatomic,retain)  NSSet*              attributeinstancedata;
@property   (nonatomic,retain)  ResourceContext*    resourceContext;

@property                       BOOL                iswebservicerepresentation;

- (id) initWithEntity:(NSEntityDescription *)entity 
insertIntoResourceContext:(ResourceContext *)context;

- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext;

//IJSONSerializable members
- (NSString*)   toJSON;
- (NSString*)   toJSON:(NSArray*)attributes;


- (id)          dictionaryFrom;

//Utility Methods
- (void)        markAsDirty;
- (void)        markAsDirty:(NSArray*)changedAttributes;
- (void)        markAsClean;
- (void)        markAsClean:(NSArray*)cleanedAttributes;
- (BOOL)        shouldResourceBeSynchronizedToCloud;
- (BOOL)        isResourceTypeSynchronizedToCloud;
- (AttributeInstanceData*) attributeInstanceDataFor:(NSString*)attributeName;
- (NSArray*) attributeInstanceDataForList:(NSArray*)attributes;
- (TypeInstanceData*) typeInstanceData;
- (void)        refreshWith:(Resource*)newResource;
- (void)        lockAttributes:(NSArray*)attributes;
- (void)        unlockAttributes:(NSArray*)attributes;
- (void)        createAttributeInstanceData:(ResourceContext*)resourceContext;
- (void)        createTypeInstanceData:(ResourceContext*)resourceContext;
- (void)        resetAttributeInstanceDataToDefault;

- (NSArray*) changedAttributesToSynchronizeToCloud;
- (NSArray*) attributesWithValues;
- (NSArray*) attributesFor:(NSArray*)attributeNames;

- (PutAttributeOperation*) putAttributeOperationFor:(NSString*)attribute;

- (NSArray*) attachmentAttributesWithValues;
//Used for logging
- (NSString*)   componentName;


//Static initializers
+ (id)          createInstanceOfType:(NSString*)type 
                 withResourceContext:(ResourceContext*)context;
+ (id)          createInstanceOfTypeFromJSON:(NSDictionary*)jsonDictionary 
                         withResourceContext:(ResourceContext*)context;
+ (id)          createInstanceOfTypeFromJSON:(NSDictionary*)jsonDictionary; 
+ (id)          createInstanceOfTypeFromJSONString:(NSString*)jsonString;
+ (id)          createInstanceOfTypeFromJSONString:(NSString*)jsonString 
                               withResourceContext:(ResourceContext*)context;


@end
