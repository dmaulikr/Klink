//
//  UIZoomingScrollView.h
//  Klink V2
//
//  Created by Bobby Gill on 8/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKlinkScrollView.h"
#import "UIViewTap.h"
#import "UIImageViewTap.h"

@interface UIZoomingScrollView : UIKlinkScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate>{
    
	
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
	UIActivityIndicatorView *spinner;
    
    id m_viewController;

}

@property (nonatomic,retain) id viewController;
// Methods
- (void)displayImage:(UIImage*)image;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
