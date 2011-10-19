//
//  AttributeInstanceData.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "AttributeInstanceData.h"
#import "Types.h"
#import "ResourceContext.h"

@implementation AttributeInstanceData
@dynamic attributename;
@dynamic isdirty;
@dynamic islocked;
@dynamic isurlattachment;

- (id) initWithEntity:(NSEntityDescription *)entity 
insertIntoResourceContext:(ResourceContext *)context 
     forAttributeName:(NSString *)attributeName {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        self.isdirty = [NSNumber numberWithBool:NO];
        self.islocked = [NSNumber numberWithBool:NO];
        self.attributename = attributeName;
        self.isurlattachment = [NSNumber numberWithBool:NO];
        
        //TODO: need to create initializers to isURLAttahcment to true for url data types
    }
    return self;
}


+ (AttributeInstanceData*) attributeInstanceDataFor:(NSString *)type 
                           withResourceContext:(ResourceContext *)context
                                       forAttribute:(NSString *)attribute{
    //this method takes the type name and attribute name and creates an attribute description object for it
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:ATTRIBUTEINSTANCEDATA inManagedObjectContext:context.managedObjectContext];
    AttributeInstanceData* retVal = [[AttributeInstanceData alloc]initWithEntity:entityDescription insertIntoResourceContext:context forAttributeName:attribute];
    retVal.isdirty = NO;
    retVal.islocked = NO;
    retVal.isurlattachment = NO;
    return retVal;
    
    
}
@end
