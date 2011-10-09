//
//  ResourceContext.m
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ResourceContext.h"
#import "PlatformAppDelegate.h"


@implementation ResourceContext
@synthesize managedObjectContext = __managedObjectContext;

- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    __managedObjectContext = appDelegate.managedObjectContext;
    return __managedObjectContext;
                                                            
}


- (void) save:(BOOL)saveToCloud 
     onFinishCallback:(Callback *)callback {
    //need to save the object locally to the managed object context
     
    //get all pending changes
    NSSet* insertedObjects = [self.managedObjectContext insertedObjects];
    NSSet* deletedObjects = [self.managedObjectContext deletedObjects];
    NSSet* updatedObjects = [self.managedObjectContext updatedObjects];
    
    //process created objects
    NSArray* insertedObjectsArray = [insertedObjects allObjects];
    for (int i = 0; i < [insertedObjectsArray count]; i++) {
        Resource* resource = [insertedObjectsArray objectAtIndex:i];
        //mark the object as being "dirty"
        [resource markAsDirty];
    }
    
    //process updated objects
    NSArray* updatedObjectsArray = [updatedObjects allObjects];
    for (int i = 0; i < [updatedObjectsArray count]; i++) {
        Resource* resource = [updatedObjectsArray objectAtIndex:i];
        [resource markAsDirty];
    }
    
    
    //process deleted objects
    NSArray* deletedObjectsArray = [deletedObjects allObjects];
    for (int i = 0; i < [deletedObjectsArray count]; i++) {
        Resource* resource = [deletedObjectsArray objectAtIndex:i];
        [resource markAsDirty];
    }
}


                                                                    
@end
