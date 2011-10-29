//
//  CloudEnumeratorFactory.m
//  Klink V2
//
//  Created by Bobby Gill on 9/18/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "CloudEnumeratorFactory.h"
#import "CloudEnumerator.h"

@implementation CloudEnumeratorFactory
@synthesize  enumeratorsForPhotos = m_enumeratorsForPhotos;
@synthesize enumeratorsForThemes = m_enumeratorsForThemes;
@synthesize enumeratorsForCaptions = m_enumeratorsForCaptions;
@synthesize enumeratorsForFeeds = m_enumeratorsForFeeds;
static CloudEnumeratorFactory* sharedManager;

+ (CloudEnumeratorFactory*)getInstance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[CloudEnumeratorFactory alloc]init];
        }
          return sharedManager;
    }
  
}

- (id) init {
    self = [super init];
    
    if (self) {
        self.enumeratorsForCaptions = [[NSMutableSet alloc]init];
        self.enumeratorsForPhotos = [[NSMutableSet alloc]init];
        self.enumeratorsForThemes = [[NSMutableSet alloc]init];
        self.enumeratorsForFeeds  = [[NSMutableSet alloc]init];
    }
    return self;
}
- (void) dealloc {
    
}

#pragma mark - Factory Methods

- (CloudEnumerator*) enumeratorForFeeds:(NSNumber*)userid {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForFeeds allObjects];
    for (int i = 0; i < [arrayOfEnumerators count];i++) {
        CloudEnumerator* currentEnumerator = [arrayOfEnumerators objectAtIndex:i];
        if ([currentEnumerator.identifier isEqualToString:[userid stringValue]]) {
            //this enumerator matches the type that we need, return it
            retVal = currentEnumerator;
            break;
        }
    }
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForFeeds:userid];
        [self.enumeratorsForFeeds addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
}

- (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForCaptions allObjects];
    for (int i = 0; i < [arrayOfEnumerators count];i++) {
        CloudEnumerator* currentEnumerator = [arrayOfEnumerators objectAtIndex:i];
        if ([currentEnumerator.identifier isEqualToString:[photoid stringValue]]) {
            //this enumerator matches the type that we need, return it
            retVal = currentEnumerator;
            break;
        }
    }
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForCaptions:photoid];
        [self.enumeratorsForCaptions addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
    
}

- (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForPhotos allObjects];
    for (int i = 0; i < [arrayOfEnumerators count];i++) {
        CloudEnumerator* currentEnumerator = [arrayOfEnumerators objectAtIndex:i];
        if ([currentEnumerator.identifier isEqualToString:[themeid stringValue]]) {
            //this enumerator matches the type that we need, return it
            retVal = currentEnumerator;
            break;
        }
    }
    
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForPhotos:themeid];
        [self.enumeratorsForPhotos addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
}

- (CloudEnumerator*) enumeratorForThemes {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForThemes allObjects];
    
    //for themese we can return the first one since there is only enumerator in general
    if ([arrayOfEnumerators count] > 0) {
        retVal = [arrayOfEnumerators objectAtIndex:0];
    }
    
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForThemes];
        [self.enumeratorsForThemes addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
}
@end
