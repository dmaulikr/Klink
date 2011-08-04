//
//  UIPagedViewItem.h
//  Klink V2
//
//  Created by Bobby Gill on 8/3/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIPagedViewItem : UIView {
    int   m_index;
    id    m_view;
    
}

@property   int index;
@property (nonatomic,retain) id view;

- (void)    setMaxMinZoomScalesForCurrentBounds;
@end
