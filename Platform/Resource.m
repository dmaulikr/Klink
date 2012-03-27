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
#import "IDGenerator.h"

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
        self.objectid = [[IDGenerator instance] generateNewId:[entity name]];
        [self setObjecttype:[entity name]];
        //self.objecttype = [entity name];
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
    
    //hack to ensure follows are always uploaded to the cloud
    if ([self.objecttype isEqualToString:FOLLOW])
    {
        retVal = YES;
        return retVal;
    }
    
    
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
    [retVal autorelease];
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
        NSSet* aidset = [[NSSet alloc]initWithArray:attributeInstanceData];
        self.attributeinstancedata = aidset;
        [aidset release];
        [attributeInstanceData release];
    }
}

- (void) createTypeInstanceData:(ResourceContext*)resourceContext {
    //creates an default type instance data object for this object
  
    self.typeinstancedata = [TypeInstanceData typeForType:self.objecttype withResourceContext:resourceContext];

}

- (BOOL) shouldCopyAttributeValue:(id)value forAttribute:(NSAttributeDescription*)attributeDescription {
    BOOL retVal = NO;
   // NSString* activityName = @"Resource.shouldCopyAttributeValue:";
   // NSString* attributeName = [attributeDescription name];
    
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
              //  LOG_RESOURCE(0,@"%@Skipping copying of attribute %@ as the attribute is either locked or the same on source object",activityName,attributeName);
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
               // LOG_RESOURCE(0,@"%@Skipping copying of attribute %@ as the attribute is either locked or the same on source object",activityName,attributeName);
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

- (id) changedValueFor:(NSString*)attribute {
    id retVal = nil;
    NSDictionary* changedValues = [self changedValues];
    
    for (NSString* key in changedValues) {
        if ([key isEqualToString:attribute]) {
            retVal = [changedValues valueForKey:key];
        }
    }
    
    return retVal;
    
}

//returns an attribute delta representation for the specific attribute name
- (PutAttributeOperation*)putAttributeOperationFor:(NSString *)attribute {
    PutAttributeOperation* retVal = nil;

    AttributeInstanceData* aid = [self attributeInstanceDataFor:attribute];
        
    NSEntityDescription* entityDescription = [self entity];
    NSArray* attributeDescriptions = [entityDescription properties];
    
    if ([aid.iscounter boolValue]) {
        //it is a counter variable, so we calculate the delta
        for (NSAttributeDescription* attributeDescription in attributeDescriptions) {
            if ([[attributeDescription name] isEqualToString:attribute]) {
                //we have the right attribute description object
                NSAttributeType attrType = [attributeDescription attributeType];
                if (attrType == NSInteger64AttributeType ||
                    attrType == NSDoubleAttributeType) {
                    
                    NSDictionary* committedValues = [self committedValuesForKeys:[NSArray arrayWithObject:attribute]];
                    NSNumber* currentValue = [committedValues valueForKey:attribute];
                    NSNumber* newValue = (NSNumber*)[self changedValueFor:attribute];
                    
                    if (attrType == NSInteger64AttributeType) {
                        //its a int
                        if ([newValue intValue] > [currentValue intValue]) {
                            //its an add
                            NSNumber* deltaInt = [NSNumber numberWithInt:([newValue intValue]-[currentValue intValue])];
                            retVal = [PutAttributeOperation putOperationWithCode:kADD withValue:deltaInt];
                        }
                        else {
                            //its a subtraction
                            NSNumber* deltaInt = [NSNumber numberWithInt:([currentValue intValue]-[newValue intValue])];
                            retVal = [PutAttributeOperation putOperationWithCode:kREMOVE withValue:deltaInt];
                        }
                    }
                    else {
                        //its a double
                        if ([newValue doubleValue] > [currentValue doubleValue]) {
                            //its an add
                            NSNumber* deltaDbl = [NSNumber numberWithDouble:([newValue doubleValue]-[currentValue doubleValue])];
                            retVal = [PutAttributeOperation putOperationWithCode:kADD withValue:deltaDbl];
                        }
                        else {
                            //its a subtraction
                            NSNumber* deltaDbl = [NSNumber numberWithDouble:([currentValue doubleValue]-[newValue doubleValue])];
                            retVal = [PutAttributeOperation putOperationWithCode:kREMOVE withValue:deltaDbl];
                        }

                    }
                    
                }
                break;
            }
        }
    }
    else {
        //if its not a counter attribute then its always a replace with the new value
        retVal = [PutAttributeOperation putOperationWithCode:kREPLACE withValue:[self changedValueFor:attribute]];
    }
    return retVal;
  
        
}




///Returns an array of attribute values for each attribute name passed in
- (NSArray*)attributesFor:(NSArray *)attributeNames {

    NSMutableArray* retVal = [[NSMutableArray alloc]initWithCapacity:[attributeNames count]];
    
    int i = 0;
    for (NSString* attributeName in attributeNames) {
        SEL selector = NSSelectorFromString(attributeName);
        if ([self respondsToSelector:selector]) {
            id val = [self performSelector:selector];
            [retVal insertObject:val atIndex:i];
        }
        i++;
    }
    [retVal autorelease];                    
    return retVal;
}

- (NSArray*) copyFrom:(Resource*)resource {
    NSString* activityName = @"Resource.copyFrom:";
    NSEntityDescription* entity = [self entity];
    NSArray* attributes = [entity properties];
    NSMutableArray* attributesCopied = [[NSMutableArray alloc]init];
    
    
    for (NSAttributeDescription* attrDesc in attributes) {
        NSString* attributeName = [attrDesc name];
        if ([attributeName isEqualToString:POLL_NUM_PAGES])
        {
            NSLog(@"Dick");
        }
        
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
    LOG_RESOURCE(0, @"%@Refreshed %d attributes on object id: %@ with type: %@",activityName,[attributesCopied count],self.objectid,self.objecttype);
   
    return attributesCopied;
}

- (void)refreshWith:(Resource *)newResource {
    //refreshes the object with the server provided values
    NSArray* attributesCopied = [self copyFrom:newResource];
    
    //marks the objects as being clean
    [self markAsClean:attributesCopied];
    [attributesCopied release];
}
    

///This method will go through all of this objects attribute instance data objects
///and reset them tot he default values they would have had upon creation
- (void) resetAttributeInstanceDataToDefault
{
    NSArray* currentAIDs = [self.attributeinstancedata allObjects];
    ResourceContext* resourceContext = [ResourceContext instance];
    
    for (AttributeInstanceData* currentAID in currentAIDs) 
    {
        AttributeInstanceData* originalAID = [AttributeInstanceData attributeInstanceDataFor:ATTRIBUTEINSTANCEDATA withResourceContext:resourceContext forAttribute:currentAID.attributename shouldInsertIntoContext:NO]; 
        //now we have the default value for this AID
        //we now reset the current the value to that one
        if ([originalAID.attributename isEqualToString:POLL_NUM_PAGES]) {
            NSLog(@"Dick");
        }
        [currentAID resetTo:originalAID];
    }

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
    [objectAsDictionary release];
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
    [resourceDictionary release];
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
    [retVal autorelease];
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
                 
                && ![aid.islocal boolValue]) 
            {
                [retVal addObject:attrName]; 
            }
           
        }
    }
    [retVal autorelease];
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
    NSString* activityName = @"Resource.createInstanceOfTypeFromJSON:";
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
        LOG_RESOURCE(1, @"%@No valid entity description object found for %@",activityName,type);
        return nil;
    }
    else {
        //now we need to initialize it from the JSON string passed in
      
        Resource* obj = [[[Resource alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entityDescription insertIntoResourceContext:resourceContext]autorelease];
        
        //the object is being created from JSON, which means it was brought down from the service, marking it as not needing sync'ing
        [entityDescription release];
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
