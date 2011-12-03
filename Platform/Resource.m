//
//  Resource.m
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"
#import "LoggerCommon.h"
#import "LoggerClient.h"
#import "JSONKit.h"
#import "AttributeInstanceData.h"
#import "ResourceContext.h"
#import "Attributes.h"
#import "TypeInstanceData.h"
#import "Macros.h"
#import "Request.h"
#import "Types.h"

@implementation Resource
@dynamic objectid;
@dynamic objecttype;
@dynamic datecreated;
@dynamic datemodified;
@dynamic attributeinstancedata;
@dynamic typeinstancedata;
@synthesize resourceContext = m_resourceContext;
@synthesize iswebservicerepresentation = m_iswebservicerepresentation;

- (void) dealloc {
    [super dealloc];
    
}

- (void) commonInitWith:(ResourceContext*)resourceContext {
    if (resourceContext != nil) {
        [self createTypeInstanceData:resourceContext];
        [self createAttributeInstanceData:resourceContext];
       
       
        
                
    }

}




- (id) initWithEntity:(NSEntityDescription *)entity insertIntoResourceContext:(ResourceContext *)context {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        //TODO: need to generate resource id here
        self.objectid = [context nextID];
        self.objecttype = [entity name];
        self.attributeinstancedata = nil;
        self.iswebservicerepresentation = NO;
        self.typeinstancedata = nil;
        [self commonInitWith:context];
    }
    
    return self;
}


//Returns a boolean indicating whether the JSON dictionary is a valid Resource
//in that it contains all necessary mandatory attributes
- (BOOL) doesJSONDictionaryContainValidResource:(NSDictionary*)jsonDictionary {
    NSEntityDescription* entityDescription = [self entity];
    NSDictionary* properties = [entityDescription propertiesByName];
    BOOL retVal = YES;
    
    for (NSAttributeDescription* propertyDescription in properties) {
        if ([propertyDescription isKindOfClass:[NSPropertyDescription class]]) {
            BOOL isRequired = ![propertyDescription isOptional];
            NSString* propertyName = [propertyDescription name];
            
            if (isRequired) {
                if ([jsonDictionary valueForKey:propertyName] == nil) {
                    retVal = NO;
                    break;
                }
            }
        }
        
    }
    
    return retVal;

}

//Extracts values from a apassed in JSON instance and populates attributes
//on this object accordingly
- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"Resource.readAttributesFromJSONDictionary:";
    NSEntityDescription* entityDescription = [self entity];

    NSArray* attributeDescriptions = [entityDescription properties];
    
    for (NSAttributeDescription* attrDesc in attributeDescriptions) {
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]]) {
              id value = [jsonDictionary valueForKey:[attrDesc name]];
            //its an attribute description object
            if (value != nil && value != [NSNull null]) {
                NSAttributeType attrType = [attrDesc attributeType];
                if (attrType == NSBooleanAttributeType ||
                    attrType == NSInteger64AttributeType) {
                    [self setValue:value forKey:[attrDesc name]];
                    
                }
                else if (attrType == NSDoubleAttributeType) {
                    [self setValue:value  forKey:[attrDesc name]];
                }
                else if (attrType == NSStringAttributeType) {
                    if ([value isKindOfClass:[NSString class]]) {
                        
                        if (![[attrDesc name]isEqualToString:RESOURCETYPE]) {
                            [self setValue:value forKey:[attrDesc name]];
                        }
                        
                    }
                    else {
                        [self setValue:[value stringValue] forKey:[attrDesc name]];
                    }
                }
                else if (attrType == NSTransformableAttributeType) {
                    [self setValue:value forKey:[attrDesc name]];
                }
                else {
                    //unsupported attribute type
                    LOG_RESOURCE(1,@"%@Unsupported attribute type in JSON string: %d",activityName,attrType);
                }
            }
        }
    }

    
}



- (id) initFromJSONDictionary:(NSDictionary*)jsonDictionary 
        withEntityDescription:(NSEntityDescription*)entity insertIntoResourceContext:(ResourceContext*)resourceContext{
    
    if (resourceContext != nil) {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    }
    else {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:nil];
    }
    
    if (self)  {
        self.objecttype = [entity name];
        self.iswebservicerepresentation = YES;
         [self commonInitWith:resourceContext];
        
        //check to ensure json conforms to the schema
        BOOL isJSONValid = [self doesJSONDictionaryContainValidResource:jsonDictionary];
        
        if (!isJSONValid) {
            //TODO: log an error for an invalid schema
            return nil;
        }
        [self readAttributesFromJSONDictionary:jsonDictionary];       
    }
    return self;
}

#pragma mark - Metadata accessors and setters
- (BOOL) shouldResourceBeSynchronizedToCloud {
    //evaluates whether this is a cloud type, and if it is, and if this instance 
    //is not one that was created by a download of json by the web service, then it will return true
    BOOL retVal = YES;
    
    if (self.typeinstancedata == nil ||
        self.attributeinstancedata == nil) {
        retVal = NO;
        return retVal;
    }
    
    if (self.iswebservicerepresentation) {
        //if the object was inserted due to being downloaded from the cloud
        //then by definition it shouldnt be sync'ed back up
        retVal = NO;
        return retVal;
    }
    //if it is a synchronized type, then the answer to this question is always no
    if (![self.typeinstancedata.iscloudtype boolValue]) {
        retVal = NO;
        return retVal;
    }
 
    
    return retVal;
    
    
}
- (BOOL) isResourceTypeSynchronizedToCloud {
    return [self.typeinstancedata.iscloudtype boolValue];
}

- (void) markAsDirty {
    //foreach attribute description for this object, we go through
    //and mark it dirty
    NSArray* attributeInstanceData = [self.attributeinstancedata allObjects];
    for (int i = 0; i < [attributeInstanceData count]; i++) {
        AttributeInstanceData* attributeInstance = [attributeInstanceData objectAtIndex:i];
        attributeInstance.isdirty = [NSNumber numberWithBool:YES];
    }
    
}

- (void) markAsDirty:(NSArray*)changedAttributes {
    
    for (NSString* changedAttribute in changedAttributes) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:changedAttribute];
        if (aid != nil) {
            aid.isdirty = [NSNumber numberWithBool:YES];
        }
    }
    
}

- (void) markAsClean {
    //go through each attribute description and mark it clean
    NSArray* attributeInstanceData = [self.attributeinstancedata allObjects];
    for (int i = 0; i < [attributeInstanceData count]; i++) {
        AttributeInstanceData* attributeInstance = [attributeInstanceData objectAtIndex:i];
        attributeInstance.isdirty = [NSNumber numberWithBool:NO];
    }
}

- (void) markAsClean:(NSArray *)cleanedAttributes {
    for (NSString* attribute in cleanedAttributes) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:attribute];
        aid.isdirty = [NSNumber numberWithBool:NO];
    }
}

- (AttributeInstanceData*) attributeInstanceDataFor:(NSString *)attribute {
    SEL selector = NSSelectorFromString(attribute);
    
    
    if ([self respondsToSelector:selector]) {
        NSArray* attributeData = [self.attributeinstancedata allObjects];
        for (AttributeInstanceData* aidata in attributeData) {
            if ([aidata.attributename isEqualToString:attribute]) {
                return aidata;
            }
        }
    }
    return nil;
}

- (NSArray*) attributeInstanceDataForList:(NSArray *)attributes 
{
    NSMutableArray* retVal = [[NSMutableArray alloc]init] ;
    
    for (NSString* attributeName in attributes) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:attributeName];
        
        if (aid != nil) {
            [retVal addObject:aid];
        }
    }
    return retVal;
                              
}

- (void) lockAttributes:(NSArray *)attributes {
    for (NSString* attribute in attributes) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:attribute];
        aid.islocked = [NSNumber numberWithBool:YES];
    }
}

- (void) unlockAttributes:(NSArray*)attributes {
    for (NSString* attribute in attributes) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:attribute];
        aid.islocked = [NSNumber numberWithBool:NO];
    }
}

- (void) createAttributeInstanceData:(ResourceContext*)resourceContext {
    //creates an empty set of attribute instance data for this object
    //we only need attribute instance values for types which are sync'ing to the cloud
    NSEntityDescription* entity = [self entity];
    
    if (self.typeinstancedata.iscloudtype) {
        NSDictionary* attributes = [entity attributesByName];
        NSMutableArray* attributeInstanceData = [[NSMutableArray alloc]init];
        for (NSString* attribute in attributes) {
            //create a new attribute type description object
            AttributeInstanceData* attributeMetadata = [AttributeInstanceData attributeInstanceDataFor:self.objecttype withResourceContext:resourceContext forAttribute:attribute ];
            
            
            //add it to the internal attribute store
            [attributeInstanceData addObject:attributeMetadata];
        }
        self.attributeinstancedata = [[NSSet alloc]initWithArray:attributeInstanceData];
        [attributeInstanceData release];
    }
}

- (void) createTypeInstanceData:(ResourceContext*)resourceContext {
    //creates an default type instance data object for this object
  
    self.typeinstancedata = [TypeInstanceData typeForType:self.objecttype withResourceContext:resourceContext];

}

- (BOOL) shouldCopyAttributeValue:(id)value forAttribute:(NSAttributeDescription*)attributeDescription {
    BOOL retVal = NO;
    
    NSAttributeType attrType = [attributeDescription attributeType];
    SEL selector = NSSelectorFromString([attributeDescription name]);
    
    if ([self respondsToSelector:selector]) {
        id currVal = [self valueForKey:[attributeDescription name]];
        AttributeInstanceData* attributeMetadata = [self attributeInstanceDataFor:[attributeDescription name]];
        
        if (attrType == NSBooleanAttributeType ||
            attrType == NSInteger64AttributeType ||
            attrType == NSDoubleAttributeType) {
            
            NSNumber* currNumberValue = (NSNumber*)currVal;
            NSNumber* otherNumberValue = (NSNumber*)value;
            
            if (![currNumberValue isEqualToNumber:otherNumberValue] &&
                ![attributeMetadata.islocked boolValue]) {
                //the values differ and the local value is not locked
                retVal = YES;
                
            }
            else {
                retVal = NO;
            }
          
            
        }
      
        else if (attrType == NSStringAttributeType) {
            NSString* currStringValue = (NSString*)currVal;
            NSString* otherStringValue = (NSString*)value;
                  
            if (currStringValue == nil && otherStringValue != nil) {
                retVal = YES;
            }
            else if (![currStringValue isEqualToString:otherStringValue] &&
                     ![attributeMetadata.islocked boolValue]) {
                retVal = YES;
            }
            else {
                retVal = NO;
            }
        
        
        }
        else if (attrType == NSTransformableAttributeType) {
            retVal = YES;
        }

    }
    else {
        //this object doesnt have a value, so a value should be copied into it
        retVal = YES;
    }
    return retVal;
}

- (NSArray*) copyFrom:(Resource*)resource {
    NSEntityDescription* entity = [self entity];
    NSArray* attributes = [entity properties];
    NSMutableArray* attributesCopied = [[NSMutableArray alloc]init];
    
    for (NSAttributeDescription* attrDesc in attributes) {
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]]) {
            //see if the passed in object has a value for this attribute
            SEL selector = NSSelectorFromString([attrDesc name]);
            if ([resource respondsToSelector:selector]) {
                //other object has a value for this selector
                id val = [resource performSelector:selector];
                if ([self shouldCopyAttributeValue:val forAttribute:attrDesc]) {
                    [self setValue:val forKey:[attrDesc name]];
                    [attributesCopied addObject:[attrDesc name]];
                }
            }
        }
    }
    return attributesCopied;
}

- (void)refreshWith:(Resource *)newResource {
    //refreshes the object with the server provided values
    NSArray* attributesCopied = [self copyFrom:newResource];
    
    //marks the objects as being clean
    [self markAsClean:attributesCopied];
    
}
    


- (TypeInstanceData*) typeInstanceData {
    return self.typeinstancedata;
}

- (id) dictionaryFrom {
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc]init]autorelease];
    NSEntityDescription* entityDescription = [self entity];
    NSDictionary* attributes = [entityDescription attributesByName];
    
    for (NSString* attribute in attributes) {
        SEL selector = NSSelectorFromString(attribute);
        id attributeValue = [self performSelector:selector];
        
        if (attributeValue != nil) {
            [dictionary setObject:attributeValue forKey:attribute];
        }
    }

    return dictionary;
}

#pragma mark - IJSONSerializable Methods
- (NSString*) toJSON {
    
    
    NSEntityDescription* entity = [self entity];
    NSArray* attributeDescriptions = [entity properties];
    NSMutableDictionary* objectAsDictionary = [[NSMutableDictionary alloc]init];
    
    for (NSAttributeDescription* attrDesc in attributeDescriptions) {
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]]) {
            SEL selector = NSSelectorFromString([attrDesc name]);
            if ([self respondsToSelector:selector]) {
                id attrValue = [self performSelector:selector];
                [objectAsDictionary setValue:attrValue forKey:[attrDesc name]];
            }
        }
    }
   
    //we now have a dictionary of all attribute values for this object
    
    
    
  
    
    NSError* error = nil;
    
    
    //we need to iterate through the object's attributes and compose a dictionary
    //of key-value pairs for attributes and references
    NSString* retVal = [objectAsDictionary JSONStringWithOptions:JKSerializeOptionNone error:&error];
    
    if (error != nil) {
       
        return nil;
    }
    else {
        
        return retVal;
    }
    
}

- (NSString*) toJSON:(NSArray *)attributes {
    //returns a JSOn representation of only the attributes specified in the array
    NSMutableDictionary* resourceDictionary = [[NSMutableDictionary alloc]init];
   
    
    for (NSString* attributeName in attributes) {
        SEL selector = NSSelectorFromString(attributeName);
        if ([self respondsToSelector:selector]) {
            id attributeValue = [self performSelector:selector];
            [resourceDictionary setObject:attributeValue forKey:attributeName];
        }
        else {
            //TODO: log error in invalid attribute passed in
        }
    }
    
    NSError* error = nil;
    
    
    //we need to iterate through the object's attributes and compose a dictionary
    //of key-value pairs for attributes and references
    NSString* retVal = [resourceDictionary JSONStringWithOptions:JKSerializeOptionNone error:&error];
    
    if (error != nil) {
        //error in json serialization
       //TODO: log error in json serialization
        return nil;
    }
    else {
        
        return retVal;
    }

    
    
}

- (NSString*) componentName {
    return self.objecttype;
}

//returns a list of all attribute names that have a non-nil value in this object
- (NSArray*) attributesWithValues {
    NSEntityDescription* entity = [self entity];
    NSArray* properties = [entity properties];
    NSMutableArray* retVal = [[NSMutableArray alloc]init];
    
    for (NSAttributeDescription* attrDesc in properties) {
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]]) {
            //get the value on the object
            NSString* attributeName = [attrDesc name];
            SEL selector = NSSelectorFromString(attributeName);
            if ([self respondsToSelector:selector]) {
                id value = [self performSelector:selector];
                if (value != nil) {
                    [retVal addObject:attributeName];
                }
            }
        }
    }
    return retVal;

}

//returns a list of all attachment attributes that currently have a value in the data store
- (NSArray*) attachmentAttributesWithValues {
    NSMutableArray* retVal = [[[NSMutableArray alloc]init ]autorelease];
    NSArray* attributesWithValues = [self attributesWithValues];
    
    for (NSString* attributeName in attributesWithValues) {
        AttributeInstanceData* aid = [self attributeInstanceDataFor:attributeName];
        if ([aid.isurlattachment boolValue]) {
            [retVal addObject:attributeName];
        }
    }
    return retVal;
}

//returns a list of all attribues that have been changed ont his object
//and that should be sync'ed to the cloud
- (NSArray*)changedAttributesToSynchronizeToCloud {
    NSMutableArray* retVal = [[NSMutableArray alloc]init] ;
    NSDictionary* changedValues = [self changedValues];
    
    
    if (changedValues != nil &&
        [self shouldResourceBeSynchronizedToCloud]) {
        for (NSString* attrName in changedValues) {     
            //we will not include NIL or NULL attributes
            SEL sel = NSSelectorFromString(attrName);
            id val = [self performSelector:sel];
            
            AttributeInstanceData* aid = [self attributeInstanceDataFor:attrName];
            
            if (val != nil 
              /*  && [aid.isdirty boolValue] */ 
                && ![aid.islocal boolValue]) 
            {
                [retVal addObject:attrName]; 
            }
           
        }
    }
    
    return retVal;
}



#pragma mark - Static Initializers
+ (NSString*)   typeNameFromJSON:(NSDictionary*)jsonDictionary {
    NSString* retVal = nil;
      if ([jsonDictionary valueForKey:RESOURCETYPE] != nil) {
        retVal = [jsonDictionary valueForKey:RESOURCETYPE];
      }

    return retVal;
}


+ (id) createInstanceOfType:(NSString *)type 
        withResourceContext:(ResourceContext*)context {
    
    //create single user object
 
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:type inManagedObjectContext:context.managedObjectContext];
   
  
    Resource* obj = [[[Resource alloc]initWithEntity:entityDescription insertIntoResourceContext:context]autorelease];
 
    
    return obj;

}



//creates a new instance of a Resource based off of a JSON representation
//returns the object in a non-syncable form
+ (id) createInstanceOfTypeFromJSON:(NSDictionary*)jsonDictionary 
                withResourceContext:(ResourceContext*)resourceContext {
    
    //find the type name
    NSString* type = [Resource typeNameFromJSON:jsonDictionary];
    
    if (!type) {
        //TODO: log error messasge for missing type
    }
    
    NSEntityDescription* entityDescription;
    if (resourceContext != nil) {
        entityDescription = [[NSEntityDescription entityForName:type inManagedObjectContext:resourceContext.managedObjectContext]retain];
    }
    else {
        NSManagedObjectContext* context = [[ResourceContext instance] managedObjectContext];
        entityDescription = [[NSEntityDescription entityForName:type inManagedObjectContext:context]retain]; 
    }
    
    if (!entityDescription) {
        //TODO: log error message for invalid type
        return nil;
    }
    else {
        //now we need to initialize it from the JSON string passed in
      
        Resource* obj = [[[Resource alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entityDescription insertIntoResourceContext:resourceContext]autorelease];
        
        //the object is being created from JSON, which means it was brought down from the service, marking it as not needing sync'ing
        
        return obj;
    }
    
    
    
    
}
//objects created from JSON are not inserted into any managed contexts
+ (id) createInstanceOfTypeFromJSON:(NSDictionary*)jsonDictionary {
    return [self createInstanceOfTypeFromJSON:jsonDictionary withResourceContext:nil];
}

+ (id) createInstanceOfTypeFromJSONString:(NSString *)jsonString {
    NSDictionary* jsonDictionary = [jsonString objectFromJSONString];
    return [Resource createInstanceOfTypeFromJSON:jsonDictionary];
}

+ (id) createInstanceOfTypeFromJSONString:(NSString *)jsonString withResourceContext:(ResourceContext *)context {
    
    NSDictionary* jsonDictionary = [jsonString objectFromJSONString];
    return [Resource createInstanceOfTypeFromJSON:jsonDictionary withResourceContext:context];
}








@end
