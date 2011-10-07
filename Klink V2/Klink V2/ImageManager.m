//
//  ImageManager.m
//  Test Project 2
//
//  Created by Bobby Gill on 6/20/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import "ImageManager.h"


@implementation ImageManager
@synthesize imageCache;
@synthesize queue;
static  ImageManager* sharedManager;  

+ (ImageManager*) getInstance {
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
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.imageCache setStoragePath:[appDelegate getImageCacheStorageDirectory]];
    
    return self;
}

-(void)dealloc {
    [self.queue release];
    [self.imageCache release];
    [super dealloc];
}



- (id)downloadImage:(NSString*)url withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback {
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


- (id)downloadImageFromFile:(NSString*) fileName withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback{
//    NSString* activityName = @"ImageManager.downloadImageFromFile:";
     
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileName]) {
         UIImage* image = [UIImage imageWithContentsOfFile:fileName];
         return image;
    }
    else {
//        NSString* message = [NSString stringWithFormat:@"No file exists at %@",fileName];
       // [BLLog e:activityName withMessage:message];
    }
    return nil;
}

- (id)downloadImageFromURL:(NSString*) url withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback {
//    NSString* activityName = @"ImageManager.downloadImageFromURL:";
    NSURL *urlObject = [NSURL URLWithString:url];
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* fileName = [urlObject lastPathComponent];
    NSString* directory = [appDelegate getImageCacheStorageDirectory];
    NSString* path = [NSString stringWithFormat:@"%@/%@",directory,fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
//        NSString* message = [NSString stringWithFormat:@"Found image on local store %@ at file %@",url,path];
//        [BLLog v:activityName withMessage:message];
        UIImage* retVal = [UIImage imageWithContentsOfFile:path];
        return retVal;
    }
    
    if (callback != nil) {
        
        NSMutableDictionary *requestUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [requestUserInfo setValue:url forKey:@"url"];
        [requestUserInfo setValue:userInfo forKey:@"callbackdata"];
        [requestUserInfo setObject:callback forKey:@"callback"];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlObject];    
        request.userInfo = requestUserInfo;
        request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
        request.delegate = self;
        request.timeOutSeconds = 5;
        [request setNumberOfTimesToRetryOnTimeout:3];
        
        request.downloadDestinationPath = path;
        request.downloadCache = imageCache;
        [request setDidFinishSelector:@selector(onImageDownloaded:)];
        [request setDidFailSelector:@selector(onImageDownloadFail:)] ;
        [self.queue addOperation:request];
    }
    return nil;
}

#pragma mark - ASIHTTPRequest Delegate Handlers
- (void)onImageDownloaded:(ASIHTTPRequest*)request {
    NSString* activityName = @"ImageManager.onImageDownloaded:";
    
    NSDictionary* requestUserInfo = request.userInfo;
        NSDictionary* callbackUserInfo = [requestUserInfo valueForKey:@"callbackdata"];
    
    id<ImageDownloadCallback> callback = [requestUserInfo objectForKey:@"callback"];
    
    NSString* downloadedImagePath = request.downloadDestinationPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:downloadedImagePath]) {
//        NSString* message = [NSString stringWithFormat:@"Image downloaded successfully from %@ to %@",url,downloadedImagePath];
        //[BLLog v:activityName withMessage:message];
        
        UIImage* image = [UIImage imageWithContentsOfFile:downloadedImagePath];
        
        [callback onImageDownload:image withUserInfo:callbackUserInfo];
    }
    else {        
        NSString* message = [NSString stringWithFormat:@"Image could not be found at download path %@",downloadedImagePath];
        [BLLog e:activityName withMessage:message];
    }
}

- (void)onImageDownloadFail:(ASIHTTPRequest*)request {
    NSString* activityName = @"ImageManager.onImageDownloadFail:";
    NSString* message = [NSString stringWithFormat:@"%@ failed to download due to %@",request.url,request.error];
    [BLLog e:activityName withMessage:message];
    
}


//Saves the picture on the hard disk in teh cache folder and returns the full path
- (NSString*)saveImage:(UIImage*)image withFileName:(NSString*)fileNameWithoutExtension {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString* path =[NSMutableString stringWithString:[appDelegate getImageCacheStorageDirectory]];
    
    [path appendFormat:@"/%@.jpg",fileNameWithoutExtension];
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
    return path;
}


@end
