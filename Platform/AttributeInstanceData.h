//
//  AttributeInstanceData.h
//  Platform
//
//  Created by Bobby Gill on 10/8/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AttributeInstanceData : NSManagedObject {
    
}

@property (nonatomic, retain) NSString* attributename;
@property (nonatomic, retain) NSNumber* isdirty;
@property (nonatomic, retain) NSNumber* islocked;

- (id) initWithEntity:(NSEntityDescription *)entity 
insertIntoManagedObjectContext:(NSManagedObjectContext *)context 
     forAttributeName:(NSString*)attributeName;
//static initializers
+ (AttributeInstanceData*) attributeInstanceDataFor:(NSString*)type 
                                       forAttribute:(NSString*)attribute 
                           withManagedObjectContext:(NSManagedObjectContext*)context;

@end
