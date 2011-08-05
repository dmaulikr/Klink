//
//  UIButtonBar.h
//  Klink V2
//
//  Created by Bobby Gill on 8/5/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButtonBar : UIView {
    int m_width;
    int m_height;
    int m_button_width;
    int m_button_height;
    
    
}
- (void) onNavigateTo:(NSNumber*)photoid withCaption:(NSNumber*)captionid;
+ (UIButtonBar*) buttonBarForPhoto:(NSNumber*)photoid withCaption:(NSNumber*)captionid;
@end
