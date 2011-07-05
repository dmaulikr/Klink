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
    NSString* activityName = @"ImageManager.getInstance:";
    @synchronized(self)
    {
        if (!sharedManager) {
            sharedManager = [[ImageManager alloc]init];
        } 
        [BLLog v:activityName withMessage:@"completed initialization"];
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

//looks at file system to find exisiting image, returns that
//else returns nil
//- (void) downloadImage:(NSString*)photoUrl forPhoto:(NSNumber*)photoID{
//    NSString* activityName = @"ImageManager.getImage:";
//    NSURL *url = [NSURL URLWithString:photoUrl];
//    NSString *filePath = [[self getFilePathFrom:photoID withURL:photoUrl]retain];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    
//    request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
//    request.delegate = self;
//    request.downloadCache = imageCache;
//    request.downloadDestinationPath = filePath;
//    [request setDidFinishSelector:@selector(onRequestSuccess:)];
//    [request setDidFailSelector:@selector(onRequestFailed:)] ;
//    
//    //create the userinfo payload to send to the response handler
//    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:1];    
//    [userInfo setObject:photoID forKey:an_OBJECTID];
//
//    request.userInfo = userInfo;
//    [userInfo release];
//    
//    [[self queue] addOperation:request];
//    
//    NSString* message = [NSString stringWithFormat:@"Executing download of image at %@ to file %@",photoUrl,filePath];
//    [BLLog v:activityName withMessage:message];
//                  
//}
//
//- (UIImage*) getImage:(NSNumber*)photoID withURL:(NSString*)url {
//    NSString* activityName = @"ImageManager.getImage:";
//    NSString* fileLocation = [self getFilePathFrom:photoID withURL:url];
//    BOOL doesFileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileLocation];
//    if (doesFileExists) {
//        UIImage* retVal = [UIImage imageWithContentsOfFile:fileLocation];
//        return retVal;
//    }
//    else {
//        NSString* message = [NSString stringWithFormat:@"no image exists at %@ for photo with id: %@",fileLocation,photoID];
//        [BLLog e:activityName withMessage:message];
//        return nil;
//    }
//}
//
//- (void)onRequestSuccess:(ASIHTTPRequest*) request { 
//    NSString* activityName = @"ImageManager.onRequestSuccess: ";
//    NSDictionary* userInfo = request.userInfo;
//    NSString* photoID = [userInfo objectForKey:an_OBJECTID];
//    
//    
//    
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    NSNotification *notification = [NSNotification notificationWithName:n_IMAGEDOWNLOADED object:nil userInfo:userInfo];
//    
//    [notificationCenter postNotification:notification];
//    
//    NSString* message = [NSString stringWithFormat:@"Image download complete, raising notification for Photo %@",photoID];
//    [BLLog v:activityName withMessage:message];
//}


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
    NSString* activityName = @"ImageManager.downloadImageFromFile:";
     
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileName]) {
         UIImage* image = [UIImage imageWithContentsOfFile:fileName];
         return image;
    }
    else {
        NSString* message = [NSString stringWithFormat:@"No file exists at %@",fileName];
        [BLLog e:activityName withMessage:message];
    }
    return nil;
}

- (id)downloadImageFromURL:(NSString*) url withUserInfo:(NSDictionary*)userInfo atCallback:(id<ImageDownloadCallback>)callback {
    NSString* activityName = @"ImageManager.downloadImageFromURL:";
    NSURL *urlObject = [NSURL URLWithString:url];
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString* fileName = [urlObject lastPathComponent];
    NSString* directory = [appDelegate getImageCacheStorageDirectory];
    NSString* path = [NSString stringWithFormat:@"%@/%@",directory,fileName];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSString* message = [NSString stringWithFormat:@"Found image on local store %@ at file %@",url,path];
        [BLLog v:activityName withMessage:message];
        UIImage* retVal = [UIImage imageWithContentsOfFile:path];
        return retVal;
    }
    
    NSString* message = [NSString stringWithFormat:@"Beginning download of %@ to file %@",url,path];
    [BLLog v:activityName withMessage:message];
    
    NSMutableDictionary *requestUserInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [requestUserInfo setValue:url forKey:@"url"];
    [requestUserInfo setValue:userInfo forKey:@"callbackdata"];
    [requestUserInfo setObject:callback forKey:@"callback"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlObject];    
    request.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
    request.delegate = self;
    request.downloadDestinationPath = path;
    request.downloadCache = imageCache;
    [request setDidFinishSelector:@selector(onImageDownloaded:)];
    [request setDidFailSelector:@selector(onImageDownloadFail:)] ;
    [self.queue addOperation:request];
    
    return nil;
}

#pragma mark - ASIHTTPRequest Delegate Handlers
- (void)onImageDownloaded:(ASIHTTPRequest*)request {
    NSString* activityName = @"ImageManager.onImageDownloaded:";
    
    NSDictionary* requestUserInfo = request.userInfo;
    NSURL* url = [requestUserInfo valueForKey:@"url"];
    NSDictionary* callbackUserInfo = [requestUserInfo valueForKey:@"callbackdata"];
    
    id<ImageDownloadCallback> callback = [requestUserInfo objectForKey:@"callback"];
    
    NSString* downloadedImagePath = request.downloadDestinationPath;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:downloadedImagePath]) {
        NSString* message = [NSString stringWithFormat:@"Image downloaded successfully from %@ to %@",url,downloadedImagePath];
        [BLLog v:activityName withMessage:message];
        
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
    [BLLog e:activityName withMessage:@"Image download failed"];
    
}


//
//- (NSString*)getFilePathFrom:(NSNumber*)photoID withURL:(NSString*)url {
//
//    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSString* directory = [appDelegate getImageCacheStorageDirectory];
//    NSMutableString* path = [[NSMutableString stringWithString:directory]autorelease];
//    [path appendFormat:@"/%@.%@",photoID,[url pathExtension]];
//    return path;
//}

//Saves the picture on the hard disk in teh cache folder and returns the full path
- (NSString*)saveImage:(UIImage*)image withFileName:(NSString*)fileNameWithoutExtension {
    Klink_V2AppDelegate *appDelegate = (Klink_V2AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableString* path =[NSMutableString stringWithString:[appDelegate getImageCacheStorageDirectory]];
    
    [path appendFormat:@"/%@.jpg",fileNameWithoutExtension]; 
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
    return path;
}

@end
