//
//  UICaptionView.h
//  Platform
//
//  Created by Jordan Gurrieri on 11/18/11.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventManager.h"

@interface UICaptionView : UIView {
    NSNumber* m_captionID;
    
    UIView* m_view;
    UIView* m_v_background;
    UILabel* m_lbl_caption;
    UILabel* m_lbl_metaData;
    UILabel* m_lbl_numVotes;
    UIImageView* m_iv_voteIcon;
}

@property (nonatomic, retain) NSNumber* captionID;

@property (nonatomic, retain) IBOutlet UIView* view;
@property (nonatomic, retain) IBOutlet UIView* v_background;
@property (nonatomic, retain) IBOutlet UILabel* lbl_caption;
@property (nonatomic, retain) IBOutlet UILabel* lbl_metaData;
@property (nonatomic, retain) IBOutlet UILabel* lbl_numVotes;
@property (nonatomic, retain) IBOutlet UIImageView* iv_voteIcon;

- (void) renderCaptionWithID:(NSNumber*)captionID;
- (void) render;

@end
