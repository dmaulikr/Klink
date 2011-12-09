//
//  LandscapePhotoViewController.h
//  Platform
//
//  Created by Jordan Gurrieri on 12/7/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LandscapePhotoViewController : BaseViewController {
    NSNumber* m_photoID;
    UIImageView* m_iv_landscapePhoto;
}

@property (nonatomic, retain) NSNumber*             photoID;
@property (nonatomic,retain) IBOutlet UIImageView*  iv_landscapePhoto;

+ (LandscapePhotoViewController*)createInstanceWithPhotoID:(NSNumber*)photoID;

@end
