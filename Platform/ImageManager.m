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
@implementation ImageManager
@synthesize imageCache;
@synthesize queue;
static  ImageManager* sharedManager;  

+ (ImageManager*) instance {
//    NSString* activityName = @"ImageManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[ImageManager alloc]init];
        } 
//        [BLLog v:activityName withMessage:@"completed initialization"];
        return sharedManager;
    }
}

- (id)init{
    self.queue = [[NSOperationQueue alloc] init];
    self.imageCache = [[ASIDownloadCache alloc]init];
    PlatformAppDelegate *appDelegate = (PlatformAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.imageCache setStoragePath:[appDelegate getImageCacheStorageDirectory]];
    
    return self;
}

-(void)dealloc {
    [self.queue release];
    [self.imageCache release];
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
        LOG_IMAGE(0,@"%@Image retrieved from existing file stored at %@, no need to download from cloud",activityName,path);
        
        return retVal;
    }
    
    
        Request* request = [Request createInstanceOfRequest];
        request.url = url;
        
        NSMutableDictionary *requestUserInfo = [NSMutableDictionary dictionaryWithObject:path forKey:IMAGEPATH];
        request.userInfo = requestUserInfo;
    request.operationcode = [NSNumber numberWithInt:kIMAGEDOWNLOAD];
    request.statuscode = [NSNumber numberWithInt:kPENDING];
    request.onSuccessCallback = callback;
    request.onFailCallback = callback;
    RequestManager* requestManager = [RequestManager instance];
        [requestManager submitRequest:request];
    
    return nil;
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
