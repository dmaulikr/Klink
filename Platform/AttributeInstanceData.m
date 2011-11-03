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
#import "Attributes.h"

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
    retVal.isdirty = [NSNumber numberWithBool:NO];
    retVal.islocked = [NSNumber numberWithBool:NO];
    retVal.isurlattachment = [NSNumber numberWithBool:NO];
    
    //if this attribute is a datemodified or datecreated, we lock it so its not overwritten by the service
    NSString* lowerCaseName = [attribute lowercaseString];
    if ([lowerCaseName isEqualToString:DATECREATED]     ||
        [lowerCaseName isEqualToString:DATEMODIFIED]    ||
        [lowerCaseName isEqualToString:HASSEEN]         ||
        [lowerCaseName isEqualToString:HASOPENED]) {
        
        retVal.islocked = [NSNumber numberWithBool:YES];
    }
    
   
    
    if ([lowerCaseName isEqualToString:IMAGEURL]        ||
        [lowerCaseName isEqualToString:THUMBNAILURL]) {
        retVal.isurlattachment = [NSNumber numberWithBool:YES];
    }
    return retVal;
    
    
}
@end
