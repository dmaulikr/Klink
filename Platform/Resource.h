//
//  Resource.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ResourceContext.h"
@interface Resource : NSManagedObject {
    ResourceContext*    m_resourceContext;
}

@property   (nonatomic,retain)  NSNumber*   resourceid;
@property   (nonatomic,retain)  NSString*   resourcetype;
@property   (nonatomic,retain)  NSNumber*   datecreated;
@property   (nonatomic,retain)  NSNumber*   datemodified;
@property   (nonatomic,retain)  NSSet*      attributeinstancedata;
@property   (nonatomic,retain)  ResourceContext*    resourceContext;

- (id)          initFromJsonDictionary:(NSDictionary*)dictionary;
- (id)          dictionaryFrom;
- (NSString*)   JSONString;
- (void)        markAsDirty;
- (NSString*)   componentName;

+ (id)          createInstanceOfType:(NSString*)type withResourceContext:(ResourceContext*)context;
@end
