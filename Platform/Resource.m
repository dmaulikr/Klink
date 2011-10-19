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


- (void) dealloc {
    [super dealloc];
    
}

- (void) commonInitWith:(ResourceContext*)resourceContext {
    if (resourceContext != nil) {
        NSEntityDescription* entity = [self entity];
        
        //we need to populate the type data for the object
        self.typeinstancedata = [TypeInstanceData typeForType:self.objecttype withResourceContext:resourceContext];

        //we only need attribute instance values for types which are sync'ing to the cloud
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

}


- (id) initWithEntity:(NSEntityDescription *)entity insertIntoResourceContext:(ResourceContext *)context {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        //TODO: need to generate resource id here
        self.objecttype = [entity name];
        self.attributeinstancedata = nil;
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
                        [self setValue:value forKey:[attrDesc name]];
                    }
                    else {
                        [self setValue:[value stringValue] forKey:[attrDesc name]];
                    }
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
    BOOL retVal = NO;
    
    if (self.typeinstancedata == nil ||
        self.attributeinstancedata == nil) {
        retVal = NO;
        return retVal;
    }
    
    //if it is a synchronized type, then the answer to this question is always no
    if (!self.typeinstancedata.iscloudtype) {
        retVal = NO;
        return retVal;
    }
    
    //if the object has been marked not to sync to the cloud, then
    //the return value can only be no
    if (!self.typeinstancedata.shouldsynctocloud) {
        retVal = NO;
        return retVal;
    }
    
    //at this point, we check all of the attributes of this object
    //and if there are dirty attributes, we then return YES
    for (AttributeInstanceData* aid in self.attributeinstancedata) {
        if (aid.isdirty) {
            retVal = YES;
            return retVal;
        }
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

- (void) markAsClean {
    //go through each attribute description and mark it clean
    NSArray* attributeInstanceData = [self.attributeinstancedata allObjects];
    for (int i = 0; i < [attributeInstanceData count]; i++) {
        AttributeInstanceData* attributeInstance = [attributeInstanceData objectAtIndex:i];
        attributeInstance.isdirty = [NSNumber numberWithBool:NO];
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

- (void)refreshWith:(Resource *)newResource {
    //TODO: implement refresh resource code
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
    NSString* activityName = [NSString stringWithFormat:@"%@.JSONString:",[self componentName]];
    
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
        //error in json serialization
        LogMessage(activityName, 0, [error description]);
        return nil;
    }
    else {
        LogMessage(activityName, 1, @"object serialized to JSON");
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
        entityDescription = [[NSEntityDescription entityForName:type inManagedObjectContext:resourceContext.managedObjectContext]autorelease];
    }
    else {
        NSManagedObjectContext* context = [[ResourceContext instance] managedObjectContext];
        entityDescription = [[NSEntityDescription entityForName:type inManagedObjectContext:context]autorelease]; 
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
