//
//  UIPhotoCaptionScrollView.h
//  Klink V2
//
//  Created by Bobby Gill on 8/4/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIZoomingScrollView.h"
#import "UIPagedViewSlider2.h"

@class Photo;

@interface UIPhotoCaptionScrollView : UIZoomingScrollView <UIPagedViewSlider2Delegate> {
    Photo*              m_photo;
    UIPagedViewSlider2* m_captionScrollView;
}

- (id) initWithFrame:(CGRect)frame withPhoto:(Photo *)photo;

@property (nonatomic,retain) Photo*                         photo;
@property (nonatomic,retain) UIPagedViewSlider2*            captionScrollView;
@property (nonatomic,retain) NSFetchedResultsController*    frc_captions;
@property (nonatomic,retain) NSManagedObjectContext*        managedObjectContext;
@end
