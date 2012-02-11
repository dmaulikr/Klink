//
//  NSStringGUIDCategory.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/26/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringGUIDCategory)
+ (NSString*) GetGUID;
- (NSNumber*) numberValue;
- (NSString*) encodeString:(NSStringEncoding)encoding;


+ (NSString *)encodeBase64WithString:(NSString *)strData;

+ (NSData *)decodeBase64WithString:(NSString *)strData;
+ (NSString *)encodeBase64WithData:(NSData *)objData;

@end
