//
//  TypeInstanceData.h
//  Platform
//
//  Created by Bobby Gill on 10/9/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceContext.h"

/*this object will store metadata for each resource
in the local persistence store */
@interface TypeInstanceData : NSManagedObject {
    
}

@property (nonatomic,retain) NSString* typename;
@property (nonatomic,retain) NSNumber* iscloudtype;
@property (nonatomic,retain) NSNumber* issingleton;

+ (TypeInstanceData*) typeForType:(NSString*)typeName withResourceContext:(ResourceContext*)context;
+ (BOOL)isSingletonType:(NSString*)type;
@end
