//
//  NSFetchedResultsControllerCategory.m
//  Klink V2
//
//  Created by Bobby Gill on 8/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "NSFetchedResultsControllerCategory.h"


@implementation NSFetchedResultsController (NSFetchedResultsControllerCategory)

- (int) indexOf:(ServerManagedResource *)res {
    NSArray* objects = self.fetchedObjects;
    int retVal = -1;
    
    for (int i = 0; i < [objects count];i++) {
        ServerManagedResource* resource = [objects objectAtIndex:i];
        if ([resource.objectid isEqualToNumber:res.objectid]) {
            retVal = i;
            break;
        }
    }
    return retVal;
}
@end
