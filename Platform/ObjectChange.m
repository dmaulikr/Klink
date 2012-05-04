//
//  ObjectChange.m
//  Platform
//
//  Created by Jasjeet Gill on 5/4/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ObjectChange.h"
#import "Macros.h"
#import "NSStringGUIDCategory.h"
@implementation ObjectChange
@dynamic targetobjectid;
@dynamic targetobjecttype;
@dynamic objectchange;
@dynamic datecreated;



//Extracts values from a apassed in JSON instance and populates attributes
//on this object accordingly
- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"AttributeChange.readAttributesFromJSONDictionary:";
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
                else if (attrType == NSBinaryDataAttributeType) {
                    //we are passed a base64 encoded string
                    NSString* base64String = (NSString*)value;
                    NSData* data = [NSString decodeBase64WithString:base64String];
                    [self setValue:data forKey:[attrDesc name]];
                }
                else if (attrType == NSStringAttributeType) {
                    if ([value isKindOfClass:[NSString class]]) {
                        [self setValue:value forKey:[attrDesc name]];
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
        withEntityDescription:(NSEntityDescription*)entity 
    insertIntoResourceContext:(ResourceContext*)resourceContext{
    
    if (resourceContext != nil) {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:resourceContext.managedObjectContext];
    }
    else {
        self = [super initWithEntity:entity insertIntoManagedObjectContext:nil];
    }
    
    if (self)  {
        
        [self readAttributesFromJSONDictionary:jsonDictionary];     
        
        
        
        
    }
    return self;
}

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* context = [[ResourceContext instance]managedObjectContext];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:OBJECTCHANGE inManagedObjectContext:context];
    return [self initFromJSONDictionary:jsonDictionary withEntityDescription:entityDescription insertIntoResourceContext:resourceContext];
}



+ (id) createInstanceOfObjectChangeFromJSON:(NSDictionary *)jsonDictionary 
{
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:OBJECTCHANGE inManagedObjectContext:resourceContext.managedObjectContext];
    ObjectChange* retVal = [[ObjectChange alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    [retVal autorelease];
    return retVal;
}



@end
