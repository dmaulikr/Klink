//
//  IWireSerializable.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/15/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol IWireSerializable <NSObject>



@optional
+ (NSString*) getTypeName;
- (NSString*) toJSON;
- (id) initFromDictionary:(NSDictionary*)jsonDictionary;
@end
