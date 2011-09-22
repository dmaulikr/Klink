//
//  UIThemePhotoCellView.h
//  Klink V2
//
//  Created by Bobby Gill on 9/21/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "Caption.h"
#import "ImageManager.h"
#import "ImageDownloadProtocol.h"

@interface UIThemePhotoCellView : UIView <ImageDownloadCallback> {
    BOOL        m_isHorizontalOrientation;
    int         m_padding;
    Photo*      m_photo;
    Caption*    m_caption;
    UIImage*    m_image;
    UIView*     m_captionBackground;
}

- (id) initWithFrame:(CGRect)frame withPhoto:(Photo*)photo withCaption:(Caption*)caption withPadding:(int)padding;
- (void) setPhoto:(Photo*)photo withCaption:(Caption*)caption;

@property BOOL isHorizontalOrientation;
@property int  padding;
@property (nonatomic,retain) Caption*  caption;
@property (nonatomic,retain) Photo*    photo;
@property (nonatomic,retain) UIImage*  image;
@property (nonatomic,retain) UIView*   captionBackground;

@end
