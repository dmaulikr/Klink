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
@synthesize enumeratorsForUsers = m_enumeratorsForUsers;
@synthesize enumeratorsForDrafts = m_enumeratorsForDrafts;
static CloudEnumeratorFactory* sharedManager;

+ (CloudEnumeratorFactory*)instance {
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
        NSMutableSet* cSet = [[NSMutableSet alloc]init];
        self.enumeratorsForCaptions = cSet;
        [cSet release];
        
        
        NSMutableSet* pSet = [[NSMutableSet alloc]init];
        self.enumeratorsForPhotos = pSet;
        [pSet release];
       
        
        NSMutableSet* tSet = [[NSMutableSet alloc]init];
        self.enumeratorsForThemes = tSet;
        [tSet release];
        
        
        NSMutableSet* fSet= [[NSMutableSet alloc]init];
        self.enumeratorsForFeeds  = fSet;
        [fSet release];
        
        NSMutableSet* uSet = [[NSMutableSet alloc]init];
        self.enumeratorsForUsers = uSet;
        [uSet release];
        
        NSMutableSet* dSet = [[NSMutableSet alloc]init];
        self.enumeratorsForDrafts = dSet;
        [dSet release];
    }
    return self;
}
- (void) dealloc {
   // [self.enumeratorsForCaptions release];
   // [self.enumeratorsForPhotos release];
   // [self.enumeratorsForThemes release];
   // [self.enumeratorsForFeeds  release];
   // [self.enumeratorsForUsers release];
   // [self.enumeratorForDrafts release];
    [super dealloc];
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


- (CloudEnumerator*) enumeratorForUser:(NSNumber *)userid {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForUsers allObjects];
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
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForUser:userid];
        [self.enumeratorsForUsers addObject:newEnumerator];
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

- (CloudEnumerator*) enumeratorForPages {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForThemes allObjects];
    
    //for themese we can return the first one since there is only enumerator in general
    if ([arrayOfEnumerators count] > 0) {
        retVal = [arrayOfEnumerators objectAtIndex:0];
    }
    
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForPages];
        [self.enumeratorsForThemes addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
}

- (CloudEnumerator*) enumeratorForDrafts {
    CloudEnumerator* retVal = nil;
    
    NSArray* arrayOfEnumerators = [self.enumeratorsForDrafts allObjects];
    
    //for themese we can return the first one since there is only enumerator in general
    if ([arrayOfEnumerators count] > 0) {
        retVal = [arrayOfEnumerators objectAtIndex:0];
    }
    
    
    if (retVal == nil) {
        //could not find an existing enumerator to return, create a new one
        CloudEnumerator* newEnumerator = [CloudEnumerator enumeratorForDrafts];
        [self.enumeratorsForDrafts addObject:newEnumerator];
        retVal = newEnumerator;
    }
    return retVal;
 
}
@end
