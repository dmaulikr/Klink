//
//  CloudEnumeratorFactory.h
//  Klink V2
//
//  Created by Bobby Gill on 9/18/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudEnumerator.h"

@interface CloudEnumeratorFactory : NSObject {
    NSMutableSet* m_enumeratorsForCaptions;
     NSMutableSet* m_enumeratorsForPhotos;
     NSMutableSet* m_enumeratorsForThemes;
    NSMutableSet* m_enumeratorsForFeeds;
}

@property (nonatomic,retain) NSMutableSet* enumeratorsForCaptions;
@property (nonatomic,retain) NSMutableSet* enumeratorsForPhotos;
@property (nonatomic,retain) NSMutableSet* enumeratorsForThemes;
@property (nonatomic,retain) NSMutableSet* enumeratorsForFeeds;

+ (CloudEnumeratorFactory*) getInstance;

- (CloudEnumerator*) enumeratorForCaptions:(NSNumber*)photoid;
- (CloudEnumerator*) enumeratorForPhotos:(NSNumber*)themeid;
- (CloudEnumerator*) enumeratorForThemes;
- (CloudEnumerator*) enumeratorForFeeds;
@end
