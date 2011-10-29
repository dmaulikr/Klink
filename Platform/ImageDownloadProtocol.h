//
//  ImageDownloadProtocol.h
//  Test Project 2
//
//  Created by Bobby Gill on 7/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ImageDownloadCallback 
-(void)onImageDownload:(UIImage*)image withUserInfo:(NSDictionary*)userInfo;


@end
