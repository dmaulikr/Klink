//
//  ImageGallerySlider.h
//  Klink V2
//
//  Created by Bobby Gill on 7/6/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageGallerySlider : UIView {
    UIView *view;
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    UIImageView *imageView5;


}

@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (nonatomic, retain) IBOutlet UIImageView *imageView2;
@property (nonatomic, retain) IBOutlet UIImageView *imageView3;
@property (nonatomic, retain) IBOutlet UIImageView *imageView4;
@property (nonatomic, retain) IBOutlet UIImageView *imageView5;
@property (nonatomic, retain) IBOutlet UIView *view;

@end
