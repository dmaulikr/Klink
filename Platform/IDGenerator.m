//
//  IDGenerator.m
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "IDGenerator.h"


@implementation IDGenerator

+ (NSNumber*)generateNewId:(NSString *)objectType {
    return [NSNumber numberWithLong:(arc4random() % LONG_MAX)];
}

+ (NSNumber*)generateNewId:(NSString *)objectType byUser:(NSNumber *)userid {
    
  

    return [NSNumber numberWithLong:(arc4random() % LONG_MAX)];
    
}
@end
