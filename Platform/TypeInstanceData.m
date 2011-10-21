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


+ (TypeInstanceData*) typeForType:(NSString *)typeName withResourceContext:(ResourceContext*)context {
    NSEntityDescription* entity = [NSEntityDescription entityForName:TYPEINSTANCEDATA inManagedObjectContext:context.managedObjectContext];
    TypeInstanceData* newType = [[TypeInstanceData alloc]initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    
    //Request objects are not sync'able
    if ([typeName isEqualToString:REQUEST]) {
        newType.iscloudtype = [NSNumber numberWithBool:NO];
            }
    else {
        newType.iscloudtype = [NSNumber numberWithBool:YES];
    }
    

    
    return newType;
}
@end
