//
//  ImageDownloadResponse.h
//  Platform
//
//  Created by Bobby Gill on 10/27/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"
#import <UIKit/UIKit.h>

@interface ImageDownloadResponse : Response {
    UIImage* m_image;
    NSString* m_path;
}

@property (nonatomic,retain) NSString* path;
@property (nonatomic,retain) UIImage*  image;
@end
