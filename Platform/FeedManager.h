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
    Callback* m_onRefreshCallback;
}

@property (nonatomic, retain) CloudEnumerator* feedEnumerator;
@property (nonatomic, retain) Callback* onRefreshCallback;

- (void) refreshFeedOnFinish:(Callback*)callback;
- (BOOL) isRefreshingFeed;


//Static initializer
+ (FeedManager*) instance;


@end
