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

@implementation AuthenticationContext
@dynamic userid;
@dynamic expirydate;
@dynamic token;
@dynamic facebookaccesstoken;
@dynamic facebookaccesstokenexpirydate;
@dynamic facebookuserid;
@dynamic twitteraccesstoken;
@dynamic twitteruserid;
@dynamic wppassword;
@dynamic wpusername;
@dynamic wordpressurl;



- (BOOL) hasWordpress {
    BOOL retVal = NO;
    
    if (self.wpusername != nil && self.wordpressurl != nil) {
        retVal = YES;
    }
    return retVal;
}

- (BOOL) hasFacebook {
    BOOL retVal = NO;
    
    if (self.facebookuserid != nil && self.facebookaccesstoken != nil) {
        retVal = YES;
    }
    return retVal;
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

+ (id) createInstanceOfAuthenticationContext {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:resourceContext.managedObjectContext];
    AuthenticationContext* retVal = [[AuthenticationContext alloc]initWithEntity:entity insertIntoResourceContext:nil];
    [retVal autorelease];
    return retVal;    
}

+ (id) createInstanceOfAuthenticationContextFromJSON:(NSDictionary *)jsonDictionary {
    ResourceContext* resourceContext = [ResourceContext instance];
    NSEntityDescription* entity = [NSEntityDescription entityForName:AUTHENTICATIONCONTEXT inManagedObjectContext:resourceContext.managedObjectContext];
    AuthenticationContext* retVal = [[AuthenticationContext alloc]initFromJSONDictionary:jsonDictionary withEntityDescription:entity insertIntoResourceContext:nil];
    return retVal;
}
@end
