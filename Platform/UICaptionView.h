//
//  UICaptionView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/18/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICaptionView : UIView {
    NSNumber* m_captionID;
    
    UIView* m_view;
    UIView* m_v_background;
    UILabel* m_lbl_caption;
    UILabel* m_lbl_metaData;
}

@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UIView* view;
@property (nonatomic, retain) IBOutlet UIView* v_background;
@property (nonatomic, retain) IBOutlet UILabel* lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel* lbl_metaData;

- (void) renderCaptionWithID:(NSNumber*)captionID;

@end
