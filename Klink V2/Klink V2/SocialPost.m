//
//  SocialPost.m
//  Klink V2
//
//  Created by Bobby Gill on 8/25/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SocialPost.h"


@implementation SocialPost
@synthesize title = m_title;
@synthesize message = m_message;
@synthesize url = m_url;
@synthesize hashtags = m_hashtags;

+ (SocialPost*) postFor:(NSString *)message withTitle:(NSString *)title atUrl:(NSString *)url  {
    SocialPost* newPost = [[SocialPost alloc]init];
    newPost.title = title;
    newPost.message = message;
    if (url != nil) {
        newPost.url =[NSURL URLWithString: url];
    }
    else {
        newPost.url = nil;
    }
    [newPost autorelease];
    return newPost;
}

+ (SocialPost*) postFor:(NSString *)message withTitle:(NSString *)title withHashtags:postHashTags{
    SocialPost* retVal =  [self postFor:message withTitle:title atUrl:nil];
    retVal.hashtags = postHashTags;
    return retVal;
}
@end
