//
//  ImageManager.h
//  Test Project 2
//
//  Created by Bobby Gill on 6/20/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "Attributes.h"

#import "Callback.h"
#import "NSURLCategory.h"

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

+ (ImageManager*) instance;



- (id)downloadImage:(NSString*)url withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback;
- (void)imageMovedFrom:(NSString*)originalFilePath toDestination:(NSURL*)destinationURL;
- (UIImage*)shrinkImage:(UIImage*)image toSize:(CGSize)size;
- (NSString*) fullPathForPhotoWithName:(NSString*)fileNameWithoutExtension;
- (void) deleteImage:(NSString*)url;
- (void) deleteImageFromURL:(NSString*)url;
- (void) deleteImageFromFile:(NSString*)path;

- (id)downloadImageFromURL:(NSString*)url withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback;
- (id)downloadImageFromFile:(NSString*)path withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback;
- (NSString*)saveImage:(UIImage*)image withFileName:(NSString*)fileNameWithoutExtension;
- (NSString*)saveImage:(UIImage*)image forPhotoWithID:(NSNumber*)photoid;
- (NSString*)saveThumbnailImage:(UIImage*)image forPhotoWithID:(NSNumber*)photoid;


@end
