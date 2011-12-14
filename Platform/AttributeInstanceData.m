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
@dynamic islocal;
@dynamic iscounter;

- (id) initWithEntity:(NSEntityDescription *)entity 
insertIntoResourceContext:(ResourceContext *)context 
     forAttributeName:(NSString *)attributeName {
    
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    if (self) {
        self.isdirty = [NSNumber numberWithBool:NO];
        self.islocked = [NSNumber numberWithBool:NO];
        self.attributename = attributeName;
        self.isurlattachment = [NSNumber numberWithBool:NO];
        self.islocal = [NSNumber numberWithBool:NO];
        self.iscounter = [NSNumber numberWithBool:NO];
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
    retVal.islocal = [NSNumber numberWithBool:NO];
    
    //if this attribute is a datemodified or datecreated, we lock it so its not overwritten by the service
    NSString* lowerCaseName = [attribute lowercaseString];
    if ([lowerCaseName isEqualToString:DATECREATED]     ||
        [lowerCaseName isEqualToString:DATEMODIFIED]    ||
        [lowerCaseName isEqualToString:HASSEEN]         ||
        [lowerCaseName isEqualToString:HASOPENED]) {
        
        retVal.islocked = [NSNumber numberWithBool:YES];
    }
    
   
    //imageurl and thumbnail url attributes are attachments
    if ([lowerCaseName isEqualToString:IMAGEURL]        ||
        [lowerCaseName isEqualToString:THUMBNAILURL]) {
        retVal.isurlattachment = [NSNumber numberWithBool:YES];
    }
    
    
    
    //we mark hasopened, hasvoted as local only attributes
    if ([lowerCaseName isEqualToString:HASOPENED] ||
        [lowerCaseName isEqualToString:HASVOTED]) {
        retVal.islocal = [NSNumber numberWithBool:YES];
    }
    
    //we mark has seen as being a locked value, so it doesnt get overwritten by the server
    if ([lowerCaseName isEqualToString:HASSEEN]) {
        retVal.islocked = [NSNumber numberWithBool:YES];
    }
    
    //we mark numberofvotes attributes on Page and Photo objects local
    if ([type isEqualToString:PAGE] ||
        [type isEqualToString:PHOTO]) {
    
        if ([lowerCaseName isEqualToString:NUMBEROFVOTES] ||
            [lowerCaseName isEqualToString:NUMBEROFPHOTOS] ||
            [lowerCaseName isEqualToString:NUMBEROFCAPTIONS] ||
            [lowerCaseName isEqualToString:NUMBEROFPUBLISHVOTES]) {
            retVal.islocal = [NSNumber numberWithBool:YES];
        }
    }
    
    //we mark the thumbnail attribute on the user local
    if ([type isEqualToString:USER]) {
        if ([lowerCaseName isEqualToString:THUMBNAILURL]) {
            retVal.islocal = [NSNumber numberWithBool:YES];
        }
    }
    
    if ([lowerCaseName isEqualToString:NUMBEROFVOTES] ||
        [lowerCaseName isEqualToString:NUMBEROFCAPTIONS] ||
        [lowerCaseName isEqualToString:NUMBEROFPHOTOS] ||
        [lowerCaseName isEqualToString:NUMBEROFPUBLISHVOTES]) {
        //these are all counter variables
        retVal.iscounter = [NSNumber numberWithBool:YES];
    }
     
    [retVal autorelease];
    return retVal;
    
    
}
@end
