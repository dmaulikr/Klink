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

@implementation Resource
@dynamic resourceid;
@dynamic resourcetype;
@dynamic datecreated;
@dynamic datemodified;
@dynamic attributeinstancedata;
@synthesize resourceContext = m_resourceContext;

- (void) dealloc {
    [super dealloc];
    
}

//todo need to change this method signature to take in a resourceocntext
- (id) initWithEntity:(NSEntityDescription *)entity insertIntoResourceContext:(ResourceContext *)context {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        self.resourcetype = [entity name];
        
        if (context != nil) {
            //we need to create a set of attribute description objects upon initialization of 
            //a new object
            NSDictionary* attributes = [entity attributesByName];
            NSMutableArray* attributeInstanceData = [[NSMutableArray alloc]init];
            for (NSString* attribute in attributes) {
                //create a new attribute type description object
                AttributeInstanceData* attributeMetadata = [AttributeInstanceData attributeInstanceDataFor:self.resourcetype forAttribute:attribute withManagedObjectContext:context];
                
                //add it to the internal attribute store
                [attributeInstanceData addObject:attributeMetadata];
            }
            self.attributeinstancedata = [[NSSet alloc]initWithArray:attributeInstanceData];
            [attributeInstanceData release];
        }
    }
    
    return self;
    
}
- (id) initFromJsonDictionary:(NSDictionary*)jsonDictionary {
    self = [super init];
    if (self)  {
        self.resourceid     = [jsonDictionary objectForKey:RESOURCEID];
        self.resourcetype   = [jsonDictionary objectForKey:RESOURCETYPE];
        self.datecreated    = [jsonDictionary objectForKey:DATECREATED];
        self.datemodified   = [jsonDictionary objectForKey:DATEMODIFIED];
    }
    return self;
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


- (NSString*) JSONString {
    NSString* activityName = [NSString stringWithFormat:@"%@.JSONString:",[self componentName]];
    NSDictionary* attributeValues = [self dictionaryFrom];
    NSError* error = nil;
    
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

- (NSString*) componentName {
    return self.resourcetype;
}




#pragma mark - Static Initializers
+ (id) createInstanceOfType:(NSString *)type 
         withManagedContext:(NSManagedObjectContext *)context {
    
    //create single user object
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:type inManagedObjectContext:context];
    
    Resource* obj = [[Resource alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:context];
    
    return obj;

}









@end
