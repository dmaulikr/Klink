//
//  SocialPost.h
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SocialPost : NSObject {
    NSString* m_title;
    NSString* m_message;
    NSURL* m_url;
    NSArray* m_hashtags;
}

@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,retain) NSURL* url;
@property (nonatomic,retain) NSArray* hashtags;

+ (SocialPost*) postFor:(NSString*)message withTitle:(NSString*)title atUrl:(NSString*)url;
+ (SocialPost*) postFor:(NSString*)message withTitle:(NSString*)title withHashtags:postHashTags;
@end
