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

@implementation Resource
@dynamic resourceid;
@dynamic resourcetype;
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
        //we need to create a set of attribute description objects upon initialization 
        NSEntityDescription* entity = [self entity];
        NSDictionary* attributes = [entity attributesByName];
        NSMutableArray* attributeInstanceData = [[NSMutableArray alloc]init];
        for (NSString* attribute in attributes) {
            //create a new attribute type description object
            AttributeInstanceData* attributeMetadata = [AttributeInstanceData attributeInstanceDataFor:self.resourcetype withResourceContext:resourceContext forAttribute:attribute ];
            
            
            //add it to the internal attribute store
            [attributeInstanceData addObject:attributeMetadata];
        }
        self.attributeinstancedata = [[NSSet alloc]initWithArray:attributeInstanceData];
        [attributeInstanceData release];
        
        
        //we need to populate the type data for the object
        self.typeinstancedata = [TypeInstanceData typeForType:self.resourcetype withResourceContext:resourceContext];
        
    }

}


- (id) initWithEntity:(NSEntityDescription *)entity insertIntoResourceContext:(ResourceContext *)context {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        //TODO: need to generate resource id here
        self.resourcetype = [entity name];
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
    NSEntityDescription* entityDescription = [self entity];
    NSDictionary* attributes = [entityDescription attributesByName];
    
    for (NSAttributeDescription* attributeDescription in attributes) {
        if ([attributeDescription isKindOfClass:[NSAttributeDescription class]]) {
            NSString* attributeName = [attributeDescription name];
            
            if ([jsonDictionary valueForKey:attributeName] != nil) {
                id value = [jsonDictionary valueForKey:attributeName];
                [self setValue:value forKey:attributeName];
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
        self.resourcetype = [entity name];
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
- (BOOL) isResourceSynchronizedToCloud {
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
    NSDictionary* attributeValues = [self dictionaryFrom];
   

    
  
    
    NSError* error = nil;
    
    
    //we need to iterate through the object's attributes and compose a dictionary
    //of key-value pairs for attributes and references
    NSString* retVal = [attributeValues JSONStringWithOptions:JKSerializeOptionNone error:&error];
    
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
    return self.resourcetype;
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
        return obj;
    }
    
    
}

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
