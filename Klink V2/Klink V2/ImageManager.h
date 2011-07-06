//
//  ImageManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/20/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLLog.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "AttributeNames.h"
#import "NotificationNames.h"
#import "ImageDownloadProtocol.h"
#import "NSURLCategory.h"
#import "Klink_V2AppDelegate.h"
@interface ImageManager : NSObject {
    ASIDownloadCache* imageCache;
    NSOperationQueue* queue;
}
@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,retain) ASIDownloadCache *imageCache;
- (id) init;

//- (void) downloadImage:(NSString*) url forPhoto:(NSNumber*)photoID;
//- (UIImage*) getImage:(NSNumber*)photoID withURL:(NSString*)url;
//- (NSString*)getFilePathFrom:(NSNumber*)photoID withURL:(NSString*)url;

+ (ImageManager*) getInstance;



- (id)downloadImage:(NSString*)url withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback;


- (id)downloadImageFromURL:(NSString*) url withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback;
- (id)downloadImageFromFile:(NSString*) path withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback;
- (NSString*)saveImage:(UIImage*)image withFileName:(NSString*)fileNameWithoutExtension;



@end
