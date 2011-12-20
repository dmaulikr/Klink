//
//  ImageManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/20/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ImageManager.h"
#import "PlatformAppDelegate.h"
#import "CallbackResult.h"
#import "ImageDownloadResponse.h"
#import "Macros.h"
#import "Request.h"
#import "RequestManager.h"

#define kScale 2


@implementation ImageManager
@synthesize imageCache;
@synthesize queue;
static  ImageManager* sharedManager;  

+ (ImageManager*) instance {
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[ImageManager alloc]init];
        } 

        return sharedManager;
    }
}

- (id)init{
    self = [super init];
    
    if (self) {
        NSOperationQueue* oq = [[NSOperationQueue alloc]init];
        self.queue = oq;
        [oq release];
        
        ASIDownloadCache* dc = [[ASIDownloadCache alloc]init];
        self.imageCache = dc;
        [dc release];
       
        PlatformAppDelegate *appDelegate = (PlatformAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.imageCache setStoragePath:[appDelegate getImageCacheStorageDirectory]];
    }
    return self;
}

-(void)dealloc {
  //  [self.queue release];
   // [self.imageCache release];
    [super dealloc];
}


- (id)downloadImage:(NSString*)url withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback {
    //check to see if the url is a file reference or a url reference
    if ([NSURL isValidURL:url]) {
        //its a url
        return [self downloadImageFromURL:url withUserInfo:userInfo atCallback:callback];
        
    }
    else {
        //its a file
        return [self downloadImageFromFile:url withUserInfo:userInfo atCallback:callback];
    }
    
}

- (void) imageMovedFrom:(NSString *)originalFilePath toDestination:(NSURL *)destinationURL {
    //this method will take the image located aqt the original filePath, and move it to a path
    //such that the URL addressed in the second parameter will correctly hit the cache whenever it is requested
    NSString* activityName = @"ImageManager.imageMovedFrom:";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    PlatformAppDelegate* appDelegate = (PlatformAppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([fileManager fileExistsAtPath:originalFilePath]) {
        //file exists
        NSString* fileName = [destinationURL lastPathComponent];
        NSString* directory = [appDelegate getImageCacheStorageDirectory];
        NSString* path = [NSString stringWithFormat:@"%@/%@",directory,fileName];
        
        NSError* error = nil;
        
        if (![fileManager fileExistsAtPath:path]) {
            [fileManager copyItemAtPath:originalFilePath toPath:path error:&error];
            
            if (error != nil) {
                LOG_IMAGE(1,@"%@Failed to copy image from %@ to %@ due to %@",activityName,originalFilePath,path,[error userInfo]);
            }
            else {
                LOG_IMAGE(0,@"%@Successfully copied image from %@ to %@",activityName,originalFilePath,path);
            }
        }
        else {
            LOG_IMAGE(0,@"%@Skipping image copy as image already exists at destination path %@",activityName,path);
        }
        
    }
    else {
        LOG_IMAGE(1, @"%@No file exists at path %@",activityName,originalFilePath);
    }
}


- (id)downloadImageFromFile:(NSString*) fileName withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback{
    NSString* activityName = @"ImageManager.downloadImageFromFile:";     
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileName]) {
         UIImage* image = [UIImage imageWithContentsOfFile:fileName];
         return image;
    }
    else {
        LOG_IMAGE(1,@"%@Unable to find image on filesystem at %@",activityName,fileName);
    }
    return nil;
}

- (id)downloadImageFromURL:(NSString*) url withUserInfo:(NSDictionary*)userInfo atCallback:(Callback*)callback {
    NSString* activityName = @"ImageManager.downloadImageFromURL:";
    NSURL *urlObject = [NSURL URLWithString:url];
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* fileName = [urlObject lastPathComponent];
    NSString* directory = [appDelegate getImageCacheStorageDirectory];
    NSString* path = [NSString stringWithFormat:@"%@/%@",directory,fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {

        UIImage* retVal = [UIImage imageWithContentsOfFile:path];
        
        if (retVal == nil) {
            LOG_IMAGE(1, @"%@Could not deserialize stored data at %@ into image object. Redownloading from cloud",activityName,path);
        }
        else {
            LOG_IMAGE(0,@"%@Image retrieved from existing file stored at %@, no need to download from cloud",activityName,path);
            return retVal;
        }
        
    }
    
    
    Request* request = [Request createInstanceOfRequest];
    request.url = url;
    
    NSMutableDictionary *requestUserInfo = [NSMutableDictionary dictionaryWithObject:path forKey:IMAGEPATH];
    [requestUserInfo addEntriesFromDictionary:callback.context];
    request.userInfo = requestUserInfo;
    request.operationcode = [NSNumber numberWithInt:kIMAGEDOWNLOAD];
    
     [request updateRequestStatus:kPENDING];
    //request.statuscode = [NSNumber numberWithInt:kPENDING];
    
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    RequestManager* requestManager = [RequestManager instance];
    [requestManager submitRequest:request];
    
    return nil;
}

static inline double radians (double degrees) {
    return degrees * M_PI/180;
}

- (UIImage*)shrinkImage:(UIImage *)original toSize:(CGSize)size {
    //CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat scale = kScale;
    
    CGFloat targetWidth = size.width * scale;
    CGFloat targetHeight = size.height * scale;
    CGImageRef imageRef = [original CGImage];
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef context;
    
    // For images taken in portrait mode (the right or left cases), we need to switch targetWidth and targetHeight when building the CG context
   
    context = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    CGColorSpaceRelease(colorSpaceInfo);
       
    // We need to rotate the CG context before drawing the image.
    // In the right or left cases, we need to switch targetWidth and targetHeight, and also the origin point
    if (original.imageOrientation == UIImageOrientationLeft || original.imageOrientation == UIImageOrientationLeftMirrored) {
        CGContextRotateCTM (context, radians(90));
        CGContextTranslateCTM (context, 0, -targetWidth);
    } else if (original.imageOrientation == UIImageOrientationRight || original.imageOrientation == UIImageOrientationRightMirrored) {
        CGContextRotateCTM (context, radians(-90));
        CGContextTranslateCTM (context, -targetHeight, 0);
    } else if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationUpMirrored) {
        // NOTHING
    } else if (original.imageOrientation == UIImageOrientationDown || original.imageOrientation == UIImageOrientationDownMirrored) {
        CGContextTranslateCTM (context, targetWidth, targetHeight);
        CGContextRotateCTM (context, radians(-180));
    }
    
    // For images to be presented in portrait mode (the right or left cases), we need to switch targetWidth and targetHeight when drawing the new image
    if (original.imageOrientation == UIImageOrientationUp || original.imageOrientation == UIImageOrientationDown || original.imageOrientation == UIImageOrientationUpMirrored  || original.imageOrientation == UIImageOrientationDownMirrored) {

        CGContextDrawImage(context, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
        
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, targetHeight, targetWidth), imageRef);
    }
    
    
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    
    UIImage* shrunkenImage = [UIImage imageWithCGImage:shrunken];
    
    
    CGContextRelease(context);
    CGImageRelease(shrunken);
    
    return shrunkenImage;

}

#pragma mark - ASIHTTPRequest Delegate Handlers
- (void) onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"ImageManager.onImageDownloadComplete:";
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if (response.didSucceed) {
        LOG_IMAGE(0,@"%@Image download succeeded with image stored at %@",activityName,response.path);
    }
    else {
        LOG_IMAGE(1,@"%@Image download failed due to %@",activityName,response.errorMessage);
    }
}


//Saves the picture on the hard disk in teh cache folder and returns the full path
- (NSString*)saveImage:(UIImage*)image withFileName:(NSString*)fileNameWithoutExtension {
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString* path =[NSMutableString stringWithString:[appDelegate getImageCacheStorageDirectory]];
    
    [path appendFormat:@"/%@.jpg",fileNameWithoutExtension];
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
    return path;
}


@end
