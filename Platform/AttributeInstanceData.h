//
//  AttributeInstanceData.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface AttributeInstanceData : NSManagedObject {
    
}

@property (nonatomic, retain) NSString* attributename;
@property (nonatomic, retain) NSNumber* isdirty;
@property (nonatomic, retain) NSNumber* islocked;
@property (nonatomic, retain) NSNumber* isurlattachment;
@property (nonatomic, retain) NSNumber* islocal;
@property (nonatomic, retain) NSNumber* iscounter;

- (id) initWithEntity:(NSEntityDescription *)entity 
insertIntoResourceContext:(ResourceContext *)context 
     forAttributeName:(NSString*)attributeName;

- (void) resetTo:(AttributeInstanceData*)originalAID;
//static initializers

+ (AttributeInstanceData*) attributeInstanceDataFor:(NSString*)type 
                           withResourceContext:(ResourceContext*)context
                            forAttribute:(NSString*)attribute;

+ (AttributeInstanceData*) attributeInstanceDataFor:(NSString*)type 
                                withResourceContext:(ResourceContext*)context
                                       forAttribute:(NSString*)attribute
                            shouldInsertIntoContext:(BOOL)shouldInsertIntoContext;

@end
