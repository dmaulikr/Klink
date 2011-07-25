//
//  FullScreenPhotoController.h
//  Klink V2
//
//  Created by Jordan Gurrieri on 7/13/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Theme.h"
#import "Caption.h"
#import "User.h"
#import "ImageDownloadProtocol.h"
#define kNavigationBarFadeDelay 5.5

@interface FullScreenPhotoController : UIViewController <ImageDownloadCallback> {
    UIImageView *m_imageView;
    UILabel     *m_submittedByLabel;
    UILabel     *m_captionLabel;
    Photo       *m_photo;
    Theme       *m_theme;
    Caption     *m_caption;
    User        *m_user;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *submittedByLabel;
@property (nonatomic, retain) IBOutlet UILabel *captionLabel;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) Theme *theme;
@property (nonatomic, retain) Caption *caption;
@property (nonatomic, retain) User *user;

@end
