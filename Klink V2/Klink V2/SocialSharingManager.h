//
//  SocialSharingManager.h
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialPost.h"
#import "Facebook.h"
#import "Caption.h"
@interface SocialSharingManager : NSObject<FBRequestDelegate> {
    
}

@property (nonatomic,retain) Facebook* facebook;

- (id) init;
- (void) shareCaption:(NSNumber*)captionID;
- (void) shareCaptionOnTwitter:(SocialPost*)post;
- (void) shareCaptionOnFacebook:(Caption*)caption withPost:(SocialPost*)post;
- (void) shareCaptionOnWordpress:(NSNumber*)captionID;
+ (id) getInstance;

@end
