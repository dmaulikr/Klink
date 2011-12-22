//
//  IDGenerator.m
//  Klink V2
//
//  Created by Bobby Gill on 8/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "IDGenerator.h"


@implementation IDGenerator

@synthesize knownIDs = m_knownIDs;

static IDGenerator* sharedManager;

+ (IDGenerator*) instance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[IDGenerator alloc]init];
        }
        return sharedManager;
    }
    
}

- (void) dealloc {
    self.knownIDs = nil;
    
}

- (id) init {
    self = [super init];
    if (self) {
        
        NSMutableArray* kids = [[NSMutableArray alloc]init];
        self.knownIDs = kids;
        [kids release];
    }
    return self;
    
}

- (BOOL) isIDKnown:(long)candidate {
    BOOL result = NO;
    
    for (int i = 0; i < [self.knownIDs count];i++) {
        long idAt = [[self.knownIDs objectAtIndex:i]longValue];
        if (idAt == candidate) {
            return YES;
        }
    }
    return result;
}

- (NSNumber*)generateNewId:(NSString *)objectType {
    
    long candidate = 0;
    
    candidate = arc4random() % LONG_MAX;
   
    while ([self isIDKnown:candidate]) {
        candidate = arc4random() % LONG_MAX;

    }

    [self.knownIDs addObject:[NSNumber numberWithLong:candidate]];
    return [NSNumber numberWithLong:candidate];
    
    

    
}

- (NSNumber*)generateNewId:(NSString *)objectType byUser:(NSNumber *)userid {
    
    long candidate = 0;
    
    candidate = arc4random() % LONG_MAX;
    
    while ([self isIDKnown:candidate]) {
        candidate = arc4random() % LONG_MAX;
        
    }
    
    [self.knownIDs addObject:[NSNumber numberWithLong:candidate]];
    return [NSNumber numberWithLong:candidate];

    
}
@end
