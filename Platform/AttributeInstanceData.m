//
//  AttributeInstanceData.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AttributeInstanceData.h"
#import "Types.h"

@implementation AttributeInstanceData
@dynamic attributename;
@dynamic isdirty;
@dynamic islocked;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context forAttributeName:(NSString *)attributeName {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        self.isdirty = [NSNumber numberWithBool:NO];
        self.islocked = [NSNumber numberWithBool:NO];
        self.attributename = attributeName;
    }
    return self;
}


+ (AttributeInstanceData*) attributeInstanceDataFor:(NSString *)type 
                                       forAttribute:(NSString *)attribute 
                           withManagedObjectContext:(NSManagedObjectContext *)context{
    //this method takes the type name and attribute name and creates an attribute description object for it
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:ATTRIBUTEINSTANCEDATA inManagedObjectContext:context];
    AttributeInstanceData* retVal = [[AttributeInstanceData alloc]initWithEntity:entityDescription insertIntoManagedObjectContext:context forAttributeName:attribute];
    return retVal;
    
    
}
@end
