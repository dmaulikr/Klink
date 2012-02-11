//
//  AuthenticationContext.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/16/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AuthenticationContext.h"
#import "JSONKit.h"
#import "IJSONSerializable.h"
#import "Types.h"
#import "Macros.h"
#import "NSStringGUIDCategory.h"

@implementation AuthenticationContext
@dynamic userid;
@dynamic expirydate;
@dynamic authenticator;
@dynamic hastwitter;
@dynamic hasfacebook;
@dynamic facebookuserid;
@dynamic isfirsttime;


#define kFACEBOOKMAXDATE    64092211200


- (BOOL) hasFacebook {

    return [self.hasfacebook boolValue];
}

- (BOOL) hasTwitter {

    return [self.hastwitter boolValue];
}


//Extracts values from a apassed in JSON instance and populates attributes
//on this object accordingly
- (void) readAttributesFromJSONDictionary:(NSDictionary*)jsonDictionary {
    NSString* activityName = @"AuthenticationContext.readAttributesFromJSONDictionary:";
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
                //TODO: research support for NSDate in JSON KIT, we can then uncomment this type of section and introduced NSDates into our datamodel
//                else if (attrType == NSDateAttributeType) {
//                    //we need to parse from the double description in the web service
//                    //package to a NSDate
//                    NSNumber* doubleDateValue = (NSNumber*)value;
//                    NSDate* convertedDate = nil;
//                    if ([doubleDateValue doubleValue] != 0) {
//                        convertedDate = [NSDate dateWithTimeIntervalSince1970:[doubleDateValue doubleValue]];
//                    }
//                    else {
//                        convertedDate = [NSDate dateWithTimeIntervalSince1970:kFACEBOOKMAXDATE];
//                    }
//                    [self setValue:convertedDate forKey:[attrDesc name]];
//                }
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

        [self readAttributesFromJSONDictionary:jsonDictionary];     
        
       
        

    }
    return self;
}

- (id) initFromJSONDictionary:(NSDictionary *)jsonDictionary {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext* context = [[ResourceContext instance]managedObjectContext];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:context];
    return [self initFromJSONDictionary:jsonDictionary withEntityDescription:entityDescription insertIntoResourceContext:resourceContext];
}

- (NSString*) toJSON {
    NSString* activityName = @"AuthenticationContext.toJSON:";
    NSEntityDescription* entity = [self entity];
    NSArray* attributeDescriptions = [[entity properties]retain];
    NSMutableDictionary* objectAsDictionary = [[NSMutableDictionary alloc]init];
    
    LOG_SECURITY(0, @"%Beginning enumeration of attributes and serializing to JSON",activityName);
    for (NSAttributeDescription* attrDesc in attributeDescriptions) 
    {
        NSString* attributeName = [attrDesc name];
        if ([attrDesc isKindOfClass:[NSAttributeDescription class]]) {
            SEL selector = NSSelectorFromString(attributeName);
            if ([self respondsToSelector:selector]) {
                id attrValue = [self performSelector:selector];
                NSAttributeType attrType = [attrDesc attributeType];
                if (attrType == NSBinaryDataAttributeType) {
                    
                    NSData* dataValue = (NSData*)attrValue;
                    NSString* base64string = [NSString encodeBase64WithData:dataValue];
                    //encode the string
                   // base64string = [base64string encodeString:NSUTF8StringEncoding];
                    [objectAsDictionary setValue:base64string forKey:attributeName];
                    LOG_SECURITY(0, @"%@Added attribute %@ with value %@ to JSON dictionary",activityName,[attrDesc name],base64string);
                }
                else {
                    [objectAsDictionary setValue:attrValue forKey:[attrDesc name]];
                    LOG_SECURITY(0, @"%@Added attribute %@ with value %@ to JSON dictionary",activityName,[attrDesc name],attrValue);
                }
            }
        }
    }
    
    //we now have a dictionary of all attribute values for this object
    NSError* error = nil;
    
    
    //we need to iterate through the object's attributes and compose a dictionary
    //of key-value pairs for attributes and references
    LOG_SECURITY(0, @"%@Serializing dictionary to JSON String...",activityName);
    NSString* retVal = [objectAsDictionary JSONStringWithOptions:JKSerializeOptionNone error:&error];
    [objectAsDictionary release];
    if (error != nil) {
        //error in json serialization
        LOG_SECURITY(1,@"%@Failure to serialize context object to JSON due to %@",activityName,[error userInfo]);
        return nil;
    }
    else {
        LOG_SECURITY(0, @"%@Successfully serialized authentication context to JSON: %@",activityName,retVal);
        return retVal;
    }
    
}

+ (id) createInstanceOfAuthenticationContext {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:resourceContext.managedObjectContext];

    AuthenticationContext* retVal = [[AuthenticationContext alloc]initWithEntity:entity insertIntoManagedObjectContext:nil];
    [retVal autorelease];
    return retVal;    
}

+ (id) createInstanceOfAuthenticationContextFromJSON:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:resourceContext.managedObjectContext];
    AuthenticationContext* retVal = [[AuthenticationContext alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    [retVal autorelease];
    return retVal;
}
@end
