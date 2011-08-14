//
//  NSFetchedResultsControllerCategory.h
//  Klink V2
//
//  Created by Bobby Gill on 8/14/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerManagedResource.h"

@interface NSFetchedResultsController (NSFetchedResultsControllerCategory)
- (int) indexOf:(ServerManagedResource*)resource;
@end
