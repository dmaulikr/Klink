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
@dynamic issingleton;


+ (TypeInstanceData*) typeForType:(NSString *)typeName withResourceContext:(ResourceContext*)context {
    NSEntityDescription* entity = [NSEntityDescription entityForName:TYPEINSTANCEDATA inManagedObjectContext:context.managedObjectContext];
    TypeInstanceData* newType = [[TypeInstanceData alloc]initWithEntity:entity insertIntoManagedObjectContext:context.managedObjectContext];
    
    newType.typename = typeName;
    
    //we mark the ApplicationSettings object as not being a cloud type
    if ([typeName isEqualToString:APPLICATIONSETTINGS]) {
        newType.iscloudtype = [NSNumber numberWithBool:NO];
        newType.issingleton = [NSNumber numberWithBool:YES];
    }
    else {
        newType.iscloudtype = [NSNumber numberWithBool:YES];
        newType.issingleton = [NSNumber numberWithBool:NO];
    }
    
    
    [newType autorelease];
    return newType;
}

+ (BOOL) isSingletonType:(NSString *)type {
    if ([type isEqualToString:APPLICATIONSETTINGS]) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
