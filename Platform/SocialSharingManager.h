//
//  SocialSharingManager.h
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Caption.h"
@interface SocialSharingManager : NSObject {
    
}


- (id) init;
- (void) shareCaption:(NSNumber*)captionID 
             onFinish:(Callback*)callback 
    trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;
- (void) shareCaptionOnTwitter:(NSNumber*)captionID 
                      onFinish:(Callback*)callback 
             trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;
- (void) shareCaptionOnFacebook:(NSNumber*)captionID 
                       onFinish:(Callback*)callback 
              trackProgressWith:(id<RequestProgressDelegate>)progressDelegate;

+ (id) getInstance;

@end
