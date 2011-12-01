//
//  SharingOptions.m
//  Klink V2
//
//  Created by Bobby Gill on 9/16/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "SharingOptions.h"
#import "JSONKit.h"
#import "Attributes.h"

@implementation SharingOptions
@synthesize shareontwitter = m_shareontwitter;
@synthesize shareonfacebook = m_shareonfacebook;


- (NSString*) toJSON {
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setValue:[NSNumber numberWithBool:self.shareonfacebook] forKey:SHAREONFACEBOOK];
    [dictionary setValue:[NSNumber numberWithBool:self.shareontwitter] forKey:SHAREONTWITTER];
    
    NSString* jsonString = [dictionary JSONString];
    [dictionary release];
    return jsonString;
}

#pragma mark - Statiuc initializers
+ (SharingOptions*) shareOnFacebook {
    SharingOptions* sharingOptions = [[[SharingOptions alloc]init]autorelease];
    sharingOptions.shareonfacebook = YES;
    sharingOptions.shareontwitter = NO;
    return sharingOptions;
}

+ (SharingOptions*) shareOnTwitter {
    SharingOptions* sharingOptions = [[[SharingOptions alloc]init]autorelease];
    sharingOptions.shareonfacebook = NO;
    sharingOptions.shareontwitter = YES;
    return sharingOptions;
}

+ (SharingOptions*) shareOnAll {
    SharingOptions* sharingOptions = [[[SharingOptions alloc]init]autorelease];
    sharingOptions.shareonfacebook = YES;
    sharingOptions.shareontwitter = YES;
    return sharingOptions;

}


@end
