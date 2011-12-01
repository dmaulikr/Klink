//
//  SharingOptions.h
//  Klink V2
//
//  Created by Bobby Gill on 9/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"

@interface SharingOptions : NSObject<IJSONSerializable> {
    BOOL m_shareonfacebook;
    BOOL m_shareontwitter;
}

@property BOOL shareonfacebook;
@property BOOL shareontwitter;

+ (SharingOptions*) shareOnFacebook;
+ (SharingOptions*) shareOnTwitter;
+ (SharingOptions*) shareOnAll;
@end
