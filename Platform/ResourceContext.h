//
//  ResourceContext.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "Callback.h"

@interface ResourceContext : NSObject {
    
}
@property (nonatomic,retain) NSManagedObjectContext* managedObjectContext;

- (void) save:(BOOL)saveToCloudAfter
onFinishCallback:(Callback*)callback;

@end
