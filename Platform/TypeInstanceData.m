//
//  TypeInstanceData.m
//  Platform
//
//  Created by Bobby Gill on 10/9/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "TypeInstanceData.h"
#import "ResourceContext.h"
#import "Types.h"
@implementation TypeInstanceData
@dynamic iscloudtype;
@dynamic typename;
@dynamic shouldsynctocloud;

+ (TypeInstanceData*) typeForType:(NSString *)typeName withResourceContext:(ResourceContext*)context {
    NSEntityDescription* entity = [NSEntityDescription entityForName:TYPEINSTANCEDATA inManagedObjectContext:context.managedObjectContext];
    TypeInstanceData* newType = [[TypeInstanceData alloc]initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    
    //Request objects are not sync'able
    if ([typeName isEqualToString:REQUEST]) {
        newType.iscloudtype = [NSNumber numberWithBool:NO];
        newType.shouldsynctocloud = [NSNumber numberWithBool:NO];
    }
    else {
        newType.iscloudtype = [NSNumber numberWithBool:YES];
    }
    

        //if the context is nil, then we infer that this is
        //an object being returned from the web service, hence 
        //it is already sync'ed and should not be sync'ed again
        newType.shouldsynctocloud = [NSNumber numberWithBool:NO];

    
    return newType;
}
@end
