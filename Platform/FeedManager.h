//
//  FeedManager.h
//  Klink V2
//
//  Created by Bobby Gill on 9/28/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudEnumerator.h"



@interface FeedManager : NSObject <NSFetchedResultsControllerDelegate,CloudEnumeratorDelegate>{
   
}

@property (nonatomic, retain) CloudEnumerator* feedEnumerator;

- (void) refreshFeed;
- (BOOL) isRefreshingFeed;


//Static initializer
+ (FeedManager*) instance;


@end
